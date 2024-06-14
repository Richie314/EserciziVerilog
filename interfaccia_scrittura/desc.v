module ABC (
    soc, eoc, x, ok,
    clock, reset_,
    addr, data, ior_, iow_
);
    output soc;
    input eoc;

    output[7:0] x;
    input ok;

    input clock, reset_;

    output [15:0] addr;
    inout [7:0] data;

    output ior_, iow_;

    reg SOC;
    assign soc = SOC;

    reg[15:0] ADDR;
    assign addr = ADDR;

    reg[7:0] DATA_OUT;
    reg DIR;
    assign data = (DIR == 1) ? DATA_OUT : 'hzz;
    assign x = DATA_OUT;

    reg IOR_, IOW_;
    assign ior_ = IOR_;
    assign iow_ = IOW_;

    reg[2:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7;

    always @(reset_ == 0) #1
    begin
        DIR <= 0;
        IOR_ <= 1;
        IOW_ <= 1;
        SOC <= 0;
        DATA_OUT <= 0;
        ADDR <= 'h0ABC;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
    // Find the number X
    S0: begin
        SOC <= 1;
        STAR <= (eoc == 0) ? S1 : S0;
    end
    S1: begin
        SOC <= 0;
        STAR <= (eoc == 1) ? S2 : S1;
    end
    S2: begin
        DATA_OUT <= (ok == 1) ? DATA_OUT : DATA_OUT + 1;
        STAR <= (ok == 1) ? S3 : S0;
    end

    // Wait for the device to be ready to receive
    S3: begin
        IOR_ <= 0;
        STAR <= S4;
    end
    S4: begin
        IOR_ <= 1;
        STAR <= (data[5] == 1) ? S5 : S3;
    end
    
    //Write to the device
    S5: begin
        ADDR <= 'h0ABD;
        DIR <= 1;
        STAR <= S6;
    end
    S6: begin
        IOW_ <= 0;
        STAR <= S7;
    end
    S7: begin
        IOW_ <= 1;
        STAR <= S7;
    end

    endcase

endmodule