module uart_rx(
//gobal clock
	input				clk,
	input				rst_n,
	input				clken_16bps,//clk_bps * 16
	
	input				rxd,		
	//output  reg [15:0]  led,
	output	reg	[31:0]	m_rxd_data,	//uart data receive
	output	reg			s_flag	//uart data receive done 
	
    );
	
	
//---------------------------------
//sync the rxd data: rxd_sync
reg	rxd_sync;				
always@(posedge clk or negedge rst_n)
begin
	if(rst_n)
		rxd_sync <= 1;
	else
		rxd_sync <= rxd;
end

//---------------------------------------
//parameter of uart transfer
localparam	R_IDLE		=	2'd0;		//detect if the uart data is begin
localparam	R_START		=	2'd1;		//uart transfert start mark bit
localparam	R_SAMPLE	=	2'd2;		//uart 8 bit data receive
localparam	R_STOP		=	2'd3;		//uart transfer stop mark bit
reg	[1:0]	rxd_state;					//uart receive state
reg	[3:0]	rxd_cnt;					//uart 8 bit data counter
reg	[3:0]	smp_cnt;					//16 * clk_bps, the center for sample
localparam	SMP_TOP		=	4'd15;
localparam	SMP_CENTER	=	4'd7;
always@(posedge clk or negedge rst_n)
begin
	if(rst_n)
		begin
		smp_cnt <= 0;
		rxd_cnt <= 0;
		rxd_state <= R_IDLE;
		end
	else 
		case(rxd_state)
		R_IDLE:		//Wait for start bit
			begin
			rxd_cnt <= 0;
			smp_cnt <= 0;
			if(rxd_sync == 1'b0)			//uart rxd start bit
				rxd_state <= R_START;
			else
				rxd_state <= R_IDLE;
			end
		R_START:
			begin
			if(clken_16bps == 1)			//clk_bps * 16
				begin
				smp_cnt <= smp_cnt + 1'b1;
				if(smp_cnt == SMP_CENTER && rxd_sync != 1'b0)	//invalid data	
					begin
					rxd_cnt <= 0;
					rxd_state <= R_IDLE;
					end
				else if(smp_cnt == SMP_TOP)	//Count for 16 clocks
					begin
					rxd_cnt <= 1;
					rxd_state <= R_SAMPLE;	//start mark bit is over
					end
				else
					begin
					rxd_cnt <= 0;
					rxd_state <= R_START;	//wait start mark bit over
					end
				end
			else							//invalid data
				begin
				smp_cnt <= smp_cnt;
				rxd_state <= rxd_state;
				end
			end
		R_SAMPLE:	//Sample 8 bit of Uart: {LSB, MSB}
			begin
			if(clken_16bps == 1)			//clk_bps * 16
				begin
				smp_cnt <= smp_cnt + 1'b1;
				if(smp_cnt == SMP_TOP)
					begin
					if(rxd_cnt < 4'd8)		//Totally 8 data
						begin
						rxd_cnt <= rxd_cnt + 1'b1;
						rxd_state <= R_SAMPLE;
						end
					else
						begin
						rxd_cnt <= 4'd9;	//Turn of stop bit
						rxd_state <= R_STOP;
						end
					end
				else
					begin
					rxd_cnt <= rxd_cnt;
					rxd_state <= rxd_state;
					end
				end
			else
				begin
				smp_cnt <= smp_cnt;
				rxd_cnt <= rxd_cnt;
				rxd_state <= rxd_state;
				end
			end
		R_STOP:
			begin
			if(clken_16bps == 1)		//clk_bps * 16
				begin
				smp_cnt <= smp_cnt + 1'b1;
				if(smp_cnt == SMP_TOP)
					begin
					rxd_state <= R_IDLE;
					rxd_cnt <= 0;		//Stop data bit is done
					end
				else
					begin
					rxd_cnt <= 9;		//Stop data bit
					rxd_state <= R_STOP;
					end
				end
			else
				begin
				smp_cnt <= smp_cnt;
				rxd_cnt <= rxd_cnt;
				rxd_state <= rxd_state;
				end
			end
				
		endcase
end

//----------------------------------
//uart data receive in center point
reg	[7:0]	rxd_data_r;
reg [7:0]	rxd_data;
always@(posedge clk or negedge rst_n)
begin
	if(rst_n)
		rxd_data_r <= 0;
	else if(rxd_state == R_SAMPLE)
		begin
		if(clken_16bps == 1 && smp_cnt == SMP_CENTER)	//sample center point
			case(rxd_cnt)
			4'd1:	rxd_data_r[0] <= rxd_sync;
			4'd2:	rxd_data_r[1] <= rxd_sync;
			4'd3:	rxd_data_r[2] <= rxd_sync;
			4'd4:	rxd_data_r[3] <= rxd_sync;
			4'd5:	rxd_data_r[4] <= rxd_sync;
			4'd6:	rxd_data_r[5] <= rxd_sync;
			4'd7:	rxd_data_r[6] <= rxd_sync;
			4'd8:	rxd_data_r[7] <= rxd_sync;
			default:;
			endcase
		else
			rxd_data_r <= rxd_data_r;
		end
	else if(rxd_state == R_STOP)
		rxd_data_r <= rxd_data_r;
	else
		rxd_data_r <= 0;
end

//----------------------------------
//update uart receive data and receive flag signal
reg rxd_flag;
always@(posedge clk or negedge rst_n)
begin
	if(rst_n)
		begin
		rxd_data <= 0;
		rxd_flag <= 0;
		end
	else if(clken_16bps == 1 &&  rxd_cnt == 4'd9 && smp_cnt == SMP_TOP)	//Start + 8 Bit + Stop Bit
		begin
		rxd_data <= rxd_data_r;
		rxd_flag <= 1;
		end
	else
		begin
		rxd_data <= rxd_data;
		rxd_flag <= 0;
		end
end
//------------
//ת32
reg [3:0] state;
reg [31:0] s_rxd_data;
always@(posedge clk or negedge rst_n)
begin
	if(rst_n)
	begin
		state<=0;
		s_flag<=0;
		s_rxd_data[31:0]<=32'b0;
		m_rxd_data[31:0]<=32'b0;
	end
	else
	begin
		case(state)
		4'd0:	begin
					state<=state+1;
					s_flag<=0;
					s_rxd_data[31:0]<=32'b0;
					m_rxd_data[31:0]<=m_rxd_data [31:0];
				end
		4'd1:	if(rxd_flag)
				begin
						s_rxd_data[7:0]<=rxd_data;
						state<=state+1;
				end
				else	
					state<=state;
		4'd2:	if(rxd_flag)
					begin
						s_rxd_data[15:8]<=rxd_data;
						state<=state+1;
					end
				else
					state<=state;
		4'd3:	if(rxd_flag)
					begin
						s_rxd_data[23:16]<=rxd_data;
						state<=state+1;
					end
				else
					state<=state;
		4'd4:	if(rxd_flag)
					begin
						s_rxd_data[31:24]<=rxd_data;
						state<=state+1;
					end
				else
					state<=state;
		4'd5:	begin
					m_rxd_data [31:0]<=s_rxd_data[31:0];
					s_flag<=1;
					state<=0;
				end
		endcase		
	end
	
end
endmodule
