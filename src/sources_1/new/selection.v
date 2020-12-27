`timescale 1ns / 1ps
module selection(
    input clock,
    input sys_rst_n,
    output reg sled,
    output reg [7:0]control, 
    output reg [7:0]cube_data,
    input[3:0] sele
    );
    reg[2:0] number;
    wire size;
    reg [16:0]divider_cnt;
    assign size=~sele[0];
    reg clk_1K;
    always@(posedge clock )
        begin
            if(sys_rst_n==1)
            begin
                divider_cnt <= 15'd0;
                clk_1K<=1'd0;
                end
                else
            if(divider_cnt ==9999)
            begin
                divider_cnt <= 15'd0;
                clk_1K<=~clk_1K;
                end
            else
                divider_cnt <= divider_cnt + 1'b1;
                end
        always @(negedge clk_1K or negedge sys_rst_n )begin
        if(sys_rst_n)
            number<=0;
        else if(number==7)
            number<=0;
        else 
            number<=number+1;
        end
        always @(number)begin
        if(size)//DISPLAY 640*480             
               case(number)
               0:begin control<=8'b01111111; cube_data<=8'b10000010;end
               1:begin control<=8'b10111111; cube_data<=8'b10011001;end
               2:begin control<=8'b11011111; cube_data<=8'b11000000;end
               3:begin control<=8'b11101111; cube_data<=8'b11111111;end
               4:begin control<=8'b11110111; cube_data<=8'b11111111;end
               5:begin control<=8'b11111011; cube_data<=8'b10011001;end
               6:begin control<=8'b11111101; cube_data<=8'b10000000;end
               7:begin control<=8'b11111110; cube_data<=8'b11000000;end
              endcase
              else
               case(number)//DISPLAY 800*600
                         0:begin control<=8'b01111111; cube_data<=8'b10000000;end
                         1:begin control<=8'b10111111; cube_data<=8'b11000000;end
                         2:begin control<=8'b11011111; cube_data<=8'b11000000;end
                         3:begin control<=8'b11101111; cube_data<=8'b11111111;end
                         4:begin control<=8'b11110111; cube_data<=8'b11111111;end
                         5:begin control<=8'b11111011; cube_data<=8'b10000010;end
                         6:begin control<=8'b11111101; cube_data<=8'b11000000;end
                         7:begin control<=8'b11111110; cube_data<=8'b11000000;end
                        endcase
    
           end
    always@(posedge clock or negedge sys_rst_n)
    begin
        if(sys_rst_n)
        sled<=0;
        else if(sele!=4'b0001)
        sled<=1;
        end
endmodule
