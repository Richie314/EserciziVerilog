module PO (
    rxd, ref, led, 
    clock, reset_,
    b5, b4, b3, b2, b1, b0,
    c2, c1, c0
);
    input rxd, clock, reset_;
    input[4:0] ref;
    output[2:0] led;
    input b5, b4, b3, b2, b1, b0;
    output c2, c1, c0;

    reg[2:0] LED; assign led = LED;
    reg[7:0] BYTE; // coda dei bit in entrata
    reg[3:0] BIT_READ; // numero dei bit letti
    reg[3:0] COUNT; // contatore dei cicli passati con rxd=spacing

    always @(reset_ == 0) #1 LED <= 3'b000;
    always @(posedge clock) if (reset_ == 1) #3
        LED <= (BYTE[7:3] == ref && b0 == 1) ? BYTE[2:0] : LED;

    always @(reset_ == 0) #1 COUNT <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex({b2, b1})
        2'b00: COUNT <= 0;
        2'b01: COUNT <= COUNT + 1;
        2'b1?: COUNT <= COUNT;
    endcase

    always @(reset_ == 0) #1 BIT_READ <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex({b4, b3})
        2'b00: BIT_READ <= BIT_READ + 1;
        2'b01: BIT_READ <= 0;
        2'b1?: BIT_READ <= BIT_READ;
    endcase

    always @(reset_ == 0) #1 BYTE <= 8'h00;
    always @(posedge clock) if (reset_ == 1) #3
        BYTE <= b5 ? {(COUNT < 8) ? 1'b1 : 1'b0, BYTE[7:1]} : BYTE;

    assign c0 = ~rxd;
    assign c1 = rxd;
    assign c2 = (BIT_READ == 7) ? 1 : 0;

endmodule

module PC (
    clock, reset_,
    b5, b4, b3, b2, b1, b0,
    c2, c1, c0
);
    input clock, reset_;
    output b5, b4, b3, b2, b1, b0;
    input c2, c1, c0;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
        S0: STAR <= c0 ? S1 : S0;
        S1: STAR <= c1 ? S2 : S1;
        S2: STAR <= c2 ? S3 : S0;
        S3: STAR <= S0;
    endcase

    assign {b5, b4, b3, b2, b1, b0} = 
        (STAR == S0) ? 6'b01x000 :
        (STAR == S1) ? 6'b01x010 :
        (STAR == S2) ? 6'b1001x0 :
        (STAR == S3) ? 6'b0011x1 :
                       6'bxxxxxx;
/*
    Rom
    uAddr  |  b5_0  |  uTrue  | uFalse  | cEff
      S0     01x000     S1       S0        c0
      S1     01x010     S2       S1        c1
      S2     1001x0     S3       S0        c2
      S3     0011x1     S0       S0         -
*/
endmodule

module ABC (
    rxd, ref, led, 
    clock, reset_
);
    input rxd, clock, reset_;
    input[4:0] ref;
    output[2:0] led;

    wire b5, b4, b3, b2, b1, b0;
    wire c2, c1, c0;

    PO po (
        .clock(clock), .reset_(reset_),
        .rxd(rxd), .ref(ref), .led(led),
        .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );

    PC pc (
        .clock(clock), .reset_(reset_),
        .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );

endmodule
