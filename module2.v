module output_controller #(parameter MAX_LEN = 16)(
input clk,
input reset,
input next,
input done,
input [5*MAX_LEN-1:0] result_flat,
input [4:0] text_len,
output reg [4:0] result_out
);

reg [4:0] index;
reg [4:0] next_index;

always @(*) begin
if (next) begin
if (index <= text_len - 1)
next_index = index + 1;
else
next_index = 0;
end else begin
next_index = index;
end
end


always @(posedge clk) begin
if (reset || !done) begin
index <= 0;
result_out <= 5'b11111;
end else begin
index <= next_index;


if (next_index == text_len)
result_out <= 5'b11111;
else
result_out <= result_flat[next_index*5 +: 5];
end
end

endmodule