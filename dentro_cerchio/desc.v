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

    reg SOC; assign soc_x = SOC; assign soc_y = SOC;
    reg DAV_; assign dav_ = DAV_;
    reg Z; assign z = Z;

    wire in_area;
    IN_AREA calc (.x(x), .y(y), .z(in_area));

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    always @(reset_ == 0) #1
    begin
        SOC <= 0;
        DAV_ <= 1;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
    S0: begin
        SOC <= 1;
        STAR <= ({eoc_x, eoc_y} == 2'b00) ? S1 : S0;
    end
    S1: begin
        SOC <= 0;
        Z <= in_area;
        STAR <= ({eoc_x, eoc_y} == 2'b11) ? S2 : S1;
    end
    S2: begin
        DAV_ <= 0;
        STAR <= (rfd == 1) ? S3 : S2;
    end
    S3: begin
        DAV_ <= 1;
        STAR <= (rfd == 0) ? S0 : S3;
    end
    endcase

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