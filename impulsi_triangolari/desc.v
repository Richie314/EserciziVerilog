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

    reg RFD; assign rfd = RFD;
    reg[7:0] OUT; assign out = OUT;
    reg S;
    reg[6:0] COUNT;

    reg[1:0] STAR;
    localparam S0 = 0, S1 = 1, S2 = 2;

    always @(reset_ == 0) #1
    begin
        RFD <= 0;
        OUT <= 8'h80;
        STAR <= S0;
        S <= 0;
        COUNT <= 0;
    end

    always @(posedge clock) #3
    casex(STAR)
        S0: begin
            RFD <= 1; // Siamo pronti a leggere, quindi leggiamo
            COUNT <= h;
            S <= s;
            STAR <= (dav_ == 0) ? S1 : S0; // Quando stiamo leggendo i dati giusti usciamo
        end 
        S1: begin
            RFD <= 0; // Non si legge più
            OUT <= (S == 0) ? (OUT + 1) : (OUT - 1); // Triangolo
            COUNT <= COUNT - 1;
            STAR <= (COUNT == 1) ? S2 : S1; // Siamo in fondo?
        end
        S2: begin
            OUT <= 8'h80; // Resettiamo la linea a zero
            STAR <= (dav_ == 1) ? S0 : S2; // Aspettiamo che il produttore si accorga che abbiamo finito
            // Quando rialzeremo rfd lui se ne accorgerà e ci darà nuovi dati
        end
    endcase

endmodule