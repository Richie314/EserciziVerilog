module ABC (
    addr, data, ior_, iow_,
    clock, reset_
);
    output[15:0] addr;
    inout[7:0] data;
    output ior_, iow_;
    input clock, reset_;

    reg[15:0] ADDR; assign addr = ADDR;
    reg[15:0] C;
    reg[7:0] A, DATA;

    reg IOR, IOW; assign ior_ = IOR; assign iow_ = IOW;
    reg DIR; assign data = (DIR == 1) ? DATA : 8'hzz; 

    wire fi; assign fi = DATA[0];

    reg[4:0] STAR;
    localparam 
        S0 = 0, S1 = 1, S2 = 2, S3 = 3, 
        S4 = 4, S5 = 5, S6 = 6, S7 = 7, 
        S8 = 8, S9 = 9, S10 = 10, S11 = 11, 
        S12 = 12, S13 = 13, S14 = 14, S15 = 15;

    always @(reset_ == 0) #1
    begin
        DIR <= 0;
        IOR <= 1;
        IOW <= 1;
        A <= 8'h00; // Parametro iniziale di A
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3 
    casex (STAR)
        // Lettura da B
        S0: begin
            ADDR <= 16'h0120; // Indirizzo di B
            DIR <= 0; // Sto leggendo
            IOR <= 0;
            STAR <= S1;
        end
        S1: begin
            C <= data * A; // Leggo B e moltiplico subito
            IOR <= 1; // Fine lettura
            STAR <= S2;
        end

        // Output su C
        S2: begin
            ADDR <= 16'h0140; // Indirizzo di C
            DATA <= C[15:8]; // Parte alta
            DIR <= 1; 
            // Non abbasso subito iow per far stabilizzare addr e data
            STAR <= S3; 
        end
        S3: begin
            IOW <= 0; // Abbasso iow_ per segnalare la scrittura
            STAR <= S4;
        end
        S4: begin
            IOW <= 1; // Rialzo iow_ per segnalare fine della scrittura
            STAR <= S5;
        end
        S5: begin
            DATA <= C[7:0]; // Parte bassa
            STAR <= S6;
        end
        S6: begin
            IOW <= 0;
            STAR <= S7;
        end
        S7: begin
            IOW <= 1;
            STAR <= S8;
        end

        // Lettura da A
        S8: begin
            DIR <= 0;
            ADDR <= 16'h0100; // Indirizzo di A
            STAR <= S9;
        end
        S9: begin
            IOR <= 0; // Abbasso ior_ quando indirizzi sono stabili
            STAR <= S10;
        end
        S10: begin
            DATA <= data; // Lettura di state register
            IOR <= 1; 
            ADDR <= 'H0101; // Indirizzi puntano a nuovo dato
            STAR <= S11; 
        end
        S11: begin
            IOR <= (fi == 1) ? 0 : 1; // Se FI = data[0] è 1 bisogna leggere di nuovo
            STAR <= S12; 
        end
        S12: begin
            A <= (fi == 1) ? data : A; // Se data[0] è 1 leggo di nuovo
            IOR <= 1;
            STAR <= S13;
        end

        // Cicli inutili per arrivare a 16
        S13: STAR <= S14;
        S14: STAR <= S15;
        S15: STAR <= S0;
    endcase


endmodule