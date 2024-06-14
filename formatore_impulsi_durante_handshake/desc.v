module XXX (
    soc, eoc, numero,
    clock, reset_,
    out
);
    output soc;
    input eoc;
    input[7:0] numero;

    input clock, reset_;
    output out;

    reg SOC; assign soc = SOC;
    reg OUT; assign out = OUT;

    reg[7:0] COUNT;
    reg[7:0] NUM;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    always @(reset_ == 0) #1
    begin
        SOC <= 0;
        OUT <= 0;
        NUM <= 6;
        COUNT <= 5;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex (STAR)
    S0: begin
        COUNT <= COUNT - 1;
        STAR <= (COUNT == 1) ? S1 : S0;
    end 
    S1: begin
        COUNT <= NUM;
        OUT <= 1;
        STAR <= S2;
    end

    S2: begin
        COUNT <= COUNT - 1;
        SOC <= 1;
        STAR <= (eoc == 0) ? S3 : S2;
    end
    S3: begin
        COUNT <= (COUNT == 1) ? (NUM - 1) : COUNT - 1;
        NUM <= (eoc == 1) ? numero : NUM;
        SOC <= 0; 
        OUT <= (COUNT == 1) ? 0 : OUT;
        STAR <= (COUNT == 1) ? S0 : S3;
    end

    endcase

endmodule