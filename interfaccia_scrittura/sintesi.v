module PO (
    soc, eoc, x, ok,
    clock, reset_,
    addr, data, ior_, iow_,
    b0, b1, b2, b3, b4, b5, b6, b7,
    c0, c1, c2
);
    output soc;
    input eoc;

    output[7:0] x;
    input ok;

    input clock, reset_;

    output [15:0] addr;
    inout [7:0] data;

    output ior_, iow_;

    reg SOC;
    assign soc = SOC;

    reg[15:0] ADDR;
    assign addr = ADDR;

    reg[7:0] DATA_OUT;
    reg DIR;
    assign data = (DIR == 1) ? DATA_OUT : 'hzz;
    assign x = DATA_OUT;

    reg IOR_, IOW_;
    assign ior_ = IOR_;
    assign iow_ = IOW_;

    input b0, b1, b2, b3, b4, b5, b6, b7;
    output c0, c1, c2;

    assign c0 = eoc;
    assign c1 = ok;
    assign c2 = data[5];

    always @(reset_ == 0) #1 IOR_ <= 1;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b4, b3})
        2'b01: IOR_ <= 0;
        2'b10: IOR_ <= 1;
        default: IOR_ <= IOR_;
    endcase

    always @(reset_ == 0) #1 IOW_ <= 1;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b7, b6})
        2'b01: IOW_ <= 0;
        2'b10: IOW_ <= 1;
        default: IOW_ <= IOW_;
    endcase

    always @(reset_ == 0) #1 SOC <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b01: SOC <= 1;
        2'b10: SOC <= 0;
        default: SOC <= SOC;
    endcase

    always @(reset_ == 0) #1 DATA_OUT <= 0;
    always @(posedge clock) if (reset_ == 1) #3
        DATA_OUT <= (~ok & b2) ? DATA_OUT + 1: DATA_OUT;


    always @(reset_ == 0) #1 ADDR <= 'h0ABC;
    always @(posedge clock) if (reset_ == 1) #3
        ADDR <= (b5 == 1) ? 'h0ABD : ADDR;

    always @(reset_ == 0) #1 DIR <= 0;
    always @(posedge clock) if (reset_ == 1) #3
        DIR <= (b5 == 1) ? 1 : DIR;

endmodule

module PC (
    clock, reset_,
    b0, b1, b2, b3, b4, b5, b6, b7,
    c0, c1, c2
);
    input clock, reset_;

    reg[2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7;

    output b0, b1, b2, b3, b4, b5, b6, b7;
    input c0, c1, c2;
    
    /*
    assign b0 = (STAR == S0) ? 1 : 0;
    assign b1 = (STAR == S1) ? 1 : 0;
    assign b2 = (STAR == S2) ? 1 : 0;
    assign b3 = (STAR == S3) ? 1 : 0;
    assign b4 = (STAR == S4) ? 1 : 0;
    assign b5 = (STAR == S5) ? 1 : 0;
    assign b6 = (STAR == S6) ? 1 : 0;
    assign b7 = (STAR == S7) ? 1 : 0;
    */

    assign {b7, b6, b5, b4, b3, b2, b1, b0} = 
        (STAR == S0) ?  8'B00000001 :
        (STAR == S1) ?  8'B00000010 :
        (STAR == S2) ?  8'B00000100 :
        (STAR == S3) ?  8'B00001000 :
        (STAR == S4) ?  8'B00010000 :
        (STAR == S5) ?  8'B00100000 :
        (STAR == S6) ?  8'B01000000 :
        (STAR == S7) ?  8'B10000000 :
        /* default */   8'BXXXXXXXX ;

    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: STAR <= (c0 == 0) ? S1 : S0;
        S1: STAR <= (c0 == 1) ? S2 : S1;
        S2: STAR <= (c1 == 1) ? S3 : S0;
        S3: STAR <= S4;
        S4: STAR <= (c2 == 1) ? S5 : S3;
        S5: STAR <= S6;
        S6: STAR <= S7;
        S7: STAR <= S7;
    endcase
    /*
    Struttura della ROM
        uAddr  | b7 ... b0   |   cEff   |  uAddrT   | uAddrF
    ------------------------------------------------------------
        S0       00000001        0          S0         S1
        S1       00000010        0          S2         S2
        S2       00000100        1          S3         S0
        S3       00001000        X          S4         S4
        S4       00010000        2          S5         S3
        S5       00100000        X          S6         S6
        S6       01000000        X          S7         S7
        S7       10000000        X          S7         S7
    */

endmodule

module ABC (
    soc, eoc, x, ok,
    clock, reset_,
    addr, data, ior_, iow_
);
    output soc;
    input eoc;

    output[7:0] x;
    input ok;

    input clock, reset_;

    output [15:0] addr;
    inout [7:0] data;

    output ior_, iow_;

    wire b0, b1, b2, b3, b4, b5, b6, b7;
    wire c0, c1, c2;

    PO po (
        .soc(soc), .eoc(eoc), .x(x), .ok(ok),
        .clock(clock), .reset_(reset_),
        .addr(addr), .data(data), .ior_(ior_), .iow_(iow_),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3), .b4(b4), .b5(b5), .b6(b6), .b7(b7),
        .c0(c0), .c1(c1), .c2(c2)
    );

    PC pc (
        .clock(clock), .reset_(reset_),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3), .b4(b4), .b5(b5), .b6(b6), .b7(b7),
        .c0(c0), .c1(c1), .c2(c2)
    );

endmodule