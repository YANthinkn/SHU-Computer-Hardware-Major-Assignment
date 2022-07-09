module  state_trans_model(
    //input
    input               sys_clk   ,        //系统时钟
    input               sys_rst_n ,        //系统复位

    output  reg  [3:0]  state     ,        //交通灯的状态，用于控制LED灯的点亮
    output  reg  [9:0]  n_time    ,        //交通灯北向数码管要显示的时间数据
    output  reg  [9:0]  e_time    ,        //交通灯东向数码管要显示的时间数据
	 output  reg  [9:0]  s_time    ,        //交通灯南向数码管要显示的时间数据
    output  reg  [9:0]  w_time    ,        //交通灯西向数码管要显示的时间数据
	 output  reg  [9:0]  nl_time    ,        //交通灯北向数码管要显示的时间数据
    output  reg  [9:0]  el_time    ,        //交通灯东向数码管要显示的时间数据
	 output  reg  [9:0]  sl_time    ,        //交通灯南向数码管要显示的时间数据
    output  reg  [9:0]  wl_time             //交通灯西向数码管要显示的时间数据
    );
  
//parameter define
parameter  TIME_LED_NSY    = 3;              //黄灯发光的时间
parameter  TIME_LED_NSR    = 60;              //红灯发光的时间
parameter  TIME_LED_NSG    = 27;             //绿灯发光的时间
parameter  TIME_LED_WEY    = 3;              //黄灯发光的时间
parameter  TIME_LED_WER    = 60;             //红灯发光的时间
parameter  TIME_LED_WEG    = 27;             //绿灯发光的时间
parameter  WIDTH         = 25000000;        
  
//reg define
reg    [5:0]     time_cnt;                 //产生数码管显示时间的计数器    
reg    [24:0]    t_count;                  //用于产生clk_1hz的计数器
reg              clk_t;                    //1hz时钟

