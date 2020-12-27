`timescale 1ns / 1ps

module bar_display
(
input [10:0] pixel_xpos,
input [10:0] pixel_ypos,
input sys_rst_n,vga_clk,
input [10:0] H_DISP,V_DISP,
input [31:0] data,
output reg[15:0]  led,
input en,
output reg[11:0]  pixel_data
);



localparam WHITE= 12'b1111_1111_1111;
localparam BLACK= 12'b0000_0000_0000;
localparam BLUE= 12'b1111_0000_0000;
localparam GREEN= 12'b0000_1111_0000;
localparam RED= 12'b0000_0000_1111;
localparam YELLOW= 12'b0000_1111_1111;
localparam PINK= 12'b1111_0000_1111;
localparam YOUNG= 12'b1111_1111_0000;


reg [3:0] SHAPE;
reg [11:0] COLOR=12'b0000_0000_0000;
reg [10:0] STARTX=11'd300;
reg [10:0] STARTY=11'd300;
reg [10:0] ENDX=11'd300;
reg [10:0] ENDY=11'd150;
reg [10:0] RADIUS=11'd10;
reg [10:0] WIDTH=11'd2;
reg first=1'b0;
reg ena=1'b1;
reg enb=1'b1;
reg wea=1'b1;
reg [18:0]addra=19'd0;
reg [18:0]addrb=19'd0;
reg [11:0]dina=12'd0;
wire [11:0]douta;
wire [11:0]doutb;

wire point;
wire rec;
wire circle;
wire line;
wire rim;
wire triangle;
wire [18:0]addr;


assign point=(((pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY))<=10);
assign rec=((pixel_xpos>=(STARTX))&&(pixel_xpos<=(ENDX))&&(pixel_ypos>=(STARTY))&&(pixel_ypos<=(ENDY))) ;
assign circle=((pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY)<(0-RADIUS)*(0-RADIUS));
assign line=(((pixel_xpos>=STARTX)&&(pixel_xpos<=ENDX))&&((pixel_ypos<=(pixel_xpos+WIDTH))&&(pixel_ypos>=(pixel_xpos-WIDTH))));
assign addr=((pixel_ypos*H_DISP)+pixel_xpos);
assign rim=(pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY)<=(ENDX-0)*(ENDX-0)&&(pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY)>=(ENDY-0)*(ENDY-0);
assign triangle = (pixel_xpos>STARTX)&&(pixel_ypos>STARTY)&&(pixel_xpos+pixel_ypos)<ENDX;

always @(posedge en) begin
      if(sys_rst_n)begin
        
      end
      else begin 
         SHAPE <=data[7:4];
         COLOR <={data[3:0],data[15:12],data[11:8]};
         STARTX <={6'd0,data[23:20]}*100;
         STARTY <={6'd0,data[19:16]}*100;
         
 case(SHAPE)     
                     4'd1:begin  
                        
                     end 
                     4'd2 :begin
                     ENDX<={6'd0,data[31:28]}*100;
                     WIDTH<={6'd0,data[27:24]};
                     end
                     4'd3 :begin
                     ENDX<={6'd0,data[31:28]}*100;
                     ENDY<={6'd0,data[27:24]}*100;
                     end
                     4'd4 :begin
                     RADIUS<={6'd0,data[31:28]}*100;     
                     end
                     4'd5 :begin
                                   
                     end 
                     4'd6 :begin
                     ENDX<={6'd0,data[31:28]}*100;
                     ENDY<={6'd0,data[27:24]}*100;
                     end
                     4'd7 :begin
                     ENDX<={6'd0,data[31:28]}*100;
                     end
                     default:;
                     endcase 
      end
      
  end
  
 always @(posedge vga_clk or negedge sys_rst_n) begin
        if(sys_rst_n)
            pixel_data <= 12'd0;
        else begin  
         case(SHAPE)     
                            4'd1:begin  
                                 if(point)begin
                                        pixel_data<=COLOR;
                                        addra <=addr;
                                        dina <=COLOR;
                                 end
                                 else begin    
                                         addrb<=addr;    
                                         pixel_data <=doutb;                                  
                                 end
                            end 
                            4'd2 :begin
                             if(line)begin
                                      pixel_data<=COLOR;
                                                                addra <=addr;
                                                                dina <=COLOR;
                                                         end
                                                         else begin    
                                                                 addrb<=addr;    
                                                                 pixel_data <=doutb;                                  
                                                         end
                            end
                            4'd3 :begin
                              if(rec)begin
                                         pixel_data<=COLOR;
                                                                 addra <=addr;
                                                                 dina <=COLOR;
                                                          end
                                                          else begin    
                                                                  addrb<=addr;    
                                                                  pixel_data <=doutb;                                  
                                                          end
                              end
                            4'd4 :begin
                            if(circle)begin
                                          pixel_data<=COLOR;
                                                               addra <=addr;
                                                               dina <=COLOR;
                                                        end
                                                        else begin    
                                                                addrb<=addr;    
                                                                pixel_data <=doutb;                                  
                                                        end
                            end  
                            4'd6 :begin
                            if(rim)begin
                                          pixel_data<=COLOR;
                                                                 addra <=addr;
                                                                 dina <=COLOR;
                                                          end
                                                          else begin    
                                                                  addrb<=addr;    
                                                                  pixel_data <=doutb;                                  
                                                          end
                            
                            end
                            4'd7 :begin
                            if(triangle)begin
                                          pixel_data<=COLOR;
                                                                 addra <=addr;
                                                                 dina <=COLOR;
                                                          end
                                                          else begin    
                                                                  addrb<=addr;    
                                                                  pixel_data <=doutb;                                  
                                                          end
                            
                            end
                             4'd5 :begin
                                                       if((pixel_xpos >= 0) && (pixel_xpos <= (H_DISP/8)*1))    begin                                          
                                                    pixel_data <= WHITE;
                                                       addra <=addr;
                                                      dina <=COLOR;    
                                                      end                           
                                                else if((pixel_xpos >= (H_DISP/8)*1) && (pixel_xpos < (H_DISP/8)*2))begin
                                                    pixel_data <= BLACK;  
                                                       addra <=addr;
                                                                                                                  dina <=COLOR;
                                                                                                                  end
                                                else if((pixel_xpos >= (H_DISP/8)*2) && (pixel_xpos < (H_DISP/8)*3))begin
                                                    pixel_data <= RED;  
                                                       addra <=addr;
                                                                                                                  dina <=COLOR;
                                                                                                                  end
                                                else if((pixel_xpos >= (H_DISP/8)*3) && (pixel_xpos < (H_DISP/8)*4))begin
                                                    pixel_data <= GREEN;  
                                                       addra <=addr;
                                                                                                                  dina <=COLOR;
                                                                                                                   end
                                                else  if((pixel_xpos >= (H_DISP/8)*4) && (pixel_xpos < (H_DISP/8)*5))begin
                                                    pixel_data <= YOUNG;  
                                                       addra <=addr;
                                                                                                                  dina <=COLOR;
                                                                                                                  end
                                                else   if((pixel_xpos >= (H_DISP/8)*5) && (pixel_xpos < (H_DISP/8)*6))begin
                                                    pixel_data <= PINK;  
                                                       addra <=addr;
                                                                                                                  dina <=COLOR;
                                                                                                                  end
                                                else  if((pixel_xpos >= (H_DISP/8)*6) && (pixel_xpos < (H_DISP/8)*7))begin
                                                    pixel_data <= YELLOW;  
                                                       addra <=addr;
                                                                                                                  dina <=COLOR;
                                                                                                                  end
                                                else begin
                                                    pixel_data <= BLUE;    
                                                       addra <=addr;
                                                                                                                  dina <=COLOR;
                                                                                                                  end
                             end
                            
                            default: begin
                                 
                               
                            end  
                            endcase    

         end
end


SDPR ram(
.clka(vga_clk),
.addra(addra),
.dina(dina),
.ena(ena),
.wea(wea),

.addrb(addrb),
.clkb(vga_clk),
.doutb(doutb),
.enb(enb)
);



endmodule

//assign point=(((pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY))<=10);
//assign rec=((pixel_xpos>=(STARTX))&&(pixel_xpos<=(ENDX))&&(pixel_ypos>=(STARTY))&&(pixel_ypos<=(ENDY))) ;
//assign circle=((pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY)<(0-RADIUS)*(0-RADIUS));
//assign line=(((pixel_xpos>=STARTX)&&(pixel_xpos<=ENDX))&&((pixel_ypos<=(pixel_xpos+WIDTH))&&(pixel_ypos>=(pixel_xpos-WIDTH))));
//reg [3:0] SHAPE;
//reg [11:0]COLOR=12'b0111_1100_1110;
//reg [10:0] STARTX=11'd300;
//reg [10:0] STARTY=11'd300;
//reg [10:0] ENDX=11'd300;
//reg [10:0] ENDY=11'd150;
//reg [10:0] RADIUS=11'd10;
//reg [10:0] WIDTH=11'd2;


// always @(posedge en) begin
//      if(sys_rst_n)begin
        
//      end
//      else begin 
//         SHAPE <=data[7:4];
//         COLOR <={data[3:0],data[15:12],data[11:8]};
//         STARTX <={6'd0,data[23:20]}*100;
//         STARTY <={6'd0,data[19:16]}*100;

//         case(SHAPE)     
//                     4'd1:begin  
                        
//                     end 
//                     4'd2 :begin
//                     ENDX<={6'd0,data[31:28]}*100;
//                     WIDTH<={6'd0,data[27:24]};
//                     end
//                     4'd3 :begin
//                     ENDX<={6'd0,data[31:28]}*100;
//                     ENDY<={6'd0,data[27:24]}*100;
//                     end
//                     4'd4 :begin
//                     RADIUS<={6'd0,data[31:28]}*100;     
//                     end
//                     4'd5:begin
                                   
//                     end 
                   
//                     endcase 
//      end
      
//  end
  
// always @(posedge vga_clk or negedge sys_rst_n) begin
//        if(sys_rst_n)
//            pixel_data <= 12'd0;
//        else begin  
//         case(SHAPE)     
//                            4'd1:begin  
//                                 if(point)begin
//                                        pixel_data<=COLOR;
//                                 end
//                                 else begin
//                                       pixel_data<=12'b0000_0000_0000;
//                                 end
//                            end 
//                            4'd2 :begin
//                             if(line)begin
//                                          pixel_data<=COLOR;
//                                         end
//                                         else begin
//                                         pixel_data<=12'b0000_0000_0000;
//                                          end
//                            end
//                            4'd3 :begin
//                              if(rec)begin
//                                          pixel_data<=COLOR;
//                                     end
//                                     else begin
//                                     pixel_data<=12'b0000_0000_0000;
//                                     end
//                              end
//                            4'd4 :begin
//                            if(circle)begin
//                                          pixel_data<=COLOR;
//                                    end 
//                                    else begin
//                                    pixel_data<=12'b0000_0000_0000;
//                                    end
//                            end  
//                             4'd5 :begin
//                                                       if((pixel_xpos >= 0) && (pixel_xpos <= (H_DISP/8)*1))                                              
//                                                    pixel_data <= WHITE;                               
//                                                else if((pixel_xpos >= (H_DISP/8)*1) && (pixel_xpos < (H_DISP/8)*2))
//                                                    pixel_data <= BLACK;  
//                                                else if((pixel_xpos >= (H_DISP/8)*2) && (pixel_xpos < (H_DISP/8)*3))
//                                                    pixel_data <= RED;  
//                                                else if((pixel_xpos >= (H_DISP/8)*3) && (pixel_xpos < (H_DISP/8)*4))
//                                                    pixel_data <= GREEN;  
//                                                else  if((pixel_xpos >= (H_DISP/8)*4) && (pixel_xpos < (H_DISP/8)*5))
//                                                    pixel_data <= YOUNG;  
//                                                else   if((pixel_xpos >= (H_DISP/8)*5) && (pixel_xpos < (H_DISP/8)*6))
//                                                    pixel_data <= PINK;  
//                                                else  if((pixel_xpos >= (H_DISP/8)*6) && (pixel_xpos < (H_DISP/8)*7))
//                                                    pixel_data <= YELLOW;  
//                                                else 
//                                                    pixel_data <= BLUE;    
//                             end
                            
//                            default: begin
                            
//                                  pixel_data<=12'b0000_0000_0000;
                               
//                            end  
//                            endcase    

//         end
//end
//endmodule










//wire point;
//wire rec;
//wire circle;
//wire line;
//always@(posedge vga_clk or negedge sys_rst_n)
//begin
//if(sys_rst_n)
//	led<=16'b0000000000000000;
//else 
//    led[15:0]<=data[15:0];
//end

//assign point=(((pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY))<=10);
//assign rec=((pixel_xpos>=(STARTX))&&(pixel_xpos<=(ENDX))&&(pixel_ypos>=(STARTY))&&(pixel_ypos<=(ENDY))) ;
//assign circle=((pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY)<(0-RADIUS)*(0-RADIUS));
//assign line=(((pixel_xpos>=STARTX)&&(pixel_xpos<=ENDX))&&((pixel_ypos<=(pixel_xpos+WIDTH))&&(pixel_ypos>=(pixel_xpos-WIDTH))));

// always @(posedge en) begin
//      if(sys_rst_n)begin
        
//      end
//      else begin 
//         COLOR <=data[11:0];
         
//      end
      
//  end
//// always @(posedge vga_clk or negedge sys_rst_n) begin
////        if(sys_rst_n)
////            pixel_data <= 12'd0;
////        else begin     
////              if(point)     begin
////              pixel_data<=COLOR;    end
////              else if(line)      begin
////              pixel_data<=WHITE;    end
////              else if(circle)    begin
////              pixel_data<=GREEN;    end
////              else if(rec)       begin
////              pixel_data<=COLOR;    end
////              else begin
////              pixel_data<=12'b1111_0000_0000; end
////         end
////end
// always @(posedge vga_clk or negedge sys_rst_n) begin
//        if(sys_rst_n)
//            pixel_data <= 12'd0;
//        else begin     
//        if((pixel_xpos >= 0) && (pixel_xpos <= (H_DISP/8)*1))                                              
//                        pixel_data <= WHITE;                               
//                    else if((pixel_xpos >= (H_DISP/8)*1) && (pixel_xpos < (H_DISP/8)*2))
//                        pixel_data <= BLACK;  
//                    else if((pixel_xpos >= (H_DISP/8)*2) && (pixel_xpos < (H_DISP/8)*3))
//                        pixel_data <= RED;  
//                    else if((pixel_xpos >= (H_DISP/8)*3) && (pixel_xpos < (H_DISP/8)*4))
//                        pixel_data <= GREEN;  
//                    else  if((pixel_xpos >= (H_DISP/8)*4) && (pixel_xpos < (H_DISP/8)*5))
//                        pixel_data <= YOUNG;  
//                    else   if((pixel_xpos >= (H_DISP/8)*5) && (pixel_xpos < (H_DISP/8)*6))
//                        pixel_data <= PINK;  
//                    else  if((pixel_xpos >= (H_DISP/8)*6) && (pixel_xpos < (H_DISP/8)*7))
//                        pixel_data <= COLOR;  
//                    else 
//                        pixel_data <= BLUE;
//              end
//end


//endmodule
