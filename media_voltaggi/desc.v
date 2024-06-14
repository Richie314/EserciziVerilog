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

    reg SOC; assign soc = SOC;
    reg DAV_; assign dav_ = DAV_;
    reg[7:0] AVG; assign avg = AVG;

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
            STAR <= ({eoc1, eoc2, eoc3, eoc4} == 4'b0000) ? S1 : S0;
        end
        S1: begin
            SOC <= 0;
            AVG <= (x1 + x2 + x3 + x4) / 4;
            STAR <= ({eoc1, eoc2, eoc3, eoc4} == 4'b1111) ? S2: S1;
        end
        S2: begin
            DAV_ <= 0;
            STAR <= rfd ? S3 : S0;
        end
        S3: begin
            DAV_ <= 1;
            STAR <= rfd ? S3 : S0;
        end
    endcase
endmodule