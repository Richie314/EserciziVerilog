module PO (
    dav_, rfd,
    s, h, 
    clock, reset_,
    out,
    b5, b4, b3, b2, b1, b0,
    c2, c1, c0
);
    input clock, reset_;
    output[7:0] out;
    input s;
    input[6:0] h;
    input dav_;
    output rfd;

    input b5, b4, b3, b2, b1, b0;
    output c2, c1, c0;

    reg RFD; assign rfd = RFD;
    reg[7:0] OUT; assign out = OUT;
    reg S;
    reg[6:0] COUNT;

    always @(reset_ == 0) #1 RFD <= 0;
    always @(posedge clock) #3 RFD <= b0;

    always @(reset_ == 0) #1 OUT <= 8'h80;
    always @(posedge clock) #3
    casex({b2, b1})
        2'b00: OUT <= (S == 0) ? (OUT + 1) : (OUT - 1);
        2'b01: OUT <= 8'h80;
        2'b1?: OUT <= OUT;
    endcase

    always @(reset_ == 0) #1 S <= 0;
    always @(posedge clock) #3 S <= b3 ? s : S;
    

    always @(reset_ == 0) #1 COUNT <= 0;
    always @(posedge clock) #3
    casex({b5, b4})
        2'b00: COUNT <= h;
        2'b01: COUNT <= COUNT - 1;
        2'b1?: COUNT <= COUNT;
    endcase

    assign c0 = ~dav_;
    assign c1 = (COUNT == 1) ? 1 : 0;
    assign c2= dav_;

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
    localparam S0 = 0, S1 = 1, S2 = 2;

    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) #3
    casex(STAR)
        S0: STAR <= c0 ? S1 : S0;
        S1: STAR <= c1 ? S2 : S1;
        S2: STAR <= c2 ? S0 : S2;
    endcase

    // Should be assigned one by one instead of this
    assign {b5, b4, b3, b2, b1, b0} = 
        (STAR == S0) ? 6'b0011x1 :
        (STAR == S1) ? 6'b010000 :
        (STAR == S2) ? 6'b1x0010 :
                       6'bxxxxxx;

/*
        uAddr    b5_0     uTrue    uFalse  cEff
        S0      0011x1     S1       S0      c0
        S1      010000     S2       S1      c1
        S2      1x0010     S0       S2      c2
*/

endmodule

module ABC (
    dav_, rfd,
    s, h, 
    clock, reset_,
    out
);
    input clock, reset_;
    output[7:0] out;
    input s;
    input[6:0] h;
    input dav_;
    output rfd;

    
    wire b5, b4, b3, b2, b1, b0;
    wire c2, c1, c0;

    PO po (
        .dav_(dav_), .rfd(rfd),
        .s(s), .h(h), 
        .clock(clock), .reset_(reset_),
        .out(out),
        .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );

    PC pc (
        .clock(clock), .reset_(reset_),
        .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0),
        .c2(c2), .c1(c1), .c0(c0)
    );

endmodule