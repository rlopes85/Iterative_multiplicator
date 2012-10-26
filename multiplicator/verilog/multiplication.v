//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  Simple usart with fixed configuration (1 start bit, 8 data bits, 1 stop bit, no parity)
//  baudrate is user defined (see configuration section below)
//
//  jca@fe.up.pt,  Dec 2007
//
//-------------------------------------------------------------------------------

	`timescale 1ns / 1ps

module multiplication(
						clock,  // master clock
						reset,  // master reset, synchronous, active high
						start,  // start bit
						ready,  //
						A,	//first operand
						B, 	//second operand
						P	//result
						);

	input        clock, reset, start;
	output       ready;
	reg ready;
	reg[32:0] SRA;
	reg[31:0] SRB, X;
	wire[31:0] Y;
	reg[31:0] RA;	// D flip-flop
	reg[4:0] counter;	//for counting 32 iterations
	wire[32:0] res_add;
	input[31:0]A, B;
	output[63:0]P;
	
	reg ld, shld, sh;

	parameter[3:0]
		s1 = 4'b0001,
		s2 = 4'b0010,
		s3 = 4'b0100,
		s4 = 4'b1000;
	reg[3:0] state;
	
	
	//D flip-flop
	always @(posedge clock or posedge reset)
	begin
		if (reset)
		begin
			RA <= 0;
		end
		else if (ld)
		begin
			RA <= A;
		end
	end
	
	//AND circuit
	assign Y = SRB[0] ? RA : 0;
	
	//adder
	assign res_add = Y + X;
	
	//shift-register A
	always @(posedge clock or posedge reset)
	begin
		if (reset)
		begin
			SRA <= 0;
		end
	
		else if (start & ready & ld)
		begin
			SRA <= 0;
		end
	
		else if (shld & start & ~ready)
		begin
			SRA <= res_add;
			SRA <= SRA >> 1;
		end
	
	end
	
	//shift-register B
	always @(posedge clock or posedge reset)
	begin
		if (reset)
		begin
			SRB <= 0;
		end
	
		else if (start & ready & ld)
		begin
			SRB <= B;
		end
	
		else if (sh & start & ~ready)
		begin
			SRB <= SRB >> 1;
			SRB[31] <= SRA[0];
			counter = counter - 1;
		end
	end
	
	//FSM
	initial begin
		state = s1;
		ready = 1'b1; //in the beginning ready should be 1
	end
	
	
	
	
	always @(posedge clock or posedge reset)
	begin
		if (reset)
		begin
			state <= s1;
			ready <= 1'b1;
		end
		else
		begin
	
			case(state)
	
				s1: begin
					if (start == 1'b1)
					begin
						state <= s2;
					end
				end
	
				s2: begin
					if (ready == 1'b1)
					begin
						state <= s3;
						ready = 1'b0;
						counter = 32;
						ld = 1'b1;
					end
				end
	
				s3: begin
					if (counter == 0)
					begin
						state <= s4;
						ld = 1'b0;
						sh = 1'b0;
						shld = 1'b0;
						ready = 1'b1;
					end
					else
					begin
						sh = 1'b1;
						shld = 1'b1;
					end
	
				end
	
				s4: begin
					if (start == 1'b0)
					begin
						state <= s1;
					end
	
				end
	
			endcase
		end
	
	end


endmodule

