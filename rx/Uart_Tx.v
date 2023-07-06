module Uart_Tx
#(
    parameter   START_BIT   =   1,
    parameter   DATA_BITS   =   16,
    parameter   PARITY_BIT  =   1,
    parameter   STOP_BIT    =   1,
    parameter   OSR         =   15
  // parameter BAUD_RATE = 
)
(
	clk,
	clk_div,
	rst_n,
	uart_tx_din,
	send_en,   

	data_out,  
	tx_done,   
	uart_state 
);
input clk;
input clk_div;
input rst_n;

input [DATA_BITS-1:0] uart_tx_din;
input send_en;   

//output data_out;
output reg data_out;
output reg tx_done;   
output reg uart_state ;

    localparam  CNT_WIDTH = $clog2(START_BIT+DATA_BITS+PARITY_BIT+STOP_BIT);
    reg [CNT_WIDTH : 0] clk_cnt;

reg [DATA_BITS-1:0] data_in;
always@(posedge clk or negedge rst_n)   begin
        if(!rst_n)
		data_in <= 0;
	else if(send_en)
		data_in <= uart_tx_din;
	else
		data_in <= data_in;
end

    // send_en==1，start counting
    always@(posedge clk or negedge rst_n)   begin
        if(!rst_n)  
         clk_cnt <= 0;
        else if((send_en == 1)&&(clk_cnt==0))   
            clk_cnt <= 1;
        else if((clk_cnt > 0)&&(clk_cnt < START_BIT+DATA_BITS+PARITY_BIT+STOP_BIT))  
            clk_cnt <= clk_cnt + 1;
        else if(clk_cnt==START_BIT+DATA_BITS+PARITY_BIT+STOP_BIT)
            clk_cnt <= 0;
        else
            clk_cnt <= 0;
    end

    // uart_state
    always@(posedge clk or negedge rst_n)   begin
        if(!rst_n)  begin
            uart_state <= 0;
        end  
        else if((send_en == 1)||(clk_cnt>0&&clk_cnt<DATA_BITS+START_BIT+STOP_BIT+PARITY_BIT)) 
            uart_state <= 1;
        else
            uart_state <= 0;
    end

    // tx_done
    always@(posedge clk or negedge rst_n)   begin
	if(!rst_n)	
		tx_done <= 0;
	else if(clk_cnt==START_BIT+DATA_BITS+PARITY_BIT+STOP_BIT)	
		tx_done <= 1;
	else
		tx_done <= 0;
    end


	
	
   //generate output data
    integer  i;
    reg [DATA_BITS+START_BIT+STOP_BIT+PARITY_BIT-1 : 0]  data_temp;
    // data process
    always@(*)  begin
        if(!rst_n)  begin
            data_temp = 0;
        end
        else if(uart_state == 1)    begin
		      data_temp[0] = 1;
		      for(i=0;i<DATA_BITS;i=i+1)	begin
		          data_temp[i+1]=~data_in[i];
		      end
		      if(PARITY_BIT == 1)	begin
		          data_temp[DATA_BITS+1]=~(^data_temp[DATA_BITS:1]);
		          data_temp[DATA_BITS+2]=0;	
		      end
       		   else 
		          data_temp[DATA_BITS+1]=0;
	       end
	      else begin
	           data_temp[DATA_BITS+1]=0;
	      end
    end
	
	
	   //transfer data
    reg cnt_div;
    always@(posedge clk_div or negedge rst_n)   begin
        if(!rst_n)  
            cnt_div <= 0;
        else if(cnt_div==1)
            cnt_div <= 0;
        else
            cnt_div <= cnt_div + 1;
    end
//assign data_out =(clk_cnt==0)?1:data_temp[clk_cnt-1]&cnt_div;
 
 always@(posedge clk_div or negedge rst_n)  begin
    if(!rst_n)
        data_out <= 0;
    else if(clk_cnt!=0)
        data_out <= data_temp[clk_cnt-1]&cnt_div;
    else
	data_out <= 0;
end

 /*   always@(posedge clk or negedge rst_n)   begin
        if(!rst_n)  
            data_out <= 0;
        else if((uart_state==1)&&(cnt_div==1))
            data_out <= data_temp[clk_cnt-1];
        else
            data_out <= 0;
    end
    */
endmodule