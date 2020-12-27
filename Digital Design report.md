# 数字逻辑实验报告  ——VGA显示



___小组名：verigood___

***成员    李怀武 : 11911425  陈桂凡：11910503 田荫熙：21990006***

[TOC]



##  1. 开发计划

#### 任务划分：

* 李怀武（40%）图形图像存储与显示，BRAM，绘图命令。
* 田荫熙（40%）串口，顶层文件，分辨率。

* 陈桂凡（20%）图形算法，数码显示管。

#### 进度安排：

*  十一周：查找资料，自学时钟分频、VGA显示原理、verilog高级语法，完成了第一版彩条显示。
*  十二周：debug，debug，debug，最后确定是 vga-hdmi 转换线的问题。
*  十三周：初步实现串口命令，实现了开发板与电脑的异步有线通信，并实现了8位二进制的数据环回。
*  十四周：串口实现32位二进制数打包，VGA显示图形，图形绘制，BRAM可储存图形与图片，并可调整分辨率。



 ## 2. 设计

#### 需求分析：

​	` 需求：通过串口命令，控制图形的重复绘制、图片的显示。`

###### 	串口命令：

​	为了实现开发板与电脑通信，有并行和串行两种模式，并行发送数据快但需要消耗大量引脚，而本次实验并不需要发送大量数据故对速度无特殊需求，采取虽然慢但只需要两个管脚的串行通信，对应开发板RX，TX。在串口通信中不仅实现电脑对开发板通信，也实现了开发板对电脑通信，即双向通信，目的在于验证发送接收过程中有无数据丢失、畸变现象。

###### 	重复绘图 与 图片显示 BRAM：

​    重复绘图需要将之前已绘制的图形保存下来，开发板的内存借以实现，在BRAM里按开辟一块内存，位宽为图像分辨率，深度为RGB宽度，重复绘图只需要修改对应位置的颜色数据即可。而图片显示更为简单，只需要将其颜色数据依次放入BRAM。

###### 	串口命令控制显示 :

​    通信协议如下：

​	共八位16进制数，第一位代表图形类型，第二至四位代表填充颜色，其余位代表各图形对应参数。

###### 	分辨率 ：

​	分辨率需要更改行列显示参数，参数可通过计算、查找资料得到，拨码开关控制分辨率切换，一个七段数码管将显示对应分辨率。

###### 	小结 ：

 	输入：系统时钟 ，复位信号 ，拨码开关（控制分辨率） ，串口RX。

​	 输出： 串口TX，VGA行同步、列同步信号、三组颜色信号，七段数码管。



#### 系统结构图 及 执行流程 ：

![image-20201226210046054](C:\Users\tianyinxi\AppData\Roaming\Typora\typora-user-images\image-20201226210046054.png)



| 模块        |    功能    |
| ----------- | :--------: |
| uart32      |  串口通信  |
| u_selection | 分辨率切换 |
| u_colorbar  |  vga显示   |



| 接口      |               功能               |
| --------- | :------------------------------: |
| sele      |          分辨率切换信号          |
| sys_clk   |   时钟，在每个子模块内进行分频   |
| rxd       |         串口接收数据引脚         |
| sys_rst_n |       复位信号，高电平有效       |
| s_flag    | 标志位，每收到一次数据，将其拉高 |
| data      |         串口接收到的数据         |
| txd       |        串口将要发送的数据        |



#### 子模块 ：

##### colorbar :

![image-20201226211512948](C:\Users\tianyinxi\AppData\Roaming\Typora\typora-user-images\image-20201226211512948.png)

##### 

###### u_vga_driver :

==代码==

