module ABC (
    clock, reset_,
    dav_, rfd,
    eoc, soc,
    in_data, out_data
);

parameter N = 8;
parameter M = 8;

input clock, reset_;

input eoc;
output soc;
input[N-1:0] in_data;

input rfd;
output dav_;
output[M-1:0] out_data;

reg [M-1:0] OUT; assign out_data = OUT;
reg SOC; assign soc = SOC;
reg DAV_; assign dav_ = DAV_;

reg [1:0] STAR;
localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

always @(reset_ == 0) #1
begin
    STAR <= S0;
    SOC <= 0;
    DAV_ <= 1;
end

always @(posedge clock) if (reset_ == 1) #3
casex (STAR)
    S0:
    begin
        SOC <= 1;
        STAR <= (eoc == 0) ? S1 : S0;
    end

    S1:
    begin
        SOC <= 0;
        // data_in
        //OUT <= 
        STAR <= (eoc == 1) ? S2 : S1;
    end

    S2:
    begin
        DAV_ <= 0;
        STAR <= (rfd == 1) ? S3 : S2;
    end

    S3:
    begin
        DAV_ <= 1;
        STAR <= (rfd == 0) ? S0: S3;
    end
endcase

endmodule