module RX(
    rxd, 
    clock, reset_, 
    data, rfd, dav_
);
    input rxd;
    input clock, reset_;
    input rfd;
    output dav_;

    reg DAV_; assign dav_ = DAV_;

    parameter N = 8; // Transmission length
    parameter K = 16; // T_bit / T_clock
    
    output [N-1:0] data;
    
    reg [N-1:0] DATA; assign data = DATA;


    reg[3:0] COUNT;
    reg[4:0] WAIT;
    
    reg[2:0] STAR; 
    localparam S0 = 0, WaitStart = 1, DataIn = 2, WaitEnd = 3, S4 = 4, S5 = 5;
    localparam start_bit = 1'B0;

    always @(reset_==0) #1 begin 
        DAV_ <= 1; 
        STAR <= S0; 
    end

    always @(posedge clock) if (reset_ == 1) #3
        casex(STAR)
            S0: begin
                COUNT <= N; // bytes we expect
                WAIT <= (K * 3 / 2 - 1); // Wait 1.5 * T_bit
                STAR <= (rxd == start_bit) ? WaitStart : S0; 
            end

            WaitStart: begin
                WAIT <= WAIT - 1; 
                STAR <= (WAIT == 1) ? DataIn : WaitStart; 
            end

            DataIn: begin
                DATA <= {rxd, DATA[N-1:1]}; // Insert from left to right
                COUNT <= COUNT - 1;
                WAIT <= K - 1; 
                STAR <= (COUNT == 1) ? WaitEnd : WaitStart; 
            end

            WaitEnd: begin
                WAIT <= WAIT - 1; // Stopping bit (last) waiting
                STAR <= (WAIT == 1) ? S4 : WaitEnd; 
            end

            S4: begin
                DAV_ <= 0;
                STAR <= (rfd == 0) ? S5 : S4;                
            end

            S5: begin
                DAV_ <= 1;
                STAR <= (rfd == 1) ? S0 : S5;
            end
        endcase
endmodule