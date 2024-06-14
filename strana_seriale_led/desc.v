module ABC (
    rxd, ref, led, 
    clock, reset_
);
    input rxd, clock, reset_;
    input[4:0] ref;
    output[2:0] led;


    reg[2:0] LED; assign led = LED;
    reg[1:0] STAR;
    reg[7:0] BYTE; // coda dei bit in entrata
    reg[3:0] BIT_READ; // numero dei bit letti
    reg[3:0] COUNT; // contatore dei cicli passati con rxd=spacing
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;

    always @(reset_ == 0) #1
    begin
        LED <= 3'b000;
        COUNT <= 0;
        BYTE <= 8'h00;
        BIT_READ <= 0;
        STAR <= S0;
    end

    always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
        S0: begin
            COUNT <= 0;
            STAR <= (rxd == 0) ? S1 : S0; // Aspetto che rxd scenda
        end
        S1: begin
            COUNT <= COUNT + 1; // conto per quanto sta giù
            STAR <= (rxd == 1) ? S2 : S1; // Aspetto che rxd risalga
        end
        S2: begin
            BYTE <= {(COUNT < 8) ? 1'b1 : 1'b0, BYTE[7:1]}; // Shift verso dx dei bit
            BIT_READ <= BIT_READ + 1;
            STAR <= (BIT_READ == 7) ? S3 : S0; // ho letto tutti i bit?
        end
        S3: begin
            LED <= (BYTE[7:3] == ref) ? BYTE[2:0] : LED; // devo aggoirnare l'output?
            BIT_READ <= 0; // Resetto contatore dei bit letti
            STAR <= S0;
        end
    endcase

endmodule
