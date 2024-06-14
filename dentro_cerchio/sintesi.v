module PO (
    soc_x, eoc_x, x,
    soc_y, eoc_y, y,
    clock, reset_, 
    dav_, rfd, z,
    b4, b3, b2, b1, b0,
    c2, c1, c0
);
    input eoc_x, eoc_y;
    output soc_x, soc_y;
    input[7:0] x, y;

    input clock, reset_;

    input rfd;
    output dav_, z;

    input b4, b3, b2, b1, b0;
    output c2, c1, c0;

    reg SOC; assign soc_x = SOC; assign soc_y = SOC;
    reg DAV_; assign dav_ = DAV_;
    reg Z; assign z = Z;

    wire in_area;
    IN_AREA calc (.x(x), .y(y), .z(in_area));

    assign c0 = ~|{eoc_x, eoc_y};
    assign c1 = eoc_x & eoc_y;
    assign c2 = rfd;

    always @(reset_ == 0) #1 SOC <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b00: SOC <= 1;
        2'b01: SOC <= 0;
        2'b1?: SOC <= SOC;
    endcase

    always @(reset_ == 0) #1 DAV_ <= 1;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b3, b2})
        2'b00: DAV_ <= 0;
        2'b01: DAV_ <= 1;
        2'b1?: DAV_ <= DAV_;
    endcase

    always @(posedge clock) if (reset_ == 1) #3
        Z <= b4 ? in_area : Z;


endmodule

module PC (
    clock, reset_,
    b4, b3, b2, b1, b0,
    c2, c1, c0
);

    input clock, reset_;
    output b4, b3, b2, b1, b0;
    input c2, c1, c0;
    
    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    assign {b4, b3, b2, b1,b0} = 
        (STAR == S0) ?  5'B01X00 :
        (STAR == S1) ?  5'B11X01 :
        (STAR == S2) ?  5'B0001X :
        (STAR == S3) ?  5'B0011X :
        /* default */   5'BXXX1X ;

    always @(reset_ == 0) #1 STAR <= S0;

    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: STAR <= c0 ? S1 : S0;
        S1: STAR <= c1 ? S2 : S1;
        S2: STAR <= c2 ? S3 : S2;
        S3: STAR <= c2 ? S3 : S0;
    endcase

endmodule

module ABC (
    soc_x, eoc_x, x,
    soc_y, eoc_y, y,
    clock, reset_, 
    dav_, rfd, z
);
    input eoc_x, eoc_y;
    output soc_x, soc_y;
    input[7:0] x, y;

    input clock, reset_;

    input rfd;
    output dav_, z;

    wire b4, b3, b2, b1, b0, c2, c1, c0;

    PO po (
        .soc_x(soc_x), .eoc_x(eoc_x), .x(x),
        .soc_y(soc_y), .eoc_y(eoc_y), .y(y),
        .clock(clock), .reset_(reset_), 
        .dav_(dav_), .rfd(rfd), .z(z),
        .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );
    PC pc (
        .clock(clock), .reset_(reset_), 
        .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );
endmodule

module ABS (
    x, abs
);
    input [7:0] x;
    output[7:0] abs;
    wire[7:0] neg;

    add #(.N(8)) adder (
        .x(~x), .y(8'h00), .c_in(1'b1), .s(neg)
    );
    assign abs = (x[7] == 0) ? x : neg;
endmodule

module SQ (
    x, square
);
    input[7:0] x;
    output[15:0] square;

    mul_add_nat #(.N(8), .M(8)) mult (
        .x(x), .y(x), .c(8'h00), .m(square)
    );
endmodule

module IN_AREA (
    x, y, z
);
    input[7:0] x, y;
    output z;

    wire[7:0] abs_x, abs_y;
    ABS a1 (.x(x), .abs(abs_x));
    ABS a2 (.x(y), .abs(abs_y));

    wire[15:0] sq_x, sq_y;
    SQ sq1 (.x(abs_x), .square(sq_x));
    SQ sq2 (.x(abs_y), .square(sq_y));

    wire[15:0] sum;
    add #(.N(16)) adder (.x(sq_x), .y(sq_y), .c_in(1'b0), .s(sum));

    comp_nat #(.N(16)) comp (
        .a(sum), .b(16'D4097), .min(z)
    );

endmodule