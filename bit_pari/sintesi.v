module ABC (
    clock, reset_,
    soc, eoc, x,
    rfd1, dav1_, c1,
    rfd2, dav2_, c2,
    rfd3, dav3_, c3
);
    input clock, reset_;

    output soc;
    input eoc;
    input[7:0] x;

    input rfd1, rfd2, rfd3;
    output dav1_, dav2_, dav3_;
    output[2:0] c1, c2, c3;


    wire b0, b1, b2, b3, b4;
    wire k0, k1, k2, k3;

    PO po (
        .clock(clock), .reset_(reset_),
        .soc(soc), .eoc(eoc), .x(x),
        .rfd1(rfd1), .dav1_(dav1_), .c1(c1),
        .rfd2(rfd2), .dav2_(dav2_), .c2(c2),
        .rfd3(rfd3), .dav3_(dav3_), .c3(c3),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3), .b4(b4),
        .k0(k0), .k1(k1), .k2(k2), .k3(k3)
    );

    PC pc (
        .clock(clock), .reset_(reset_),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3), .b4(b4),
        .k0(k0), .k1(k1), .k2(k2), .k3(k3)
    );
    
    
endmodule

module PO (
    clock, reset_,
    soc, eoc, x,
    rfd1, dav1_, c1,
    rfd2, dav2_, c2,
    rfd3, dav3_, c3,

    b0, b1, b2, b3, b4,
    k0, k1, k2, k3
);
    input clock, reset_;

    output soc;
    input eoc;
    input[7:0] x;

    input rfd1, rfd2, rfd3;
    output dav1_, dav2_, dav3_;
    output[2:0] c1, c2, c3;

    input b0, b1, b2, b3, b4;
    output k0, k1, k2, k3;

    reg SOC; 
    assign soc = SOC;

    reg DAV_; 
    assign dav1_ = DAV_;
    assign dav2_ = DAV_;
    assign dav3_ = DAV_;

    reg[2:0] OUT;
    assign c1 = OUT;
    assign c2 = OUT;
    assign c3 = OUT;

    reg[7:0] X;
    
    assign k0 = eoc;
    assign k1 = ~|(X);
    assign k2 = ~|({rfd1, rfd2, rfd3});
    assign k3 = &({rfd1, rfd2, rfd3});

    always @(reset_ == 0) #1 SOC <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b1, b0})
        2'b01: SOC <= 1;
        2'b10: SOC <= 0;
        default: SOC <= SOC;
    endcase

    always @(reset_ == 0) #1 DAV_ <= 1;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b4, b3})
        2'b01: DAV_ <= 0;
        2'b10: DAV_ <= 1;
        default: DAV_ <= DAV_;
    endcase

    always @(reset_ == 0) #1 OUT <= 0;
    always @(posedge clock) if (reset_ == 1) #3
    casex ({b2, b1})
        2'b01: OUT <= 0;
        2'b10: OUT <= OUT + X[0];
        default: OUT <= OUT;
    endcase

    always @(posedge clock) if (reset_ == 1) #3
    casex ({b2, b1})
        2'b01: X <= x;
        2'b10: X <= {2'b00, X[7:2]};
        default: X <= X;
    endcase    
    
endmodule

module PC (
    clock, reset_,
    b0, b1, b2, b3, b4,
    k0, k1, k2, k3
);
    input clock, reset_;
    output b0, b1, b2, b3, b4;
    input k0, k1, k2, k3;

    reg [2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    assign b0 = ~STAR[0] & ~|(STAR[2:1]);//assign b0 = (STAR == S0) ? 1 : 0;
    assign b1 = STAR[0] & ~|(STAR[2:1]);//assign b1 = (STAR == S1) ? 1 : 0;
    assign b2 = ~STAR[2] & STAR[1] & ~STAR[0];//assign b2 = (STAR == S2) ? 1 : 0;
    assign b3 = ~STAR[2] & &(STAR[1:0]);//assign b3 = (STAR == S3) ? 1 : 0;
    assign b4 = STAR[2] & ~|(STAR[1:0]);//assign b4 = (STAR == S4) ? 1 : 0;
    

    always @(reset_ == 0) #1 STAR <= S0;
    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
        S0: STAR <= (k0 == 1) ? S0 : S1;
        S1: STAR <= (k0 == 1) ? S2 : S1;
        S2: STAR <= (k1 == 1) ? S3 : S2;
        S3: STAR <= (k2 == 1) ? S4 : S3;
        S4: STAR <= (k3 == 1) ? S0 : S4;
    endcase
    
endmodule