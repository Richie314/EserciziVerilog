module PO (
    x, y,
    clock, reset_,
    soc, eoc,
    out,
    b3, b2, b1, b0,
    c1, c0
);
    output[7:0] x;
    input[7:0] y;
    input clock, reset_;
    input soc;
    output eoc;
    output[15:0] out;

    reg[7:0] X;
    assign x = X;

    reg EOC; assign eoc = EOC;
    reg[15:0] OUT; assign out = OUT;

    wire check_passed;
    CHECK cheker(.x(X), .y(y), .check(check_passed));

    input b3, b2, b1, b0;
    output c1, c0;


    always @(reset_ == 0) #1  EOC <= 1;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b00: EOC <= 1;
        2'b01: EOC <= 0;
        2'b1?: EOC <= EOC;
    endcase

    always @(reset_ == 0) #1  OUT <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (b2)
        1'b0: OUT <= OUT;
        1'b1: OUT <= x_and_y;
    endcase

    always @(reset_ == 0) #1  X <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (b3)
        1'b0: X <= X;
        1'b1: X <= X + 1;
    endcase
    wire[15:0] x_and_y; assign x_and_y = {X, y};

    assign c0 = soc;
    assign c1 = check_passed;
endmodule

module PC (
    clock, reset_,
    b3, b2, b1, b0,
    c1, c0
);
    output[7:0] x;
    input[7:0] y;
    input clock, reset_;
    input soc;
    output eoc;
    output[15:0] out;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    output b3, b2, b1, b0;
    input c1, c0;

    assign {b3, b2, b1, b0} = 
        (STAR == S0) ? 'b0000 : 
        (STAR == S1) ? 'b0001 : 
        (STAR == S2) ? 'b101X : 
        (STAR == S3) ? 'b011X : 
                        'bXXXX; 

    always @(reset_ == 0) #1  STAR <= S0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: STAR <= c0 ? S1 : S0;
        S1: STAR <= c0 ? S1 : S2;
        S2: STAR <= S3;
        S3: STAR <= c1 ? S0 : S2;
    endcase
    /*
    uAddr   b3_0  cEff  uAddrT   uAddrF
      S0    0000    0    S1        S0
      S1    0001    0    S1        S2
      S2    101X    X    S3        S3
      S3    011X    1    S0        S2
    */
endmodule
module ABC (
    x, y,
    clock, reset_,
    soc, eoc,
    out
);
    output[7:0] x;
    input[7:0] y;
    input clock, reset_;
    input soc;
    output eoc;
    output[15:0] out;

    wire b3, b2, b1, b0;
    wire c1, c0;
    
    PO po (
        .x(x), .y(y), .clock(clock), .reset_(reset_),
        .soc(soc), .eoc(eoc),
        .out(out),
        .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c1(c1), .c0(c0)
    );
    PC pc (
        .clock(clock), .reset_(reset_),
        .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c1(c1), .c0(c0)
    );
endmodule

module CHECK (
    x, y, check
);
    input[7:0] x, y;
    output check;
    wire[15:0] xy;
    wire min, eq;

    mul_add_nat #(.N(8), .M(8)) m (
        .x(x), .y(y), .c(8'h00),
        .m(xy)
    );

    comp_nat #(.N(16)) comp (
        .a(16'hABBA), .b(xy), .min(min), .eq(eq)
    );

    assign check = min | eq;
endmodule