module TX(
    txd, 
    clock, reset_, 
    data_in, rfd, dav_
);
    output txd;
    input clock, reset_;
    
    parameter N = 8; // message lenght
    parameter K = 1; // T_bit / T_clock. K must be > 1

    input [N-1:0] data_in;
    output rfd;
    input dav_;

    reg RFD; assign rfd = RFD;
    reg TXD; assign txd = TXD;
    
    reg[3:0] COUNT;
    reg[N+1:0] BUFFER;
    reg[1:0] STAR;
    reg[3:0] WAIT;
    localparam S0 = 0, S1 = 1, Wait = 2, S3 = 3;
    localparam marking=1'B1, start_bit=1'B0, stop_bit=1'B1;

    always @(reset_ == 0) #1 begin 
        RFD <= 1; 
        TXD <= marking; 
        STAR <= S0; 
    end
    
    always @(posedge clock) if (reset_ == 1) #3
        casex(STAR)
            S0: begin 
                RFD <= 1; 
                COUNT <= (N + 2); // start_bit + data_in + stop_bit
                TXD <= marking;
                BUFFER <= {stop_bit, data_in, start_bit};
                STAR <= (dav_ == 0) ? S1 : S0; // dav_ == 0 => data received
            end

            S1: begin 
                RFD <= 0; 
                TXD <= BUFFER[0]; // Get first byte to transmit
                BUFFER <= {marking, BUFFER[9:1]}; // Shift the data to the right

                COUNT <= COUNT - 1; 
                WAIT <= K - 1;
                STAR <= Wait; 
            end

            Wait: begin
                WAIT <= WAIT - 1;
                STAR <= (WAIT != 1) ? Wait : 
                        (COUNT == 0) ? S3 : S1;
            end

            S3: begin 
                STAR <= (dav_ == 1) ? S0 : S3; 
            end
        endcase
endmodule