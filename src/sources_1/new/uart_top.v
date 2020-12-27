
module UART_Test(
	input				clk,			
	input				rst_n,			
	
	input				fpga_rxd,		
	//output[15:0]        led,
	output[31:0]        m_rxd_data,
	output				fpga_txd,		
	output              s_flag
	//output				divide_clk,		//precise clock output
    
    );
wire clk100mhz;
clk_wiz_0 clk_pll_0
   (
    .clk_out3(clk100mhz),     
    .clk_in1(clk)
    );      
//Precise clk divider
wire	divide_clken;
precise_divider	
#(
	//DEVIDE_CNT = 42.94967296 * fo
	
//	.DEVIDE_CNT	(32'd175921860)	//256000bps * 16	
//	.DEVIDE_CNT	(32'd87960930)	//128000bps * 16
//	.DEVIDE_CNT	(32'd79164837)	//115200bps * 16
	.DEVIDE_CNT	(32'd6597070)	//9600bps * 16
)
u_precise_divider
(
	.clk				(clk100mhz),		
	.rst_n				(rst_n),    
	
	.divide_clk			(divide_clk),
	.divide_clken		(divide_clken)
);

wire	clken_16bps = divide_clken;
//wire			s_flag;
//wire	[31:0]	m_rxd_data;
/******command******/

uart_rx	u_uart_rx
(
	.clk			(clk100mhz),
	.rst_n			(rst_n),
	
	.clken_16bps	(clken_16bps),
	.rxd			(fpga_rxd),	
	//.led             (led),

	.m_rxd_data		(m_rxd_data),		
	.s_flag		(s_flag)  	
);


uart_tx	 u_uart_tx
(
	.clk			(clk100mhz),
	.rst_n			(rst_n),
	
	.clken_16bps	(clken_16bps),	
	.txd			(fpga_txd),  	
             
	.txd_en			(s_flag),		
	.txd_data		(m_rxd_data),		
	.txd_flag		() 			
);
endmodule

/*
//module UART_Test(
//	//global clock 25MHz
//	input				clk,			//25MHz
//	input				rst_n,			
	
//	//user interface
//	input				fpga_rxd,		//pc 2 fpga uart receiver
//	output             led,
//	output				fpga_txd		//fpga 2 pc uart transfer
//	//output				divide_clk,		//precise clock output

//    );
//wire clk50mhz;
//wire clk100mhz;
//clk_wiz_0 clk_pll_0
//   (
//    // Clock out ports
//    .clk_out1(clk100mhz),     // output clk_out1 50mhz
//	//.clk_out2(clk100mhz),
//    // Status and control signals
//   /*  .reset(rst_n), // input reset
//    .locked(),       // output locked */
//   // Clock in ports
//    .clk_in1(clk));      // input clk_in1	
//	//------------------------------------
////Precise clk divider
//wire	divide_clken;
//precise_divider	
//#(
//	//DEVIDE_CNT = 42.94967296 * fo
	
////	.DEVIDE_CNT	(32'd175921860)	//256000bps * 16	
////	.DEVIDE_CNT	(32'd87960930)	//128000bps * 16
////	.DEVIDE_CNT	(32'd79164837)	//115200bps * 16
//	.DEVIDE_CNT	(32'd6597070)	//9600bps * 16
//)
//u_precise_divider
//(
//	//global
//	.clk				(clk100mhz),		//50MHz clock
//	.rst_n				(rst_n),    //global reset
	
//	//user interface
//	.divide_clk			(divide_clk),
//	.divide_clken		(divide_clken)
//);

//wire	clken_16bps = divide_clken;
////---------------------------------
////Data receive for PC to FPGA.
//wire			s_flag;
//wire	[31:0]	m_rxd_data;
//uart_rx	u_uart_rx
//(
//	//gobal clock
//	.clk			(clk100mhz),
//	.rst_n			(rst_n),
	
//	//uart interface
//	.clken_16bps	(clken_16bps),
//	.rxd			(fpga_rxd),	
//	.led             (led),
//	//user interface
//	.m_rxd_data		(m_rxd_data),		
//	.s_flag		(s_flag)  	
//);

////---------------------------------
////Data receive for FPGA to PC.
//uart_tx	 u_uart_tx
//(
//	//gobal clock
//	.clk			(clk100mhz),
//	.rst_n			(rst_n),
	
//	//uaer interface
//	.clken_16bps	(clken_16bps),	
//	.txd			(fpga_txd),  	
           
//	//user interface   
//	.txd_en			(s_flag),		
//	.txd_data		(m_rxd_data),		
//	.txd_flag		() 			
//);
//endmodule


/****************************/
//module uart_top(
//    input           sys_clk,         
//    input           sys_rst_n,        
    
    
//    input           rxd,         
//    output         txd,          
//    output       [7:0]led
//    );
    

//parameter  CLK_FREQ = 100000000;     
//parameter  UART_BPS = 115200;       

    
//wire       en;               
//wire [31:0] data;              

    
////bramtest ubram(
////     .clk(sys_clk),
////     .rst(sys_rst_n),
 
    
////     .wea(en),
     
////     .dina(data),
////     .doutb(led)
////);


//uart_recv #(                   
//    .CLK_FREQ       (CLK_FREQ),     
//    .UART_BPS       (UART_BPS))  
    
//u_uart_recv(                 
//    .sys_clk        (sys_clk), 
//    .sys_rst_n      (sys_rst_n),
    
//    .uart_rxd       (rxd),
//    .uart_done      (en),
//    .uart_data      (data)
  
//    );
    
//uart_send #(               
//    .CLK_FREQ       (CLK_FREQ),       
//    .UART_BPS       (UART_BPS))     
    
//u_uart_send(                 
//    .sys_clk        (sys_clk),
//    .sys_rst_n      (sys_rst_n),
     
//    .uart_en        (en),
//    .uart_din       (data),
//    .uart_txd       (txd)
//    );

//endmodule 
