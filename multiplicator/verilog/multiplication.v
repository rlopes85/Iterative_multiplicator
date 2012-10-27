//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  Shift-and-add multiplier
//
//  First practical project - Digital Systems Design
//  Damir and Ricardo
//-------------------------------------------------------------------------------

    `timescale 1ns / 1ps

module multiplication(
                      clock,  // master clock
                      reset,  // master reset, synchronous, active high
                      start,  // start bit
                      ready,  //signifies beginning of multiplication
                      A,      //first operand
                      B,      //second operand
                      P       //result
                     );
    
    //inputs
    input           clock,
                    reset,
                    start;
    
    input   [31:0]  A,
                    B;
    
    //outputs
    output          ready;
    
    output  [63:0]  P;
    
    //registers
    reg             ready;
    reg             ld,
                    shld,
                    sh;
    
    reg     [32:0]  SRA;
    reg     [31:0]  SRB;
    reg     [31:0]  RA;           // D flip-flop
    reg     [5:0]   counter;     //for counting 32 iterations
    
    //wires
    wire            lsb_A,
                    lsb_B; //LSB of each shift-register, has to be wire for assign
    
    wire    [32:0]  res_add;
    wire    [31:0]  Y;    
    
    parameter   [2:0]
                    s1 = 3'b001,
                    s2 = 3'b010,
                    s3 = 3'b100;
                    //s4 = 4'b1000;
    reg     [2:0]   state;
    
    
    //D flip-flop
    always @(posedge clock) //synchronous reset, don't put it in sensitivity list!
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
    
    //wires of LSB
    assign lsb_A = SRA[0];    //WIRE!!!
    assign lsb_B = SRB[0];
    
    //AND circuit
    assign Y = lsb_B ? RA : 0;
   
    //adder
    assign res_add = Y + SRA;
    
    //output
    assign P[31:0] = SRB;
    assign P[63:32] = SRA[31:0];
    
    //shift-register A
    always @(posedge clock)
        begin
            if (reset)
                begin
                    SRA <= 0;
                end
            else if (ld)  //begin multiplication, loading 0 to SRA
                begin
                    SRA <= 0;
                end
            else if (shld)
                begin
                    SRA <= res_add >> 1; //load the previous result
                    //SRA <= SRA >> 1;  //then shift it one place to the right
                end
        end
    
    //shift-register B
    always @(posedge clock)
        begin
            if (reset)
                begin
                    SRB <= 0;
                end
            else if (ld)  //state S2
                begin
                    SRB <= B;
                end
            else if (sh) //state S3
                begin
                    SRB <= SRB >> 1;
                    SRB[31] <= lsb_A;
                end
        end
    
    //FSM
    initial begin
        state = s1;
        ready = 1'b1; //in the beginning ready should be 1
    end
    
    
    always @(posedge clock)
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
                                if (start == 1'b1) //start is 0, wait for it to become 1, ready is 1
                                    begin
                                        state <= s2;
                                        counter <= 6'b100000;
                                    end
                            end
            
                        s2: begin        //start is 1, ready is 1, beginning of multiplication - putting ready to 0
                                if (ready == 1'b1)
                                    begin
                                        state <= s3;
                                        ready <= 1'b0;
                                        ld <= 1'b1;
                                        //counter <= 6'b100000;
                                    end
                            end
            
                        s3: begin
                                if (counter == 0)  //multiplication is finished, have to put ready to 1 again and go to initial state waiting for the start
                                    begin
                                        state <= s1;
                                        ld <= 1'b0;   // all control signals back to 0
                                        sh <= 1'b0;
                                        shld <= 1'b0;
                                        ready <= 1'b1;
                                    end
                                else
                                    begin        //counter is not zero - multiplication in process
                                        ld <= 1'b0;
                                        sh <= 1'b1;
                                        shld <= 1'b1;
                                        counter <= counter - 1;
                                    end
                            end
                    endcase
                end
        end
endmodule