```verilog
module vga_driver(
        input sys_clk,              //系统时钟100Mhz
        input vga_clk25,            //25Mhz
        input vga_clk50,            //50Mhz
        input sys_rst_n,            //复位
        input [3:0] sele,           //分辨率
        input [11:0] pixel_data,    //颜色数据
        
        output vga_hs,              //行场同步
        output vga_vs,
        output reg[10:0] H_DISP,
        output reg[10:0] V_DISP,
        output [11:0] vga_rgb,      //输出到显示屏
        output [10:0] pixel_xpos,   //坐标
        output [10:0] pixel_ypos,
        output reg vga_clk_cur
    );
    reg [10:0] H_TOTAL; 
    reg [10:0] H_FRONT; //行显示前沿
    reg [10:0] H_SYNC;
    reg [10:0] V_TOTAL; 
    reg [10:0] V_FRONT; //列显示前沿    
    reg [10:0] V_SYNC;
    reg [10:0] H_BACK;  //行显示后沿
    reg [10:0] V_BACK;  //列显示后沿
    //分辨率对应参数
    always@(posedge sys_clk) begin
        casex(sele)
        default: //640 * 480
        begin
            H_TOTAL <= 11'd800;
            H_DISP<=11'd640;
            H_FRONT<=11'd16;
            H_SYNC<=11'd96;
            H_BACK<=11'd48;
            V_TOTAL<=11'd525;
            V_DISP<=11'd480;
            V_FRONT<=11'd10;
            V_SYNC<=11'd2;
            V_BACK<=11'd33;
            vga_clk_cur<=vga_clk25;
        end
        4'b0001:
        begin  //800 * 600
            H_TOTAL<=11'd1056;
            H_DISP<=11'd800;
            H_FRONT<=11'd16;
            H_SYNC<=11'd80;
            H_BACK<=11'd160;
            V_TOTAL<=11'd625;
            V_DISP<=11'd600;
            V_FRONT<=11'd1;
            V_SYNC<=11'd3;
            V_BACK<=11'd21;
            vga_clk_cur<=vga_clk50;
        end
        endcase
    end
    
    reg [10:0] cnt_h;
    reg [10:0] cnt_v;
    
    wire vga_en;
    wire data_req;
            
    //驱动显示
    assign vga_rgb=vga_en ?pixel_data:12'd0;
    
    assign vga_hs =(cnt_h <= H_SYNC - 1'b1) ? 1'b0 :1'b1;
    
    assign vga_vs =(cnt_v <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;
    
    assign vga_en =(((cnt_h >= H_SYNC+H_BACK)&&(cnt_h < H_SYNC+H_BACK+H_DISP))
           &&((cnt_v >= V_SYNC+V_BACK)&&(cnt_v < V_SYNC+V_BACK+V_DISP)))? 1'b1:1'b0;
           
    assign data_req=(((cnt_h >= H_SYNC+H_BACK-1'b1)&&(cnt_h < H_SYNC+H_BACK+H_DISP-1'b1))
           &&((cnt_v >= V_SYNC+V_BACK)&&(cnt_v < V_SYNC+V_BACK+V_DISP)))? 1'b1:1'b0;
           
    assign pixel_xpos =data_req ?(cnt_h -(H_SYNC +H_BACK-1'b1)) :11'd0;
    
    assign pixel_ypos =data_req ?(cnt_v -(V_SYNC +V_BACK-1'b1)) : 11'd0;
    
    //行扫描
    always @(posedge vga_clk_cur or negedge sys_rst_n) begin         
        if (sys_rst_n)
            cnt_h <= 11'd0;                                  
        else begin
            if(cnt_h < H_TOTAL - 1'b1)                                               
                cnt_h <= cnt_h + 1'b1;                               
            else 
                cnt_h <= 11'd0;  
        end
    end
    
    //列扫描
    always @(posedge vga_clk_cur or negedge sys_rst_n) begin         
        if (sys_rst_n)
            cnt_v <= 11'd0;                                  
        else if(cnt_h == H_TOTAL - 1'b1) begin
            if(cnt_v < V_TOTAL - 1'b1)                                               
                cnt_v <= cnt_v + 1'b1;                               
            else 
                cnt_v <= 11'd0;  
        end
    end
    
endmodule
```




![image-20201226211638432](C:\Users\tianyinxi\AppData\Roaming\Typora\typora-user-images\image-20201226211638432.png)



###### display :

==代码==

```verilog
module bar_display
(
    input [10:0] pixel_xpos,//x坐标
    input [10:0] pixel_ypos,//y坐标
	input sys_rst_n,vga_clk,//时钟
	input [10:0] H_DISP,V_DISP,
	input [31:0] data,
	output reg[15:0]  led,
	input en,
	output reg[11:0]  pixel_data
);


//颜色数据
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

//各种图形
assign point=(((pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY))<=10);
assign rec=((pixel_xpos>=(STARTX))&&(pixel_xpos<=(ENDX))&&(pixel_ypos>=(STARTY))&&(pixel_ypos<=(ENDY))) ;
assign circle=((pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY)<(0-RADIUS)*(0-RADIUS));
assign line=(((pixel_xpos>=STARTX)&&(pixel_xpos<=ENDX))&&((pixel_ypos<=(pixel_xpos+WIDTH))&&(pixel_ypos>=(pixel_xpos-WIDTH))));
assign addr=((pixel_ypos*H_DISP)+pixel_xpos);
assign rim=(pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY)<=(ENDX-0)*(ENDX-0)&&(pixel_xpos-STARTX)*(pixel_xpos-STARTX)+(pixel_ypos-STARTY)*(pixel_ypos-STARTY)>=(ENDY-0)*(ENDY-0);
assign triangle = (pixel_xpos>STARTX)&&(pixel_ypos>STARTY)&&(pixel_xpos+pixel_ypos)<ENDX;

//处理串口发送的32位数据
always @(posedge en) begin
    	if(sys_rst_n);
      	else begin 
         SHAPE <=data[7:4];
         COLOR <={data[3:0],data[15:12],data[11:8]};
         STARTX <={6'd0,data[23:20]}*100;
         STARTY <={6'd0,data[19:16]}*100;
         case(SHAPE)     
                     4'd1:;
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
                     4'd5 :;
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
            
            
            
//内存读取
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


```



