module cipher_engine #(parameter MAX_LEN = 16)(
input clk,
input reset,
input start,                // single-cycle pulse
input mode,                 // 0 = encrypt, 1 = decrypt
input [4:0] text_len,
input [4:0] key_len,
input [5*MAX_LEN-1:0] text_flat,
input [5*MAX_LEN-1:0] key_flat,
output reg [5*MAX_LEN-1:0] result_flat,
output reg done
);

reg [4:0] index;
reg [4:0] key_index; 
reg running;
    

wire [4:0] text_char;
wire [4:0] key_char;
wire [4:0] out_char;


assign text_char = text_flat[index*5 +: 5];
assign key_char = key_flat[key_index*5 +: 5];


vigenere_core core (
.A(text_char),
.B(key_char),
.mod(mode),
.C(out_char)
 );

always @(posedge clk) begin
if (reset) begin
result_flat <= 0;
done        <= 0;
index       <= 0;
key_index   <= 0;
running     <= 0;
end else begin
            
if (start && !running) begin
result_flat <= 0;
index       <= 0;
key_index   <= 0;
done        <= 0;
running     <= 1;
end else if (running) begin


if (index < text_len) begin
//ignored
$display("index=%0d key_index=%0d text_char=%0d key_char=%0d out_char=%0d",
index, key_index, text_char, key_char, out_char);
                    
result_flat[5*index +: 5] <= out_char;

if (key_index >= key_len - 1)
key_index <= 0;
else
key_index <= key_index + 1;

index <= index + 1;
                    
end else begin
running <= 0;
done    <= 1;
end
end
end
end

endmodule