always @(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        t_count <= 25'b0;
		  clk_t <= 1'b0;
	 end
    else if (t_count < WIDTH - 1'b1)begin
        t_count <= t_count + 1'b1;
		  clk_t <=  clk_t;
	 end
    else begin
        t_count <= 25'b0;
		  clk_t <= ~ clk_t;
	 end
end 

//切换交通信号灯工作的8个状态，并产生数码管要显示的时间数据
always @(posedge clk_t or negedge sys_rst_n)begin
    if(!sys_rst_n)begin        
        state <= 4'd0;
        time_cnt <= TIME_LED_NSG ;            //状态1持续的时间
    end 
    else begin
        case (state)
            4'b0000:  begin                    //状态1 南北为绿灯，东西为黄灯
				    n_time  <= time_cnt - 1'b1;    //绿灯倒计时             
                e_time  <= time_cnt + TIME_LED_NSY*2+TIME_LED_NSG- 1'b1 ;     //红灯倒计时60S           
	             s_time  <= time_cnt - 1'b1;       //绿灯倒计时        
                w_time  <= time_cnt + TIME_LED_NSY*2+TIME_LED_NSG- 1'b1 ; 
					 nl_time  <= time_cnt + TIME_LED_NSY- 1'b1;     //红灯倒计时30s     
                el_time  <= time_cnt + TIME_LED_NSY*2+TIME_LED_NSG+TIME_LED_WEG+TIME_LED_WEY- 1'b1 ;      //红灯倒计时90s        
	             sl_time  <= time_cnt + TIME_LED_NSY - 1'b1;            
                wl_time  <= time_cnt + TIME_LED_NSY*2+TIME_LED_NSG+TIME_LED_WEG+TIME_LED_WEY- 1'b1 ;    
                if (time_cnt > 1)begin      //time_cnt等于1的时候切换状态，转换为黄灯
                    time_cnt <= time_cnt - 1'b1;
                    state <= state;
                end 
                else begin
                    time_cnt <= TIME_LED_NSY; //状态2持续的时间 //南北直行变为黄灯
                    state <= 4'b0001;         //切换到状态2
						  n_time  <= TIME_LED_NSY;                 
                    e_time  <= TIME_LED_WER-TIME_LED_NSG;   //等待红灯33s            
	                 s_time  <= TIME_LED_NSY;              
                    w_time  <= TIME_LED_WER-TIME_LED_NSG;   //南北黄灯，东西为红灯等待南北左转绿灯与红灯
						  nl_time  <= TIME_LED_NSY;                 //等待与南北黄灯相同时间的红灯
                    el_time  <= TIME_LED_WER+TIME_LED_NSY;          //等待南北左转30s+东西直行30s+南北直行3s黄灯     
	                 sl_time  <= TIME_LED_NSY;              
                    wl_time  <= TIME_LED_WER+TIME_LED_NSY; 
                end 
            end 
            4'b0001:  begin                   //状态2 南北直行为黄灯，左转为红灯；东西直行左转为红灯
                n_time  <= time_cnt - 1'b1;                 
                e_time  <= TIME_LED_NSG+TIME_LED_NSY*2+time_cnt - 1'b1;    //等待33s红灯         
	             s_time  <= time_cnt - 1'b1;               
                w_time  <= TIME_LED_NSG+TIME_LED_NSY*2+time_cnt - 1'b1;  
					 nl_time  <= time_cnt- 1'b1;     //左转等待直行黄灯变绿灯     
                el_time  <= time_cnt + TIME_LED_NSY+TIME_LED_NSG+TIME_LED_WEG+TIME_LED_WEY- 1'b1 ;      //等待63s红灯        
	             sl_time  <= time_cnt- 1'b1;            
                wl_time  <= time_cnt + TIME_LED_NSY+TIME_LED_NSG+TIME_LED_WEG+TIME_LED_WEY- 1'b1 ;
                if (time_cnt > 1)begin
                    time_cnt <= time_cnt - 1'b1;
                    state <= state;
                end 
                else begin
                    time_cnt <= TIME_LED_NSG; //状态3持续的时间 南北左转绿灯
                    state <= 4'b0010;         //切换到状态3		  
						  e_time  <= TIME_LED_NSY+TIME_LED_NSG ;        //等待30s红灯      
                    s_time  <= TIME_LED_NSY+TIME_LED_NSG+TIME_LED_NSR;   //等待90s红灯           
	                 w_time  <= TIME_LED_NSY+TIME_LED_NSG ;                
                    n_time  <= TIME_LED_NSY+TIME_LED_NSG+TIME_LED_NSR; 
						  nl_time  <= TIME_LED_NSG;                 //绿灯
                    el_time  <= TIME_LED_WER;               //等待60s红灯
	                 sl_time  <= TIME_LED_NSG;              
                    wl_time  <= TIME_LED_WER; 
                end 
            end 
            4'b0010:  begin                   //状态3 南北直行红灯，左转绿灯；东西都为红灯 
                e_time  <= TIME_LED_NSY+time_cnt - 1'b1;         //30S倒计时        
                s_time  <= TIME_LED_WER+time_cnt + TIME_LED_NSY - 1'b1;         //90S倒计时      
	             w_time  <= TIME_LED_NSY+time_cnt - 1'b1;            
                n_time  <= TIME_LED_WER+time_cnt + TIME_LED_NSY - 1'b1;
					 nl_time  <= time_cnt- 1'b1;     //绿灯27s    
                el_time  <= time_cnt+TIME_LED_NSY+TIME_LED_WEY+TIME_LED_WEG- 1'b1 ;         //东西左转等60s
	             sl_time  <= time_cnt- 1'b1;            
                wl_time  <= time_cnt+TIME_LED_NSY+TIME_LED_WEY+TIME_LED_WEG- 1'b1 ; 
                if (time_cnt > 1)begin
                    time_cnt <= time_cnt - 1'b1;
                    state <= state;
                end 
                else begin
                    time_cnt <= TIME_LED_NSY; //状态4持续的时间  南北左转黄灯
                    state <= 4'b0011;         //切换到转态4						  
						  e_time  <= TIME_LED_NSY;                 //3S倒计时为绿灯
                    s_time  <= TIME_LED_NSY+TIME_LED_WER;               //63S红灯倒计时
	                 w_time  <= TIME_LED_NSY;               
                    s_time  <= TIME_LED_NSY+TIME_LED_WER; 
						  nl_time  <= TIME_LED_NSY;                 //3S黄灯倒计时
                    el_time  <= TIME_LED_NSY+TIME_LED_WEY+TIME_LED_WEG;               //33S红灯倒计时
	                 sl_time  <= TIME_LED_NSY;              
                    wl_time  <= TIME_LED_NSY+TIME_LED_WEY+TIME_LED_WEG;    
                end 
            end 
            4'b0011:  begin                   //状态4  南北左转黄灯
                e_time  <= time_cnt - 1'b1;                 
                s_time  <= TIME_LED_NSR+time_cnt - 1'b1;           //南北等待63s红灯    
	             w_time  <= time_cnt - 1'b1;            
                n_time  <= TIME_LED_NSR+time_cnt - 1'b1; 
					 el_time  <= TIME_LED_WEY+ TIME_LED_WEG+time_cnt - 1'b1;         //30S倒计时        
                sl_time  <= time_cnt - 1'b1;         //3S倒计时      
	             wl_time  <= TIME_LED_WEY+ TIME_LED_WEG+time_cnt - 1'b1;                
                nl_time  <= time_cnt - 1'b1; 
                if (time_cnt > 1)begin
                    time_cnt <= time_cnt - 1'b1;
                    state <= state;
                end 
                else begin
                    time_cnt <= TIME_LED_WEG;
                    state <= 4'b0100;          //切换到状态5 东西直行绿灯
						  n_time  <= TIME_LED_NSR;               //南北直行等待60s  
                    e_time  <= TIME_LED_WEG;           //东西绿灯    
	                 s_time  <= TIME_LED_NSR;               
                    w_time  <= TIME_LED_WEG; 
						  nl_time  <= TIME_LED_WER+TIME_LED_NSG+TIME_LED_NSY;                 //等待90s
                    el_time  <= TIME_LED_WEY+TIME_LED_WEG;               //30S红灯倒计时
	                 sl_time  <= TIME_LED_WER+TIME_LED_NSG+TIME_LED_NSY;               
                    wl_time  <= TIME_LED_WEY+TIME_LED_WEG;   
                end 
            end		
	            4'b0100:  begin                   //状态5  南北都为红灯；东西直行绿灯，左转红灯
                e_time  <= time_cnt - 1'b1;                 
                s_time  <= TIME_LED_WEY+TIME_LED_WEG+TIME_LED_WEY+time_cnt - 1'b1;           //南北等待60s红灯    
	             w_time  <= time_cnt - 1'b1;            
                n_time  <= TIME_LED_WEY+TIME_LED_WEG+TIME_LED_WEY+time_cnt - 1'b1; 
					 el_time  <= TIME_LED_WEY+time_cnt - 1'b1;         //30S倒计时        
                sl_time  <= TIME_LED_NSR+TIME_LED_WEY+time_cnt - 1'b1;         //90S倒计时      
	             wl_time  <= TIME_LED_WEY+time_cnt - 1'b1;                
                nl_time  <= TIME_LED_NSR+TIME_LED_WEY+time_cnt - 1'b1;   
                if (time_cnt > 1)begin
                    time_cnt <= time_cnt - 1'b1;
                    state <= state;
                end 
                else begin
                    time_cnt <= TIME_LED_WEY;
                    state <= 4'b0101;          //切换到状态6 南北都为红灯；东西直行黄灯，左转红灯
						  n_time  <= TIME_LED_WEG+TIME_LED_WEY*2;               //南北直行等待33s  
                    e_time  <= TIME_LED_WEY;           //东西直行黄灯    
	                 s_time  <= TIME_LED_NSR;               
                    w_time  <= TIME_LED_WEY; 
						  nl_time  <= TIME_LED_NSR+TIME_LED_WEY;                 //等待63s
                    el_time  <= TIME_LED_WEY;               //3S红灯倒计时
	                 sl_time  <= TIME_LED_NSR+TIME_LED_WEY;              
                    wl_time  <= TIME_LED_WEY;   
                end 
            end	
	            4'b0101:  begin                   //状态6  南北都为红灯；东西直行黄灯，左转红灯
                e_time  <= time_cnt - 1'b1;          //直行黄灯3s倒计时       
                s_time  <= TIME_LED_WEG+TIME_LED_WEY+time_cnt - 1'b1;           //南北等待33s红灯    
	             w_time  <= time_cnt - 1'b1;            
                n_time  <= TIME_LED_WEG+TIME_LED_WEY+time_cnt - 1'b1;   
					 el_time  <= time_cnt - 1'b1;         //3S倒计时        
                sl_time  <= TIME_LED_NSR+time_cnt - 1'b1;          //63S倒计时      
	             wl_time  <= time_cnt - 1'b1;            
                nl_time  <= TIME_LED_NSR+time_cnt - 1'b1; 
                if (time_cnt > 1)begin
                    time_cnt <= time_cnt - 1'b1;
                    state <= state;
                end 
                else begin
                    time_cnt <= TIME_LED_WEG;
                    state <= 4'b0110;          //切换到状态7 东西直行红灯，左转绿灯
						  n_time  <= TIME_LED_WEG+TIME_LED_WEY;                 //南北直行等待30s  
                    e_time  <= TIME_LED_WEG+TIME_LED_WEY+TIME_LED_WER;           //红灯90s   
	                 s_time  <= TIME_LED_WEG+TIME_LED_WEY;               
                    w_time  <= TIME_LED_WEG+TIME_LED_WEY+TIME_LED_WER;    
						  nl_time  <= TIME_LED_WEG+TIME_LED_WEY+TIME_LED_NSY+TIME_LED_NSG;                 //等待60s
                    el_time  <= TIME_LED_WEG;              //27s绿灯倒计时
	                 sl_time  <= TIME_LED_WEG+TIME_LED_WEY+TIME_LED_NSY+TIME_LED_NSG;               
                    wl_time  <= TIME_LED_WEG;   
                end 
            end	
	            4'b0110:  begin                   //状态7  东西直行红灯，左转绿灯
                e_time  <= time_cnt - 1'b1;                 
                s_time  <= TIME_LED_WEY+time_cnt - 1'b1;           //南北等待30s红灯    
	             w_time  <= time_cnt - 1'b1;            
                n_time  <= TIME_LED_WEY+time_cnt - 1'b1;  
					 el_time  <= time_cnt - 1'b1;         //绿灯倒计时        
                sl_time  <= TIME_LED_WEY+TIME_LED_NSG+TIME_LED_NSY+time_cnt - 1'b1;         //60S倒计时      
	             wl_time  <= time_cnt - 1'b1;                
                nl_time  <= TIME_LED_WEY+TIME_LED_NSG+TIME_LED_NSY+time_cnt - 1'b1; 
                if (time_cnt > 1)begin
                    time_cnt <= time_cnt - 1'b1;
                    state <= state;
                end 
                else begin
                    time_cnt <= TIME_LED_WEY;
                    state <= 4'b0111;          //切换到状态8 南北都为红灯；东西直行红灯，左转黄灯

						  n_time  <= TIME_LED_WEY;               //南北直行等待3s  
                    e_time  <= TIME_LED_WEG+TIME_LED_WEY;           //东西63s红灯   
	                 s_time  <= TIME_LED_WEY;               
                    w_time  <= TIME_LED_WEG+TIME_LED_WEY;   
						  nl_time  <= TIME_LED_WEY+TIME_LED_NSG+TIME_LED_NSY;                 //等待33s
                    el_time  <= TIME_LED_WEY;               //3s黄灯
	                 sl_time  <= TIME_LED_WEY+TIME_LED_NSG+TIME_LED_NSY;               
                    wl_time  <= TIME_LED_WEY;    
                end 
            end	
	            4'b0111:  begin                   //状态8 南北都为红灯；东西直行红灯，左转黄灯
                e_time  <= TIME_LED_WER+time_cnt - 1'b1;            //东西直行等待63s红灯    
                s_time  <= time_cnt - 1'b1;          //南北等待3s红灯    
	             w_time  <= TIME_LED_WER+time_cnt - 1'b1;             
                n_time  <= time_cnt - 1'b1;
					 el_time  <= time_cnt - 1'b1;        //30S倒计时        
                sl_time  <= TIME_LED_NSY+TIME_LED_NSG+time_cnt - 1'b1;         //3S倒计时      
	             wl_time  <= time_cnt - 1'b1;              
                nl_time  <= TIME_LED_NSY+TIME_LED_NSG+time_cnt - 1'b1;  
                if (time_cnt > 1)begin
                    time_cnt <= time_cnt - 1'b1;
                    state <= state;
                end 
                else begin
                    time_cnt <= TIME_LED_NSG;
                    state <= 4'b0000;          //切换到状态1 南北直行绿灯，左转红灯；东西都为红灯
						  n_time  <= TIME_LED_NSG;               //南北直行  
                    e_time  <= TIME_LED_WER;           //东西等待60s    
	                 s_time  <= TIME_LED_NSG;               
                    w_time  <= TIME_LED_WER; 
						  nl_time  <= TIME_LED_NSG+TIME_LED_NSY;                 //等待30s
                    el_time  <= TIME_LED_WER+TIME_LED_NSY+TIME_LED_NSG;               //90S红灯倒计时
	                 sl_time  <= TIME_LED_NSG+TIME_LED_NSY;               
                    wl_time  <= TIME_LED_WER+TIME_LED_NSY+TIME_LED_NSG;   
                end 
            end				
            default: begin
                state <= 4'b0;
                time_cnt <= TIME_LED_NSG;
				    n_time  <= TIME_LED_NSG;                 
                e_time  <= TIME_LED_WER;               
	             s_time  <= TIME_LED_NSG;              
                w_time  <= TIME_LED_WER;  
					 nl_time  <= TIME_LED_NSG+TIME_LED_NSY;              
                el_time  <= TIME_LED_WER+TIME_LED_NSY+TIME_LED_NSG;    
	             sl_time  <= TIME_LED_NSG+TIME_LED_NSY;               
                wl_time  <= TIME_LED_WER+TIME_LED_NSY+TIME_LED_NSG;   
            end 
        endcase
    end 
end                 

endmodule