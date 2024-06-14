module PO (
    clock, reset_,
    rfdA, rfdB,
    davA_, davB_,
    dataA, dataB,
    out,
    b2, b1, b0,
    c2, c1, c0
);
    input clock, reset_;

    input davA_, davB_;
    input [7:0] dataA, dataB;

    output rfdA, rfdB;
    reg RFD; assign rfdA = RFD; assign rfdB = RFD;

    output out;
    reg OUT; assign out = OUT;

    wire[3:0] comp_out;
    COMP comp (.a(dataA), .b(dataB), .count(comp_out));

    reg[3:0] WAIT;
    input b2, b1, b0;
    output c2, c1, c0;

    always @(reset_ == 0) #1 RFD <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b01: RFD <= 1;
        2'b10: RFD <= 0;
        default: RFD <= RFD;
    endcase

    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b01: WAIT <= comp_out;
        2'b10: WAIT <= WAIT - 1;
        default: WAIT <= WAIT;
    endcase

    always @(reset_ == 0) #1 OUT <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b2, b1})
        2'b01: OUT <= 1;
        2'b10: OUT <= 0;
        default: OUT <= OUT;
    endcase
    
    assign c0 = ~|{davA_, davB_};
    //assign c1 = (WAIT == 1) ? 1 : 0;
    assign c1 = WAIT[0] & ~|{WAIT[3:1]};
    assign c2 = &{davA_, davB_};
endmodule

module PC (
    clock, reset_,
    b2, b1, b0,
    c2, c1, c0
);
    input clock, reset_;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2;

    output b2, b1, b0;
    input c2, c1, c0;

    //assign b0 = (STAR == S0) ? 1 : 0;
    assign b0 = ~|{STAR};
    //assign b1 = (STAR == S1) ? 1 : 0;
    assign b1 = ~STAR[1] & STAR[0];
    //assign b2 = (STAR == S2) ? 1 : 0;
    assign b2 = STAR[1] & ~STAR[0];
    
    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: STAR <= (c0 == 1) ? S1 : S0;
        S1: STAR <= (c1 == 1) ? S2 : S1;
        S2: STAR <= (c2 == 1) ? S0 : S2;
    endcase

    /*
    uAddr      | b2 b1 b0   |  cEff,  |  uAddrT   | uAddrF
    S0 (00)    |  0  0  1   |    0    |    S1     |   S0
    S1 (01)    |  0  1  0   |    1    |    S2     |   S1
    S2 (10)    |  1  0  0   |    2    |    S0     |   S2
    */
endmodule

module ABC (
    clock, reset_,
    rfdA, rfdB,
    davA_, davB_,
    dataA, dataB,
    out
);
    input clock, reset_;

    input davA_, davB_;
    input [7:0] dataA, dataB;

    output rfdA, rfdB;
    output out;

    wire b2, b1, b0, c2, c1, c0;

    PO po(
        .clock(clock), .reset_(reset_),
        .rfdA(rfdA), .rfdB(rfdB),
        .davA_(davA_), .davB_(davB_),
        .dataA(dataA), .dataB(dataB),
        .out(out),
        .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );

    PC pc (
        .clock(clock), .reset_(reset_),
        .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );

endmodule

module COMP (
    a, b, count
);
    input [7:0] a, b;
    output [3:0] count;
    wire c_out;
    add #(.N(8)) adder (
        .x(b), .y(~a), .c_in(1'b1), 
        .c_out(c_out)
    );

    //assign count = (c_out == 0) ? 4'b0110 : 4'b1100;
    assign count = {c_out, 1'b1, ~c_out, 1'b0};
endmodule