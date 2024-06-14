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

    reg[7:0] X;
    assign x = X;

    reg EOC; assign eoc = EOC;
    reg[15:0] OUT; assign out = OUT;

    wire check_passed;
    CHECK cheker(.x(X), .y(y), .check(check_passed));

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    always @(reset_ == 0) #1 
    begin
        EOC <= 1;
        OUT <= 0;
        X <= 0;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: begin
            EOC <= 1;
            STAR <= (soc == 1) ? S1 : S0;
        end
        S1: begin
            EOC <= 0;
            STAR <= (soc == 0) ? S2 : S1;
        end
        S2: begin
            X <= X + 1;
            STAR <= S3;
        end
        S3: begin
            OUT <= {X, y};
            STAR <= check_passed ? S0 : S2;
        end
    endcase
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