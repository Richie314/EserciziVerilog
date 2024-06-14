module PO (
    x1, x2, x3, x4,
    eoc1, eoc2, eoc3, eoc4,
    soc,
    clock, reset_,
    dav_, rfd, avg,
    b4, b3, b2, b1, b0,
    c2, c1, c0
);

    input clock, reset_;

    input[7:0] x1, x2, x3, x4;
    input eoc1, eoc2, eoc3, eoc4;
    output soc;

    output dav_;
    input rfd;

    output[7:0] avg;

    reg SOC; assign soc = SOC;
    reg DAV_; assign dav_ = DAV_;
    reg[7:0] AVG; assign avg = AVG;

    wire[7:0] m;
    MEDIA4 media (.x(x1), .y(x2), .z(x3), .k(x4), .m(m));

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    input b4, b3, b2, b1, b0;        

    always @(reset_ == 0) #1 SOC = 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b00: SOC <= 1;
        2'b01: SOC <= 0;
        2'b1X: SOC <= SOC;
    endcase

    always @(reset_ == 0) #1 DAV_ = 1;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b3, b2})
        2'b00: DAV_ <= 0;
        2'b01: DAV_ <= 1;
        2'b1X: DAV_ <= DAV_;
    endcase

    always @(reset_ == 0) #1 AVG = 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (b4)
        1'b1: AVG <= m;
        1'b0: AVG <= AVG;
    endcase

    output c0, c1, c2;
    assign c0 = ~|{eoc1, eoc2, eoc3, eoc4};
    assign c1 = &{eoc1, eoc2, eoc3, eoc4};
    assign c2 = rfd;
endmodule

module PC (
    clock, reset_,
    b4, b3, b2, b1, b0,
    c2, c1, c0
);

    input clock, reset_;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    output b4, b3, b2, b1, b0;

    assign {b4, b3, b2, b1, b0} =
        (STAR == S0) ? 5'b01X00 :
        (STAR == S1) ? 5'b11X01 :
        (STAR == S2) ? 5'b0001X :
        (STAR == S3) ? 5'b0011X :
                       5'bXXXXX;

    input c0, c1, c2;

    always @(reset_ == 0) #1 STAR = S0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: STAR <= c0 ? S1 : S0;
        S1: STAR <= c1 ? S2 : S1;
        S2: STAR <= c2 ? S3 : S0;
        S3: STAR <= c2 ? S3 : S0;
    endcase
endmodule

module ABC (
    x1, x2, x3, x4,
    eoc1, eoc2, eoc3, eoc4,
    soc,
    clock, reset_,
    dav_, rfd, avg
);

    input clock, reset_;

    input[7:0] x1, x2, x3, x4;
    input eoc1, eoc2, eoc3, eoc4;
    output soc;

    output dav_;
    input rfd;

    output[7:0] avg;

    wire b4, b3, b2, b1, b0;
    wire c0, c1, c2;

    PO po (
        .x1(x1),.x2(x2), .x3(x3), .x4(x4),
        .eoc1(eoc1), .eoc2(eoc2), .eoc3(eoc3), .eoc4(eoc4),
        .soc(soc),
        .clock(clock), .reset_(reset_),
        .dav_(dav_), .rfd(rfd),
        .avg(avg),
        .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );

    PC pc (
        .clock(clock), .reset_(reset_),
        .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );
endmodule

module MEDIA4 (
    x, y, z, k, m
);
    input[7:0] x, y, z, k;
    output[7:0] m;

    wire[8:0] x_y;
    add #(.N(8)) add1 (.x(x), .y(y), .c_out(x_y[8]), .s(x_y[7:0]), .c_in(1'b0));

    wire[8:0] z_k;
    add #(.N(8)) add2 (.x(z), .y(k), .c_out(z_k[8]), .s(z_k[7:0]), .c_in(1'b0));

    wire[9:0] x_y_z_k;
    add #(.N(9)) add3 (.x(x_y), .y(z_k), .c_out(x_y_z_k[9]), .s(x_y_z_k[8:0]), .c_in(1'b0));

    assign m = x_y_z_k[9:2];
endmodule