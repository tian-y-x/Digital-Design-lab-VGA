`timescale 1ns / 1ps

module ttop(
    input           sys_clk,         
    input           sys_rst_n,        
        
    input[3:0]      sele,       //control resolution
    input           rxd,        //uart receive site
    output          txd,        //uart send site
    output[7:0]     control,    //cube site
    output[7:0]     cube_data,  //cube site
    output          sled,       //led of resolution
    
    output          vga_hs,
    output          vga_vs,
    output[11:0]    vga_rgb
    );
    wire[31:0]     data;        //the data from computer through uart
    wire           s_flag;      //posedge of receive data
    
    //resolution control 640*480 @60HZ   800*600 @75HZ
    selection u_selection
    (
        .clock      (sys_clk),
        .sys_rst_n  (sys_rst_n),
        .sele       (sele),
        .control    (control), 
        .cube_data  (cube_data),
        .sled       (sled)
    );
    //top of uart
    UART_Test uart32
    (
        .clk        (sys_clk),		         	
        .rst_n      (sys_rst_n),   
        .m_rxd_data (data),         
        
        .s_flag     (s_flag),
        .fpga_rxd   (rxd),        
        .fpga_txd   (txd)
    );
    //top of display
    colorbar u_colorbar
    (
        .s_flag     (s_flag),
        .data       (data),
        .sele       (sele),
        .sys_clk    (sys_clk),
        .sys_rst_n  (sys_rst_n),
        .vga_hs     (vga_hs),
        .vga_vs     (vga_vs),
        .vga_rgb    (vga_rgb)
    );
    
endmodule
