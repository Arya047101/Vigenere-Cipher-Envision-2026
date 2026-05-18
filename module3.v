module input_controller#(parameter MAX_LEN=16)( 
input clk, //InputClock
input reset, //SynchronousReset
input [4:0] switches, //5-bit Input fromSwitches
input input_mode_switch, // if0==plaintext,1==key
input store, //Pulsesignal to store the character
input text_reset, //Clear Plain text and Length
output reg[5*MAX_LEN-1:0] text_flat, //PlainText
output reg[5*MAX_LEN-1:0]key_flat, //Key
output reg[4:0] text_len, //PlainTextLength
output reg[4:0] key_len //KeyLength
); 
//Declareregistersneeded
wire [4:0] w1,w2,w3;
always@(posedge clk)begin

if(reset)begin
text_flat <= 0;
key_flat <= 0;
text_len <= 0;
key_len <= 0;

end
else if(text_reset)begin 
text_flat<=0;
text_len <= 0;
end

else if(store)begin
if (input_mode_switch == 1'b0 && text_len < MAX_LEN) begin
text_flat[text_len*5 +: 5] <= switches;
text_len <= text_len + 1;
end 
else if (input_mode_switch == 1'b1 && key_len < MAX_LEN) begin
key_flat[key_len*5 +: 5] <= switches;
key_len <= key_len + 1;
end
end
end
endmodule
