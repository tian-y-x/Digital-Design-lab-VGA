
module uart_tx(
//gobal clock
	input				clk,
	input				rst_n,
	
	//uart interface
	input				clken_16bps,//clk_bps * 16
	output	reg			txd,		//uart txd interface
	
	//user interface
	input				txd_en,		//uart data transfer enable
	input		[31:0]	txd_data,	//uart transfer data
	output	reg			txd_flag	//uart data transfer done
    );
	
	/**************************************************************************
..IDLE...Start...............UART DATA........................End...IDLE...
________													 ______________
        |____< D0 >< D1 >< D2 >< D3 >< D4 >< D5 >< D6 >< D7 >
		Bit0  Bit1  Bit2  Bit3  Bit4  Bit5  Bit6  Bit7  Bit8  Bit9
**************************************************************************/
//---------------------------------------
//parameter of uart transfer
localparam	T_IDLE	=	2'b0;	//test the flag to transfer data
localparam	T_SEND	=	2'b1;	//uart transfer data
reg	[1:0]	txd_state;			//uart transfer state
reg	[3:0]	smp_cnt;			//16 * clk_bps, the center for sample
reg	[5:0]	txd_cnt;			//txd data counter
localparam	SMP_TOP		=	4'd15;
localparam	SMP_CENTER	=	4'd7;
always@(posedge clk	or negedge rst_n)
begin
	if(rst_n)
		begin
		smp_cnt <= 0;
		txd_cnt <= 0;	
		txd_state <= T_IDLE;
		end
	else
		begin
		case(txd_state)
		T_IDLE:		
			begin
			smp_cnt <= 0;
			txd_cnt <= 0;
			if(txd_en == 1)
				txd_state <= T_SEND;
			else
				txd_state <= T_IDLE;
			end	
		T_SEND:	
			begin
			if(clken_16bps == 1)
				begin
				smp_cnt <= smp_cnt + 1'b1;
				if(smp_cnt == SMP_TOP)
					begin
					if(txd_cnt < 6'd45)
						begin
						txd_cnt <= txd_cnt + 1'b1;
						txd_state <= T_SEND;
						end
					else
						begin
						txd_cnt <= 0;
						txd_state <= T_IDLE;
						end
					end
				else
					begin
					txd_cnt <= txd_cnt;
					txd_state <= txd_state;
					end
				end	
			else
				begin
				txd_cnt <= txd_cnt;
				txd_state <= txd_state;
				end
			end		
		endcase
		end
end


//--------------------------------------
//uart 8 bit data transfer
always@(*)
begin
	if(txd_state == T_SEND)
		case(txd_cnt)
		                           
				   
		6'd0:  	txd = 0;			    
		6'd1:  	txd = txd_data[0];    
		6'd2:  	txd = txd_data[1];    
		6'd3:	txd = txd_data[2];   
		6'd4:	txd = txd_data[3];   
		6'd5:	txd = txd_data[4];   
		6'd6:	txd = txd_data[5];   
		6'd7:	txd = txd_data[6];   
		6'd8:	txd = txd_data[7];   
		6'd9:  	txd = 1;	 
		                                  
		6'd12:	 txd = 0;	    
		6'd13:	 txd = txd_data[8];	 
		6'd14:	 txd = txd_data[9];	 
		6'd15:	 txd = txd_data[10]; 
		6'd16:	 txd = txd_data[11]; 
		6'd17:	 txd = txd_data[12]; 
		6'd18:	 txd = txd_data[13]; 
		6'd19:	 txd = txd_data[14]; 
		6'd20:	 txd = txd_data[15]; 
		6'd21:   txd = 1;	        

		6'd24:	 txd = 0;            
		6'd25:	 txd = txd_data[16];	
		6'd26:	 txd = txd_data[17];	
		6'd27:	 txd = txd_data[18];	
		6'd28:	 txd = txd_data[19];	
		6'd29:	 txd = txd_data[20];	
		6'd30:	 txd = txd_data[21];	
		6'd31:	 txd = txd_data[22];	
		6'd32:	 txd = txd_data[23];	
		6'd33:	 txd = 1;
		         				   
		6'd36:	 txd = 0;           
		6'd37:	 txd = txd_data[24];
		6'd38:	 txd = txd_data[25];
		6'd39:	 txd = txd_data[26];
		6'd40:	 txd = txd_data[27];
		6'd41:	 txd = txd_data[28];
		6'd42:	 txd = txd_data[29];
		6'd43:	 txd = txd_data[30];
		6'd44:	 txd = txd_data[31];
		6'd45:	 txd = 1;
		default:txd = 1;
		endcase
	else
		txd = 1'b1;	//default state
end


//-------------------------------------
//Capture the falling of data transfer over
always@(posedge clk or negedge rst_n)
begin
	if(rst_n)
		txd_flag <= 0;
	else if(clken_16bps == 1 &&  txd_cnt == 4'd9 && smp_cnt == SMP_TOP)	//Totally 8 data is done
		txd_flag <= 1;
	else
		txd_flag <= 0;
end

//ndmodule
//		//
//		//6'd12:	txd = 0;
//		//6'd13:	txd = txd_data[8];
//		//6'd14:	txd = txd_data[9];
//		//6'd15:	txd = txd_data[10];
//		//6'd16:	txd = txd_data[11];
//		//6'd17:	txd = txd_data[12];
//		//6'd18:	txd = txd_data[13];
//		//6'd19:	txd = txd_data[14];
//		//6'd20:	txd = txd_data[15];
//		//6'd21:	txd = 1;
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		//
//		default:txd = 1;
//		endcase
//	else
//		txd = 1'b1;	//default state
//nd


//-------------------------------------
//Capture the falling of data transfer over
//always@(posedge clk or negedge rst_n)
//begin
//	if(!rst_n)
//		txd_flag <= 0;
//	else if(clken_16bps == 1 &&  txd_cnt == 4'd39 && smp_cnt == SMP_TOP)	//Totally 8 data is done
//		txd_flag <= 1;
//	//else if(clken_16bps == 1 &&  txd_cnt == 4'd19 && smp_cnt == SMP_TOP)	//Totally 8 data is done
//	//	txd_flag <= 1;
//	//else if(clken_16bps == 1 &&  txd_cnt == 4'd29 && smp_cnt == SMP_TOP)	//Totally 8 data is done
//	//	txd_flag <= 1;
//	//else if(clken_16bps == 1 &&  txd_cnt == 4'd39 && smp_cnt == SMP_TOP)	//Totally 8 data is done
//	//	txd_flag <= 1;
//	else
//		txd_flag <= 0;
//end


//reg [3:0]state;
//always@(posedge clk or negedge rst_n)
//begin 
//	if(!rst_n)
//	begin
//		state<=0;
//	end 
//	else if(state < 4'd4)
//	begin
//	if(txd_flag)
//		state<=state+1;
//	else 
//		state<=state;
//	end
//	else
//		state<=0;
//end
//
//always@(*)
//begin
//	if(state==4'd1)
//        data<=txd_data[7:0];   
//	else if(state==4'd2)
//        data<=txd_data[15:8];
//	else if(state==4'd3)
//        data<=txd_data[23:16];  
//	else if(state==4'd4)
//        data<=txd_data[31:24];
//end
endmodule

//module uart_send(
//    input	      sys_clk,                 
//    input         sys_rst_n,              
    
//    input         uart_en,                
//    input  [7:0]  uart_din,                
//    output  reg   uart_txd                
//    );
    

//parameter  CLK_FREQ = 100000000;           
//parameter  UART_BPS = 115200;              
//localparam BPS_CNT  = CLK_FREQ/UART_BPS;    

//reg        uart_en_d0; 
//reg        uart_en_d1;  
//reg [15:0] clk_cnt;                       
//reg [ 3:0] tx_cnt;                      
//reg        tx_flag;                       
//reg [ 7:0] tx_data;                     

//wire       en_flag;


//assign en_flag = (~uart_en_d1) & uart_en_d0;
                                                 
//always @(posedge sys_clk or negedge sys_rst_n) begin         
//    if (sys_rst_n) begin
//        uart_en_d0 <= 1'b0;                                  
//        uart_en_d1 <= 1'b0;
//    end                                                      
//    else begin                                               
//        uart_en_d0 <= uart_en;                               
//        uart_en_d1 <= uart_en_d0;                            
//    end
//end

    
//always @(posedge sys_clk or negedge sys_rst_n) begin         
//    if (sys_rst_n) begin                                  
//        tx_flag <= 1'b0;
//        tx_data <= 8'd0;
//    end 
//    else if (en_flag) begin                               
//            tx_flag <= 1'b1;              
//            tx_data <= uart_din;          
//        end
//        else 
//        if ((tx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))
//        begin                         
//            tx_flag <= 1'b0;            
//            tx_data <= 8'd0;
//        end
//        else begin
//            tx_flag <= tx_flag;
//            tx_data <= tx_data;
//        end 
//end


//always @(posedge sys_clk or negedge sys_rst_n) begin         
//    if (sys_rst_n) begin                             
//        clk_cnt <= 16'd0;                                  
//        tx_cnt  <= 4'd0;
//    end                                                      
//    else if (tx_flag) begin              
//        if (clk_cnt < BPS_CNT - 1) begin
//            clk_cnt <= clk_cnt + 1'b1;
//            tx_cnt  <= tx_cnt;
//        end
//        else begin
//            clk_cnt <= 16'd0;               
//            tx_cnt  <= tx_cnt + 1'b1;       
//        end
//    end
//    else begin                            
//        clk_cnt <= 16'd0;
//        tx_cnt  <= 4'd0;
//    end
//end


//always @(posedge sys_clk or negedge sys_rst_n) begin        
//    if (sys_rst_n)  
//        uart_txd <= 1'b1;        
//    else if (tx_flag)
//        case(tx_cnt)
//            4'd0: uart_txd <= 1'b0;        
//            4'd1: uart_txd <= tx_data[0];   
//            4'd2: uart_txd <= tx_data[1];
//            4'd3: uart_txd <= tx_data[2];
//            4'd4: uart_txd <= tx_data[3];
//            4'd5: uart_txd <= tx_data[4];
//            4'd6: uart_txd <= tx_data[5];
//            4'd7: uart_txd <= tx_data[6];
//            4'd8: uart_txd <= tx_data[7];   
//            4'd9: uart_txd <= 1'b1;      
//            default: ;
//        endcase
//    else 
//        uart_txd <= 1'b1;                   
//end

//endmodule	          