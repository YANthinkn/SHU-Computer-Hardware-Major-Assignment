module bit_seg_module(
    input                  sys_clk     ,     //系统时钟 
    input                  sys_rst_n   ,     //系统复位 
    input        [9:0]     n_time      ,     //北方向数码管要显示的数值
    input        [9:0]     e_time      ,     //东方向数码管要显示的数值
	 input        [9:0]     s_time      ,     //南方向数码管要显示的数值
    input        [9:0]     w_time      ,     //西方向数码管要显示的数值
    input                  en          ,     //数码管使能信号                                                             
    output  reg  [7:0]     bit         ,     //数码管位选信号
    output  reg  [7:0]     segment           //数码管段选信号,包含小数点
);
//parameter define
parameter  state_count = 25000;              //计数0.0001ms的计数深度

//reg define 
reg    [15:0]             count_s;           //计数1ms的计数器(仿真可调整)
reg    [2:0]              count_state;       //用于切换要点亮数码管
reg    [3:0]              num;               //数码管要显示的数据

//wire define
wire   [3:0]              data_n_0;         //北方向数码管的十位
wire   [3:0]              data_n_1;         //北方向数码管的个位
wire   [3:0]              data_e_0;         //东方向数码管的十位
wire   [3:0]              data_e_1;         //东方向数码管的个位
wire   [3:0]              data_s_0;         //南方向数码管的十位
wire   [3:0]              data_s_1;         //南方向数码管的个位
wire   [3:0]              data_w_0;         //西方向数码管的十位
wire   [3:0]              data_w_1;         //西方向数码管的个位

//主程序               
assign  data_n_0   = n_time / 10;          //取出北向时间数据的十位
assign  data_n_1   = n_time % 10;          //取出北向时间数据的个位
assign  data_e_0   = e_time / 10;          //取出东向时间数据的十位
assign  data_e_1   = e_time % 10;          //取出东向时间数据的个位
assign  data_s_0   = s_time / 10;          //取出南向时间数据的十位
assign  data_s_1   = s_time % 10;          //取出南向时间数据的个位
assign  data_w_0   = w_time / 10;          //取出西向时间数据的十位
assign  data_w_1   = w_time % 10;          //取出西向时间数据的个位

//计数0.1ms(非固定依据state_count参数调整)
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        count_s <= 16'b0;
    else if (count_s < state_count - 1'b1)
        count_s <= count_s + 1'b1;
    else
        count_s <= 16'b0;
end 

//计数器，用来切换数码管点亮的8个状态 0.2ms周期(非固定依据state_count参数调整)
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        count_state <= 2'd0;
    else  if (count_s == state_count - 1'b1)
        count_state <= count_state + 1'b1;
    else
        count_state <= count_state;
end 

//先显示北方向数码管的十位，然后是个位。再依次显示东南西方向数码管的十位、个位
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        bit  <= 8'b11111111;
        num  <= 4'b0;
    end 
    else if(en) begin       
        case (count_state) 
            3'd0 : begin     
                bit <= 8'b11111110;              //驱动北方向数码管的十位  
                num <= data_n_0;
            end       
            3'd1 : begin     
                bit <= 8'b11111101;              //驱动北方向数码管的个位
                num <= data_n_1;
            end 
            3'd2 : begin 
                bit <= 8'b11111011;              //驱动东方向数码管的十位
                num  <= data_e_0;
            end
            3'd3 : begin 
                bit <= 8'b11110111;              //驱动东方向数码管的个位
                num  <= data_e_1 ;    
            end
				3'd4 : begin     
                bit <= 8'b11101111;              //驱动南方向数码管的十位  
                num <= data_s_0;
            end       
            3'd5 : begin     
                bit <= 8'b11011111;              //驱动南方向数码管的个位
                num <= data_s_1;
            end 
            3'd6 : begin 
                bit <= 8'b10111111;              //驱动西方向数码管的十位
                num  <= data_w_0;
            end
            3'd7 : begin 
                bit <= 8'b01111111;              //驱动西方向数码管的个位
                num  <= data_w_1 ;    
            end
            default : begin     
                bit <= 8'b11111111;                     
                num <= 4'b0;
            end 
        endcase
    end
    else  begin
          bit <= 8'b11111111;
          num <= 4'b0;    
    end
end 

//数码管要显示的数值所对应的段选信号      
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) 
        segment <= 8'b0; 
    else begin
        case (num)              
            4'd0 :     segment <= 8'b11000000;                                                        
            4'd1 :     segment <= 8'b11111001;                            
            4'd2 :     segment <= 8'b10100100;                            
            4'd3 :     segment <= 8'b10110000;                            
            4'd4 :     segment <= 8'b10011001;                            
            4'd5 :     segment <= 8'b10010010;                            
            4'd6 :     segment <= 8'b10000010;                            
            4'd7 :     segment <= 8'b11111000;      
            4'd8 :     segment <= 8'b10000000;      
            4'd9 :     segment <= 8'b10010000;    
            default :  segment <= 8'b11000000;
        endcase
    end 
end

endmodule