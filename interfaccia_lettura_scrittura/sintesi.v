module PO (
    addr, data, ior_, iow_, clock, reset_,
    b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0,
    c0
);
    output[15:0] addr;
    inout[7:0] data;
    output ior_, iow_;

    input clock, reset_;

    input b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0;
    output c0;

    reg[15:0] ADDR; assign addr = ADDR;
    reg[7:0] DATA_OUT;
    reg DIR; assign data = (DIR == 1) ? DATA_OUT : 8'hzz;

    reg IOR_, IOW_;
    assign ior_ = IOR_;
    assign iow_ = IOW_;

    reg[7:0] X;

    wire[7:0] mh, ml;
    MUL5 m (.x(X), .y({mh, ml}));


    assign c0 = data[0];

    always @(reset_ == 0) #1 DIR <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b00: DIR <= 0;
        2'b01: DIR <= 1;
        2'b1X: DIR <= DIR;
    endcase

    always @(reset_ == 0) #1 IOR_ <= 1;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b3, b2})
        2'b00: IOR_ <= 0;
        2'b01: IOR_ <= 1;
        2'b1X: IOR_ <= IOR_;
    endcase

    always @(reset_ == 0) #1 IOW_ <= 1;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b5, b4})
        2'b00: IOW_ <= 0;
        2'b01: IOW_ <= 1;
        2'b10: IOW_ <= IOW_;
    endcase

    always @(posedge clock) if (reset_ == 1) #3
    casex ({b7, b6})
        2'b00: ADDR <= 16'h0100;
        2'b01: ADDR <= 16'h0101;
        2'b10: ADDR <= 16'h0121;
        2'b11: ADDR <= ADDR;
    endcase

    always @(posedge clock) if (reset_ == 1) #3
        X <= b8 ? data : X;

    always @(posedge clock) if (reset_ == 1) #3
    casex ({b10, b9})
        2'b00: DATA_OUT <= mh;
        2'b01: DATA_OUT <= ml;
        2'b1X: DATA_OUT <= DATA_OUT;
    endcase
endmodule

module PC (
    clock, reset_,
    b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0,
    c0
);
    input clock, reset_;
    output b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0;
    input c0;

    reg[3:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6,
            S7 = 7, S8 = 8, S9 = 9, S10 = 10, S11 = 11;

    // Too lazy to assign them one by one as it should be done
    assign {b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0} =
        (STAR == S0)  ? 'B1X0001X1X00 :
        (STAR == S1)  ? 'B1X0111X001X :
        (STAR == S2)  ? 'B1X0111X011X :
        (STAR == S3)  ? 'B1X0011X1X1X :
        (STAR == S4)  ? 'B1X0111X001X :
        (STAR == S5)  ? 'B1X1111X011X :
        (STAR == S6)  ? 'B000101X1X01 :
        (STAR == S7)  ? 'B1X011001X1X :
        (STAR == S8)  ? 'B1X011011X1X :
        (STAR == S9)  ? 'B010111X1X1X :
        (STAR == S10) ? 'B1X011001X1X :
        (STAR == S11) ? 'B1X011011X1X :
                        'BXXXXXXXXXXX;

    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: STAR <= S1;
        S1: STAR <= S2;
        S2: STAR <= c0 ? S3 : S0;
        S3: STAR <= S4;
        S4: STAR <= S5;
        S5: STAR <= S6;
        S6: STAR <= S7;
        S7: STAR <= S8;
        S8: STAR <= S9;
        S9: STAR <= S10;
        S10: STAR <= S11;
        S11: STAR <= S0;
    endcase

    /*
    uAddr   b10_0        cEff  uAddrT   uAddrF
        S0  1X0001X1X00   X     S1       S1
        S1  1X0111X001X   X     S2       S2
        S2  1X0111X011X   0     S3       S0
        S3  1X0011X1X1X   X     S4       S4
        S4  1X0111X001X   X     S5       S5
        S5  1X1111X011X   X     S6       S6
        S6  000101X1X01   X     S7       S7
        S7  1X011001X1X   X     S8       S8
        S8  1X011011X1X   X     S9       S9
        S9  010111X1X1X   X     S10      S10
        S10 1X011001X1X   X     S11      S11
        S11 1X011011X1X   X     S0       S0
    */
endmodule

module ABC (
    addr, data, ior_, iow_, clock, reset_
);
    output[15:0] addr;
    inout[7:0] data;
    output ior_, iow_;

    input clock, reset_;

    wire b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0;
    wire c0;
    PO po (
        .addr(addr), .data(data), .ior_(ior_), .iow_(iow_), .clock(clock), .reset_(reset_),
        .b10(b10), .b9(b9), .b8(b8), .b7(b7), .b6(b6), .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c0(c0)
    );
    PC pc (
        .clock(clock), .reset_(reset_),
        .b10(b10), .b9(b9), .b8(b8), .b7(b7), .b6(b6), .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c0(c0)
    );
endmodule

module MUL5 (
    x, y
);
    input [7:0] x;
    output[15:0] y;
    
    add #(.N(16)) adder (
        .x({6'b00, x, 2'b00}), .y({8'h00, x}), .s(y), .c_in(1'b0)
    );

endmodule