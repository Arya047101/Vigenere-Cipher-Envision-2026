module testbench;

//ENTER UPPERCASE OR LOWERCASE LETTERS UPTO 16
parameter [128*8-1:0] PLAINTEXT = "SecretMessage";
parameter [128*8-1:0] KEY       = "Kryptos";
parameter             MODE      = 0;        // 0 = Encrypt, 1 = Decrypt

  
reg clk = 0;                    //cloak
always #5 clk = ~clk;
reg        reset;
reg [4:0]  switches;
reg        input_mode_switch;   // 0 = text buffer, 1 = key buffer
reg        mode_switch;         // 0 = encrypt,     1 = decrypt
reg        store;               // commit switches to active buffer
reg        start;               // begin cipher
reg        next;                // step to next output character
reg        text_reset;          // clear text buffer (key preserved)

wire [4:0] result_out;
top_module uut (
.clk              (clk),
.reset            (reset),
.switches         (switches),
.input_mode_switch(input_mode_switch),
.mode_switch      (mode_switch),
.store            (store),
.start            (start),
.next             (next),
.text_reset       (text_reset),
.result_out       (result_out)
);



// Finds length of string
function integer str_len;
input [1023:0] s;
integer k;
begin
            str_len = 0;
            for (k = 0; k < 128; k = k + 1)
                if (s[k*8 +: 8] != 8'h00) str_len = str_len + 1;
        end
    endfunction

    // Gets character from string
    // Converts ASCII letter into alphabet index
    // A -> 0
    // B -> 1...
    // Z -> 25

    function [4:0] get_char;
        input [1023:0] s;
        input integer  i;
        input integer  len;
        reg   [7:0]    ascii;
        begin
            ascii    = s[(len - 1 - i)*8 +: 8];
            get_char = ascii[4:0] - 5'd1;
        end
    endfunction

    // Convert index to ASCII
    function [7:0] to_ascii;
        input [4:0] val;
        begin
            to_ascii = 8'h41 + {3'b0, val};   
        end
    endfunction

    // Pulse generators
    // Each task asserts its signal for exactly one clock cycle.


    // Store one character
    task do_store;
        input [4:0] char_idx;
        begin
            switches = char_idx;
            @(posedge clk); #1;
            store = 1;
            @(posedge clk); #1;
            store = 0;
            @(posedge clk); #1;
        end
    endtask


    // Press START button
    task do_start;
        begin
            @(posedge clk); #1;
            start = 1;
            @(posedge clk); #1;
            start = 0;
        end
    endtask


    // Press NEXT button
    task do_next;
        begin
            @(posedge clk); #1;
            next = 1;
            @(posedge clk); #1;  // result_out is updated on this edge
            next = 0;
            // NOTE: we do NOT add a trailing clock here.
            // The caller latches result_out immediately after do_next returns,
            // before any further clock edge can change it.
        end
    endtask

    //  Clear text
    task do_text_reset;
        begin
            @(posedge clk); #1;
            text_reset = 1;
            @(posedge clk); #1;
            text_reset = 0;
            @(posedge clk); #1;
        end
    endtask

    // Wait for cipher engine to finish (timeout = 500 cycles)
    task wait_done;
        integer t;
        begin
            t = 0;
            while (uut.ce.done !== 1'b1 && t < 500) begin
                @(posedge clk);
                t = t + 1;
            end
            if (uut.ce.done !== 1'b1) begin
                $display("  [ERROR] Cipher engine timed out after 500 cycles!");
                $finish;
            end
            @(posedge clk);  // one settle cycle
        end
    endtask

    // Main test
    reg [1023:0] pt_wide;
    reg [1023:0] key_wide;
    integer pt_len;
    integer key_len_v;
    integer i;
    reg [4:0] char_latch;   // holds result_out before do_next mutates it

    initial begin

        // Copy parameters into wide regs for helper-function access
        pt_wide   = PLAINTEXT;
        key_wide  = KEY;
        pt_len    = str_len(pt_wide);
        key_len_v = str_len(key_wide);

        // Validate lengths
        if (pt_len == 0 || pt_len > 16) begin
            $display("[ERROR] PLAINTEXT must be 1-16 uppercase letters.");
            $finish;
        end
        if (key_len_v == 0 || key_len_v > 16) begin
            $display("[ERROR] KEY must be 1-16 uppercase letters.");
            $finish;
        end

        // Initialise signals 
        reset             = 1;
        switches          = 0;
        input_mode_switch = 0;
        mode_switch       = MODE[0];
        store             = 0;
        start             = 0;
        next              = 0;
        text_reset        = 0;

        repeat(4) @(posedge clk);
        reset = 0;
        repeat(2) @(posedge clk);



        // Print inputs
        $write("  Input text  :  ");
        for (i = 0; i < pt_len; i = i + 1)
            $write("%s", to_ascii(get_char(pt_wide, i, pt_len)));
        $write("\n");

        $write("  Key         :  ");
        for (i = 0; i < key_len_v; i = i + 1)
            $write("%s", to_ascii(get_char(key_wide, i, key_len_v)));
        $write("\n");

        if (MODE == 0)
            $display("  Mode        :  ENCRYPT");
        else
            $display("  Mode        :  DECRYPT");
            
        $write("\n");

        // Feed text 
        input_mode_switch = 0;
        for (i = 0; i < pt_len; i = i + 1)
            do_store(get_char(pt_wide, i, pt_len));

        // Feed key 
        input_mode_switch = 1;
        for (i = 0; i < key_len_v; i = i + 1)
            do_store(get_char(key_wide, i, key_len_v));

         // Start cipher
        do_start;
        wait_done;

        // Print raw result
        $write("\n");
        $display("  Done!");
        $display("");
        $write("  Output :  ");
        for (i = 0; i < pt_len; i = i + 1)
            $write("%s", to_ascii(uut.ce.result_flat[i*5 +: 5]));
        $write("\n");

        // Scroll through all characters
        $display("  +-------+-----+--------+");
        $display("  |  Pos  | Val |  Char  |");
        $display("  +-------+-----+--------+");

        
        char_latch = result_out;
        $display("  |  %2d   |  %2d |    %s   |", 1, char_latch, to_ascii(char_latch));

        for (i = 1; i < pt_len; i = i + 1) begin
            do_next;
            char_latch = result_out;
            @(posedge clk); #1;
            $display("  |  %2d   |  %2d |    %s   |",
                     i + 1, char_latch, to_ascii(char_latch));
        end
        $display("  +-------+-----+--------+");
        
        $write("\n");
        // Wrap check
        do_next;
        @(posedge clk); #1;
        if (result_out === 5'b11111)
            $display("  Wrap check   :  PASS - sentinel restored");
        else
            $display("  Wrap check   :  FAIL = %05b", result_out);

        // Final summary 
        $display("");
        if (MODE == 0) begin
            $write("  Plaintext    :  ");
            for (i = 0; i < pt_len; i = i + 1)
                $write("%s", to_ascii(get_char(pt_wide, i, pt_len)));
            $write("\n");

            $write("  Key          :  ");
            for (i = 0; i < key_len_v; i = i + 1)
                $write("%s", to_ascii(get_char(key_wide, i, key_len_v)));
            $write("\n");

            $write("  Ciphertext   :  ");
            for (i = 0; i < pt_len; i = i + 1)
                $write("%s", to_ascii(uut.ce.result_flat[i*5 +: 5]));
            $write("\n");
        end else begin
            $write("  Ciphertext   :  ");
            for (i = 0; i < pt_len; i = i + 1)
                $write("%s", to_ascii(get_char(pt_wide, i, pt_len)));
            $write("\n");

            $write("  Key          :  ");
            for (i = 0; i < key_len_v; i = i + 1)
                $write("%s", to_ascii(get_char(key_wide, i, key_len_v)));
            $write("\n");

            $write("  Plaintext    :  ");
            for (i = 0; i < pt_len; i = i + 1)
                $write("%s", to_ascii(uut.ce.result_flat[i*5 +: 5]));
            $write("\n");
        end
        $write("\n");
        $finish;
    end

endmodule