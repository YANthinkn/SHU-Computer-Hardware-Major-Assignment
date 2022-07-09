module traffic_led( 
    input                  sys_clk   ,    //系统时钟信号
    input                  sys_rst_n ,    //系统复位信号
	 input        [3:0]          key  ,
    
    output       [7:0]     bit       ,    //数码管位选信号
    output       [7:0]     segment   ,    //数码管段选信号
    output	     [23:0]	   led            //LED使能信号
);

//wire define    
wire   [9:0]  n_time;                    //北方向状态剩余时间数据
wire   [9:0]  e_time;                    //东方向状态剩余时间数据
wire   [9:0]  s_time;                    //南方向状态剩余时间数据
wire   [9:0]  w_time;                    //西方向状态剩余时间数据
wire   [9:0]  nl_time;                   //北方向状态剩余时间数据
wire   [9:0]  el_time;                   //东方向状态剩余时间数据
wire   [9:0]  sl_time;                   //南方向状态剩余时间数据
wire   [9:0]  wl_time;                   //西方向状态剩余时间数据    
wire   [3:0]  state  ;                   //交通灯的状态，用于控制LED灯的点亮

state_trans_model u0_state_trans_model(
    .sys_clk                (sys_clk),   
    .sys_rst_n              (sys_rst_n),      
    .n_time                 (n_time),
    .e_time                 (e_time),
	 .s_time                 (s_time),
    .w_time                 (w_time),
	 .nl_time                (nl_time),
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