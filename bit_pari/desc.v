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

    reg [2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;

    always @(reset_ == 0) #1
    begin
        SOC <= 0;
        DAV_ <= 1;
        OUT <= 0;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
    S0: begin
        SOC <= 1;
        STAR <= (eoc == 0) ? S1 : S0;
    end
    S1: begin
        SOC <= 0;
        X <= x;
        OUT <= 0;
        STAR <= (eoc == 1) ? S2 : S1;
    end
    S2: begin
        OUT <= OUT + X[0];
        X <= {2'b00, X[7:2]};
        STAR <= (X == 0) ? S3 : S2;
    end
    S3: begin
        DAV_ <= 0;
        STAR <= ({rfd1, rfd2, rfd3} == 3'b000) ? S4 : S3;
    end
    S4: begin
        DAV_ <= 1;
        STAR <= ({rfd1, rfd2, rfd3} == 3'b111) ? S0 : S4;
    end
    endcase
    
    
endmodule