##### uart32 :

![image-20201226213348118](C:\Users\tianyinxi\AppData\Roaming\Typora\typora-user-images\image-20201226213348118.png)

###### uart_rx :

```verilog
module uart_rx(
	input				clk,
	input				rst_n,
	input				clken_16bps,//clk_bps * 16
	
	input			      rxd,		
	output	reg	[31:0]	m_rxd_data,	//uart data receive
	output	reg			s_flag	//uart data receive done 
	
    );
	
	
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
//转32
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

```

#### 约束文件 ：

```verilog
set_property PACKAGE_PIN Y18 [get_ports sys_clk]
set_property PACKAGE_PIN P1 [get_ports sys_rst_n]


set_property PACKAGE_PIN Y19 [get_ports rxd]
set_property PACKAGE_PIN V18 [get_ports txd]
set_property PACKAGE_PIN H20 [get_ports {vga_rgb[0]}]
set_property PACKAGE_PIN G20 [get_ports {vga_rgb[1]}]
set_property PACKAGE_PIN K21 [get_ports {vga_rgb[2]}]
set_property PACKAGE_PIN K22 [get_ports {vga_rgb[3]}]
set_property PACKAGE_PIN H17 [get_ports {vga_rgb[4]}]
set_property PACKAGE_PIN H18 [get_ports {vga_rgb[5]}]
set_property PACKAGE_PIN J22 [get_ports {vga_rgb[6]}]
set_property PACKAGE_PIN H22 [get_ports {vga_rgb[7]}]
set_property PACKAGE_PIN M21 [get_ports vga_hs]
set_property PACKAGE_PIN L21 [get_ports vga_vs]
set_property PACKAGE_PIN Y19 [get_ports fpga_rxd]
set_property PACKAGE_PIN V18 [get_ports fpga_txd]
set_property PACKAGE_PIN W4 [get_ports {sele[0]}]
set_property PACKAGE_PIN P4 [get_ports {sele[1]}]
set_property PACKAGE_PIN P5 [get_ports {sele[2]}]
set_property PACKAGE_PIN R1 [get_ports {sele[3]}]
set_property PACKAGE_PIN A21 [get_ports sled]
set_property PACKAGE_PIN F15 [get_ports {cube_data[0]}]
set_property PACKAGE_PIN F13 [get_ports {cube_data[1]}]
set_property PACKAGE_PIN F14 [get_ports {cube_data[2]}]
set_property PACKAGE_PIN F16 [get_ports {cube_data[3]}]
set_property PACKAGE_PIN E17 [get_ports {cube_data[4]}]
set_property PACKAGE_PIN C14 [get_ports {cube_data[5]}]
set_property PACKAGE_PIN C15 [get_ports {cube_data[6]}]
set_property PACKAGE_PIN E13 [get_ports {cube_data[7]}]
set_property PACKAGE_PIN E19 [get_ports {control[1]}]
set_property PACKAGE_PIN D19 [get_ports {control[2]}]
set_property PACKAGE_PIN F18 [get_ports {control[3]}]
set_property PACKAGE_PIN E18 [get_ports {control[4]}]
set_property PACKAGE_PIN B20 [get_ports {control[5]}]
set_property PACKAGE_PIN A20 [get_ports {control[6]}]
set_property PACKAGE_PIN A18 [get_ports {control[7]}]
set_property PACKAGE_PIN Y9 [get_ports en_pic]
set_property PACKAGE_PIN G17 [get_ports {vga_rgb[8]}]
set_property PACKAGE_PIN G18 [get_ports {vga_rgb[9]}]
set_property PACKAGE_PIN J15 [get_ports {vga_rgb[10]}]
set_property PACKAGE_PIN H15 [get_ports {vga_rgb[11]}]

```

## 3. 测试

 ==无仿真文件==

 ==附测试视频==

## 4. 总结

##### problem and solution ：

* uart通信一次只能接受8个二进制位，用状态转移机将4个8位打包成32位，这样一次可以发送32位数据。

* Bram时序错误，读取地址错误导致显示错位，图片高频率滚动显示。

![image-20201226214247935](C:\Users\tianyinxi\AppData\Roaming\Typora\typora-user-images\image-20201226214247935.png)



* 绘圆时半径使用reg直接与reg相乘导致显示如下图案，将reg数据-0后相乘解决。

![img](file:///C:/Users/TIANYI~1/AppData/Local/Temp/msohtmlclip1/01/clip_image004.jpg)



##### 本系统特色和优化方向 ：

本程序特色在于实现了重复绘图与不同分辨率的切换和串口数据32位的环回发送。

* 由于BRAM内存大小限制，不能完全存储高分辨率图片，只能存放较低分辨率图片，故可改进此功能。

* 串口一次性发送32位数据，虽然在本次实验中够用，但画更为复杂的图形时需要更多位数据。

​         