module PO (
    soc, eoc, numero,
    clock, reset_,
    out,
    b6, b5, b4, b3, b2, b1, b0,
    c1, c0
);
    output soc;
    input eoc;
    input[7:0] numero;

    input clock, reset_;
    output out;

    reg SOC; assign soc = SOC;
    reg OUT; assign out = OUT;

    reg[7:0] COUNT;
    reg[7:0] NUM;

    input b6, b5, b4, b3, b2, b1, b0;

    always @(reset_ == 0) #1 SOC <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b00: SOC <= 1;
        2'b01: SOC <= 0;
        2'b1X: SOC <= SOC; 
    endcase

    always @(reset_ == 0) #1 OUT <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b3, b2})
        2'b00: OUT <= 1;
        2'b01: OUT <= (COUNT == 1) ? 0 : OUT;
        2'b1X: OUT <= OUT;
    endcase

    always @(reset_ == 0) #1 NUM <= 6;
    always @(posedge clock) if (reset_ == 1) #3
    casex (b4)
        1'b1: NUM <= (eoc == 1) ? numero : NUM;
        1'b0: NUM <= NUM;
    endcase
    
    always @(reset_ == 0) #1 COUNT <= 5;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b6, b5})
        2'b00: COUNT <= COUNT - 1;
        2'b01: COUNT <= NUM;
        2'b10: COUNT <= (COUNT == 1) ? (NUM - 1) : COUNT - 1;
        2'b11: COUNT <= COUNT;
    endcase

    output c0, c1;
    assign c0 = COUNT[0] & ~|{COUNT[7:1]};
    assign c1 = ~eoc;
endmodule

module PC (
    clock, reset_,
    b6, b5, b4, b3, b2, b1, b0,
    c1, c0
);
    input clock, reset_;
    input c0, c1;
    output b6, b5, b4, b3, b2, b1, b0;
    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    assign {b6, b5, b4, b3, b2, b1, b0} = 
                (STAR == S0) ? 'b0001X1X :
                (STAR == S1) ? 'b010001X :
                (STAR == S2) ? 'b0001X00 :
                (STAR == S3) ? 'b1010101 :
                                'bxxxxxxx;

    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: STAR <= c0 ? S1 : S0;
        S1: STAR <= S2;
        S2: STAR <= c1 ? S3 : S2;
        S3: STAR <= c0 ? S0 : S3;
    endcase
endmodule

module XXX (
    soc, eoc, numero,
    clock, reset_,
    out
);
    output soc;
    input eoc;
    input[7:0] numero;

    input clock, reset_;
    output out;
    wire b6, b5, b4, b3, b2, b1, b0;
    wire c1, c0;

    PO po (
        .soc(soc), .eoc(eoc), .numero(numero),
        .clock(clock), .reset_(reset_),
        .out(out),
        .b6(b6), .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c1(c1), .c0(c0)
    );
    PC pc (
        .clock(clock), .reset_(reset_),
        .b6(b6), .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c1(c1), .c0(c0)
    );
endmodule