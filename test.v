`timescale 1ns/1ns // 时延单位为1ms，时延精度为1ns

module test;


//wire define    
wire   [9:0]  n_time;                    //北方向状态剩余时间数据
wire   [9:0]  e_time;                    //东方向状态剩余时间数据
wire   [9:0]  s_time;                    //南方向状态剩余时间数据
wire   [9:0]  w_time;                    //西方向状态剩余时间数据
wire   [9:0]  nl_time;                    //北方向状态剩余时间数据
wire   [9:0]  el_time;                    //东方向状态剩余时间数据
wire   [9:0]  sl_time;                    //南方向状态剩余时间数据
wire   [9:0]  wl_time;                    //西方向状态剩余时间数据    
wire   [3:0]  state  ;                    //交通灯的状态，用于控制LED灯的点亮



// 初始化信号
wire [7:0]     bit; 
wire [7:0]     segment;
wire [23:0]	   led;
reg sys_clk;
reg sys_rst_n;
reg [3:0] key;

initial begin
sys_clk=1'b0;
sys_rst_n=1'b0;
#20 sys_rst_n=1'b1;
key=4'b1111;

#120000 sys_rst_n=1'b1;


#80000 key=4'b0000;
#80000 key=4'b1110;
#80000 key=4'b1101;
#80000 key=4'b1011;

#80000 sys_rst_n=1'b0;
end

always #10 sys_clk = ~sys_clk; // 系统时钟周期为20ns



state_trans_model #(.WIDTH(25))u0_state_trans_model(
    .sys_clk                (sys_clk),   
    .sys_rst_n              (sys_rst_n),      
    .n_time                 (n_time),
    .e_time                 (e_time),
	 .s_time                 (s_time),
    .w_time                 (w_time),
    .nl_time                 (nl_time),
    .el_time                 (el_time),
	 .sl_time                 (sl_time),
    .wl_time                 (wl_time),
    .state                  (state)
);

//数码管显示模块	
bit_seg_module    u1_bit_seg_module(
    .sys_clk                (sys_clk)  ,
    .sys_rst_n              (sys_rst_n),
    .n_time                 (n_time),
    .e_time                 (e_time),
	 .s_time                 (s_time),
    .w_time                 (w_time),
    .en                     (1'b1),   
    .bit                    (bit), 
    .segment                (segment)
);

//led灯控制模块
led_module   u2_led_module(
    .sys_clk                (sys_clk  ),
    .sys_rst_n              (sys_rst_n),
    .state                  (state    ),
    .led                    (led      ),
	 .key                    (key      )
); 
   
endmodule        