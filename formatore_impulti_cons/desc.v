module ABC (
    clock, reset_,
    rfdA, rfdB,
    davA_, davB_,
    dataA, dataB,
    out
);
    input clock, reset_;

    input davA_, davB_;
    input [7:0] dataA, dataB;

    output rfdA, rfdB;
    reg RFD; assign rfdA = RFD; assign rfdB = RFD;

    output out;
    reg OUT; assign out = OUT;

    wire[3:0] comp_out;
    COMP comp (.a(dataA), .b(dataB), .count(comp_out));

    reg[3:0] WAIT;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2;

    always @(reset_ == 0) #1 
    begin
        RFD <= 0;
        WAIT <= 0;
        OUT <= 0;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
    S0: begin
        RFD <= 1;
        //OUT <= 0;
        WAIT <= comp_out;
        STAR <= ({davA_, davB_} == 2'b00) ? S1 : S0;
    end
    S1: begin
        RFD <= 0;
        OUT <= 1;
        WAIT <= WAIT - 1;
        STAR <= (WAIT == 1) ? S2 : S1;
    end
    S2: begin
        OUT <= 0;
        STAR <= ({davA_, davB_} == 2'b11) ? S0 : S2;
    end

    endcase


endmodule

module COMP (
    a, b, count
);
    input [7:0] a, b;
    output [3:0] count;
    wire c_out;
    add #(.N(8)) adder (
        .x(b), .y(~a), .c_in(1'b1), 
        .c_out(c_out)
    );

    assign count = (c_out == 0) ? 4'b0110 : 4'b1100;

endmodule