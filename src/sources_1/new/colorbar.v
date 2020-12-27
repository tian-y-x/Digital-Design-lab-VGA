`timescale 1ns / 1ps

//top of display
module colorbar
    (
        input s_flag,   
        input[3:0] sele,
        input sys_clk,
        input sys_rst_n,
        input [31:0] data,
        
        output vga_hs,
        output vga_vs,
        output [11:0] vga_rgb,
        output  [15:0] led
    );
    wire rst_n_w;
    wire [11:0] pixel_data_w;
    wire [10:0] pixel_xpos_w;
    wire [10:0] pixel_ypos_w;
    assign rst_n_w =sys_rst_n;
    
    wire[10:0] H_DISP;
    wire[10:0] V_DISP;
    wire       vga_clk_cur;
    
    wire vga_clk_w25;
    wire vga_clk_w50;
    clk_wiz_0 u_vga_pll
    (
    .clk_in1  (sys_clk),
    .clk_out1 (vga_clk_w25),
    .clk_out2 (vga_clk_w50)
    );   
        
    vga_driver u_vga_driver
    (
    .sele       (sele),
    .H_DISP     (H_DISP),
    .V_DISP     (V_DISP),
    .sys_clk    (sys_clk),
    .vga_clk25  (vga_clk_w25),
    .vga_clk50  (vga_clk_w50),
    .sys_rst_n  (rst_n_w),
    .vga_hs     (vga_hs),
    .vga_vs     (vga_vs),
    .vga_rgb    (vga_rgb),
    .pixel_data (pixel_data_w),
    .vga_clk_cur(vga_clk_cur),
    .pixel_xpos (pixel_xpos_w),
    .pixel_ypos (pixel_ypos_w)
    );
    bar_display u_vga_display
    (
    .led(led),
    .en(s_flag),
    .data(data),
    .H_DISP(H_DISP),
    .V_DISP(V_DISP),
    .sys_rst_n (rst_n_w),
    .vga_clk(vga_clk_cur),
    .pixel_xpos (pixel_xpos_w),
    .pixel_ypos (pixel_ypos_w),
    .pixel_data (pixel_data_w)
    );
     
endmodule
