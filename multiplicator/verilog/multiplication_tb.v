//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// testbench for multiplication (shift-and-add)
//
//-------------------------------------------------------------------------------

`timescale 1ns / 1ps

module  multiplication_tb;

    parameter   HALF_PERIOD = 20;
    parameter   LENGTH = 32;
    
    reg         clock,
                reset,
                start;
    reg         ready;
    
    reg         [LENGTH-1:0]    SRA;
    reg         [LENGTH-1:0]    SRB, 
                                X, 
                                Y;
    reg         [LENGTH-1:0]    RA;   // D flip-flop
    reg         [4:0]           counter;  //for counting 32 iterations
    reg[32:0] res_add;
    reg[LENGTH-1:0] A, B;
    reg[63:0] P;
    
    wire ld, shld, sh;
    
    
    multiplication
    // testbench multiplication
        multiplication_1(
        .clock(clock),  // master clock
        .reset(reset),  // master reset, synchronous, active high
        .start(start),
        .ready(ready),
        .A(A),
        .B(B),
        .P(P)
        );
    
    
    // Initial reset:
    initial
    begin
        A = 0;
        B = 0;
        start = 1'b0;
        ready = 1'b1;
        reset = 1'b0; //clock = #10 1'b0;
        #3000
            reset = #105 1'b1;
        #1007
            reset <= #100 1'b0;
    end
    
    
    // Generate the master clock:
    always begin
        #9.688 clock = ~clock;
        #9.688 clock = ~clock;
    end
    
    
    / *
    // Verification: register data to transmit and compare to nxt data received:
        always @(negedge send_data)
    begin
        datasent = datatosend;
        @(negedge data_received_ready)
        if (datasent == datareceived)
            $display("Sent = received ( %h )", datasent);
        else
            $display("ERROR: sent %h, received %h", datasent, datareceived);
    end
    * /
    
    // Send one byte to the first USART, wait for the end of transmission:
        task FirstMultiplication;
    //input [7:0] data;
    begin
        #100
            A = 4'hF0F0; //setting the values for multiplication
        B = 4'hFF00;
        @(posedge clock)
            start = 1'b1; // starting multiplication
    
        #5000 // wait some more time...
    
            @(posedge ready)
            start = 1'b0;
    
        @(posedge clock)
            start = 1'b1;
    
    end
    endtask
    
    // generate N clock cycles (not used in current testbench)
        / *
        task DoNClocks;
    input[LENGTH-1:0]nclocks;
    integer i;
    begin
        clock = 0;  // clock is a global signal
        for (i = 0; i < nclocks; i = i + 1)
        begin
            #(HALF_PERIOD)clock = ~clock;
            #(HALF_PERIOD)clock = ~clock;
        end
    end
    endtask * /

endmodule

 