//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// testbench for multiplication (shift-and-add)
//  Damir Valput
//  Ricardo Lopes
//-------------------------------------------------------------------------------
`timescale 1ns / 1ps

module  multiplication_tb;

    reg         clock,
                reset,
                start;
            
    wire        ready;  //OUTPUTS FROM THE DUT (Device-Under-Test) are WIRES!!!!
    
    
    reg [31:0]  A,
                B;
    wire[63:0]  P;
    
    
    
    // testbench multiplication
    multiplication  multiplication_1(
                                      .clock(clock),  // master clock
                                      .reset(reset),  // master reset, synchronous, active high
                                      .start(start),
                                      .ready(ready),
                                      .A(A),
                                      .B(B),
                                      .P(P)
                                     );
                        
    
    // Initial reset:
    initial begin
        $dumpfile("tbench.vcd");
        $dumpvars(0,multiplication_tb);
        $monitor("clock=%b, reset=%b, A=%b, B=%b, P=%b",
                  clock, reset, A, B, P);
        A     = 0;
        B     = 0;
        start = 1'b0;
        reset = 1'b0;
        clock = 1'b0;
    
        @(posedge clock);
            reset = 1'b1;
            #0.2 reset = 1'b0;
            
        @(posedge clock);
            A = 32'h0000AABC; //setting the values for multiplication
            B = 32'h00AABBCC;
            start = 1'b1; // starting multiplication
            
        @(posedge clock);   //returning start signal to zero after 1 clock-cycle
            start = 1'b0;
        
        @(posedge ready);
            begin
                if (P == (A * B))
                    $display(" Correct result: Found: %d is equal to expected: %d ", P, A * B);
                else 
                    $display(" Wrong result: expected %d, found:%d", A * B, P);
                
                
                $finish;
            end
    end
    
    
    
     //clock genetator
        always begin
          #2 clock = !clock;
        end
    
endmodule



 
