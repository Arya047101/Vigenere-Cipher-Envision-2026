module vigenere_core(input [4:0] A, B, input mod, output reg [4:0] C);
wire [4:0] encrypt_answer;
//random comment 
wire [4:0] decrypt_answer;
vignere_cipher a1 (.A(A), .B(B), .C(encrypt_answer));
vignere_decipher a2 (.A(A), .B(B), .C(decrypt_answer));
always @(*) begin
case (mod)
0 : C=encrypt_answer;
1 : C=decrypt_answer;
default : C=00000;
endcase
end
endmodule


module vignere_cipher(input [4:0] A,B, output[4:0] C);
wire [5:0] A_ext = {1'b0,A};
wire [5:0] B_ext = {1'b0,B};
assign C=(A_ext+B_ext)%26;
endmodule

module vignere_decipher(input [4:0] A,B, output[4:0] C);
wire [5:0] A_ext = {1'b0,A};
wire [5:0] B_ext = {1'b0,B};
assign C=(A_ext-B_ext+26)%26;
endmodule