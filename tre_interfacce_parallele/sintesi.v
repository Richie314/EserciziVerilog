// C'è un errore da qualche parte

module PO (
    addr, data, ior_, iow_,
    clock, reset_,
    b12, b11, b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0
);
    output[15:0] addr;
    inout[7:0] data;
    output ior_, iow_;
    input clock, reset_;
    input b12, b11, b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0;

    reg[15:0] ADDR; assign addr = ADDR;
    reg[15:0] C;
    reg[7:0] A, DATA;

    reg IOR, IOW; assign ior_ = IOR; assign iow_ = IOW;
    reg DIR; assign data = (DIR == 1) ? DATA : 8'hzz; 

    wire fi; assign fi = DATA[0];

    always @(reset_ == 0) #1
        DIR <= 0;
    always @(posedge clock) if (reset_ == 1) #3 
    casex ({b1, b0})
        2'b00: DIR <= 0; 
        2'b01: DIR <= 1; 
        2'b1?: DIR <= DIR;
    endcase

    always @(reset_ == 0) #1
        IOR <= 1;
    always @(posedge clock) if (reset_ == 1) #3 
    casex ({b3, b2})
        2'b00: IOR <= 0;
        2'b01: IOR <= 1; 
        2'b10: IOR <= (fi == 1) ? 0 : 1;
        2'b11: IOR <= IOR;
    endcase

    always @(reset_ == 0) #1
        IOW <= 1;
    always @(posedge clock) if (reset_ == 1) #3 
    casex ({b5, b4})
        2'b00: IOW <= 0;
        2'b01: IOW <= 1;
        2'b1?: IOW <= IOW;
    endcase

    always @(posedge clock) if (reset_ == 1) #3 
    casex ({b8, b7, b6})
        3'b000: ADDR <= 16'h0120;
        3'b001: ADDR <= 16'h0140;
        3'b010: ADDR <= 16'h0100;
        3'b011: ADDR <= 16'h0101;
        3'b1??: ADDR <= ADDR;
    endcase

    always @(posedge clock) if (reset_ == 1) #3 
        C <= (b9 == 1) ? (data * A) : C;

    always @(posedge clock) if (reset_ == 1) #3 
    casex ({b11, b10})
        2'b00: DATA <= C[15:8];
        2'b01: DATA <= C[7:0];
        2'b10: DATA <= data;
        2'b1?: DATA <= DATA;
    endcase

    always @(reset_ == 0) #1
        A <= 8'h00;
    always @(posedge clock) if (reset_ == 1) #3 
        A <= (b12 & fi == 1) ? data : A;

endmodule

module PC (
    clock, reset_,
    b12, b11, b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0
);
    input clock, reset_;
    output b12, b11, b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0;

    reg[4:0] STAR;
    localparam 
        S0 = 0, S1 = 1, S2 = 2, S3 = 3, 
        S4 = 4, S5 = 5, S6 = 6, S7 = 7, 
        S8 = 8, S9 = 9, S10 = 10, S11 = 11, 
        S12 = 12, S13 = 13, S14 = 14, S15 = 15;

    assign {b1, b0} = 
        (STAR == S0) ? 2'b00 : (STAR == S8) ? 2'b00 :
        (STAR == S2) ? 2'b01 :
                    2'b1X;
    assign {b3, b2} = 
        (STAR == S0) ? 2'b00 : (STAR == S9) ? 2'b00 :
        (STAR == S1) ? 2'b01 : (STAR == S12) ? 2'b01 :
        (STAR == S11) ? 2'b10 :
                    2'b11; 
    assign {b5, b4} = 
        (STAR == S3) ? 2'b00 : (STAR == S6) ? 2'b00 :
        (STAR == S4) ? 2'b01 : (STAR == S7) ? 2'b01 :
                    2'b1X; 
    assign {b8, b7, b6} = 
        (STAR == S0) ? 3'b000 :
        (STAR == S2) ? 3'b001 :
        (STAR == S8) ? 3'b010 :
        (STAR == S10) ? 3'b011 :
                    3'b1XX; 
    assign b9 = (STAR == S1) ? 1 : 0;
    assign {b11, b10} = 
        (STAR == S2) ? 2'b00 :
        (STAR == S5) ? 2'b01 :
        (STAR == S10) ? 2'b10 :
                    2'b1X; 
    assign b12 = (STAR == S12) ? 1 : 0;


    always @(reset_ == 0) #1
        STAR <= S0;
    always @(posedge clock) if (reset_ == 1) #3 
    casex (STAR)
        /* STAR <= STAR + 1; */
        S0: STAR <= S1;
        S1: STAR <= S2;
        S2: STAR <= S3; 
        S3: STAR <= S4;
        S4: STAR <= S5;
        S5: STAR <= S6;
        S6: STAR <= S7;
        S7: STAR <= S8;
        S8: STAR <= S9;
        S9: STAR <= S10;
        S10: STAR <= S11;
        S11: STAR <= S12; 
        S12: STAR <= S13;
        S13: STAR <= S14;
        S14: STAR <= S15;
        S15: STAR <= S0;
    endcase

endmodule

module ABC (
    addr, data, ior_, iow_,
    clock, reset_
);
    output[15:0] addr;
    inout[7:0] data;
    output ior_, iow_;
    input clock, reset_;
    wire b12, b11, b10, b9, b8, b7, b6, b5, b4, b3, b2, b1, b0;

    PO po (
        .addr(addr), .data(data), .ior_(ior_), .iow_(iow_),
        .clock(clock), .reset_(reset_),
        .b12(b12), .b11(b11), .b10(b10), .b9(b9), .b8(b8), .b7(b7), .b6(b6), 
        .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0)
    );

    PC pc (
        .clock(clock), .reset_(reset_),
        .b12(b12), .b11(b11), .b10(b10), .b9(b9), .b8(b8), .b7(b7), .b6(b6), 
        .b5(b5), .b4(b4), .b3(b3), .b2(b2), .b1(b1), .b0(b0)
    );

endmodule