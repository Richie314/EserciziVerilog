module ABC (
    addr, data, ior_, iow_, clock, reset_
);
    output[15:0] addr;
    inout[7:0] data;
    output ior_, iow_;

    input clock, reset_;

    reg[15:0] ADDR; assign addr = ADDR;
    reg[7:0] DATA_OUT;
    reg DIR; assign data = (DIR == 1) ? DATA_OUT : 8'hzz;

    reg IOR_, IOW_;
    assign ior_ = IOR_;
    assign iow_ = IOW_;

    reg[7:0] X;

    wire[7:0] mh, ml;
    MUL5 m (.x(X), .y({mh, ml}));

    reg[3:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6,
            S7 = 7, S8 = 8, S9 = 9, S10 = 10, S11 = 11;

    always @(reset_ == 0) #1
    begin
        DIR <= 0;
        IOR_ <= 1;
        IOW_ <= 1;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
    S0: begin
        DIR <= 0;
        ADDR <= 16'h0100;
        STAR <= S1;
    end
    S1: begin
        IOR_ <= 0;
        STAR <= S2;
    end
    S2: begin
        IOR_ <= 1;
        STAR <= (data[0] == 1) ? S3 : S0;
    end

    S3: begin
        ADDR <= 16'h0101;
        STAR <= S4;
    end
    S4: begin
        IOR_ <= 0;
        STAR <= S5;
    end
    S5: begin
        IOR_ <= 1;
        X <= data;
        STAR <= S6;
    end

    ///////////////////////

    S6: begin
        DIR <= 1;
        ADDR <= 16'h0121;
        DATA_OUT <= mh;
        STAR <= S7;
    end
    S7: begin
        IOW_ <= 0;
        STAR <= S8;
    end
    S8: begin
        IOW_ <= 1;
        STAR <= S9;
    end
    S9: begin
        DATA_OUT <= ml;
        STAR <= S10;
    end
    S10: begin
        IOW_ <= 0;
        STAR <= S11;
    end
    S11: begin
        IOW_ <= 1;
        STAR <= S0;
    end

    endcase

endmodule

module MUL5 (
    x, y
);
    input [7:0] x;
    output[15:0] y;
    
    add #(.N(16)) adder (
        .x({6'b00, x, 2'b00}), .y({8'h00, x}), .s(y), .c_in(1'b0)
    );

endmodule