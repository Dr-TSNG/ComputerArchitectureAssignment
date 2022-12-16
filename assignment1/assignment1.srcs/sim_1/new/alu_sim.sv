`timescale 1ns / 1ps

module alu_sim;
	reg [31:0] A;
	reg [31:0] B;
	reg Cin;
	reg [4:0] Card;

	wire [31:0] F;
	wire Cout;
	wire Zero;

	alu alu(
		.A(A), 
		.B(B), 
		.Cin(Cin),
		.Card(Card), 
		
		.F(F), 
		.Cout(Cout), 
		.Zero(Zero)
	);

	initial begin
		A = -3;
		B = -5;
		Cin = 1;
		Card = 5'b00001;
		#10;
	end
	
	always #1 begin
		Cin = !Cin;
	end

	always #2 begin
		A = A + 1;
		B = B + 1;
		Card = (Card + 1) % 16 == 0 ? 16 : (Card + 1) % 16;
	end
endmodule
