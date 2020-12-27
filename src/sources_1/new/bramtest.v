`timescale 1ns / 1ps


module bramtest(
     input clk,
     input rst,
  
     input wea,
     input [7:0] dina,
     output  [7:0] doutb

    );
   
    reg   ena;
    reg   enb;

    reg [10:0] addra;
    reg [10:0] addrb;
    reg [0:0] empty;
  
    always @( posedge clk   )begin
      if(rst)begin
            addra <=11'd0;
            ena <=1'b1;
            empty <=1'b0;
            end
      else begin
            if(wea)begin
                if(~empty)begin
                empty <=1'b1;
                end                
                  if(addra != 11'd2047) begin
                        ena<=1'b1;
                        addra<=addra +1'b1;
                       end
                  else begin
                        addra <=11'd1;
                  end                                   
            end
       end
    end

   always @( posedge clk )begin
         if(rst)begin
            addrb<=11'd0;
            enb <=1'b0;
          end
         else begin
         if(~wea)begin
             if(empty)begin
              enb<=1'b1;
              addrb<=addra;
             end
          end
          end
       end
    
     SDPR bram(
        .clka(clk),
        .ena(ena),
        .wea(wea),
        .addra(addra),
        .dina(dina),
    
        
        .addrb(addrb),
        .clkb(clk),

        .doutb(doutb),
        .enb(enb)
     
     );
     
endmodule
