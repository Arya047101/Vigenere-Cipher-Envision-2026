module top_module(
input clk,
input reset,
input [4:0] switches,           // character input (A–Z mapped to 0–25)
input       input_mode_switch,  // 0 = text,    1 = key
input       mode_switch,        // 0 = encrypt, 1 = decrypt
                                //Single-cycle control pulses
input store,                    // store current switch value into text/key buffer
input start,                    // start cipher operation
input next,                     // advance output index by one character
input text_reset,               // clear text buffer (key is preserved)
output [4:0] result_out         // 5-bit character output
);

parameter MAX_LEN = 16;

// Flattened memories
wire [5*MAX_LEN-1:0] text_flat;
wire [5*MAX_LEN-1:0] key_flat;
wire [5*MAX_LEN-1:0] result_flat;
wire [4:0] text_len, key_len;
wire       done;

//Input Controller
input_controller #(MAX_LEN) ic (
.clk              (clk),
.reset            (reset),
.switches         (switches),
.input_mode_switch(input_mode_switch),
.store            (store),
.text_reset       (text_reset),
.text_flat        (text_flat),
.key_flat         (key_flat),
.text_len         (text_len),
.key_len          (key_len)
 );

// Cipher Engine
cipher_engine #(MAX_LEN) ce (
.clk        (clk),
.reset      (reset),
.start      (start),
.mode       (mode_switch),
.text_len   (text_len),
.key_len    (key_len),
.text_flat  (text_flat),
        .key_flat   (key_flat),
        .result_flat(result_flat),
        .done       (done)
    );

// Output Controller
output_controller #(MAX_LEN) oc (
.clk        (clk),
.reset      (reset),
.next       (next),
.done       (done),
.result_flat(result_flat),
.text_len   (text_len),
.result_out (result_out)
 );

endmodule
