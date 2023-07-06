module top(
  input         clk_sys,
  input         reset_n,
  output        top_out
);

/**********************parameter**********************/
parameter DISP_IMAGE_W    = 200                      ;
parameter DISP_IMAGE_H    = 200                      ;
parameter ROM_DEPTH       = DISP_IMAGE_W*DISP_IMAGE_H;
parameter ROM_ADDR_WIDTH  = $clog2(ROM_DEPTH)        ;
parameter ROM_DATA_WIDTH  = 16                       ; 
parameter DISP_BACK_COLOR = 16'hFFFF                 ; //白色
parameter TFT_WIDTH  = 480;
parameter TFT_HEIGHT = 272;
parameter DISP_HBEGIN = (TFT_WIDTH  - DISP_IMAGE_W)/2;
parameter DISP_VBEGIN = (TFT_HEIGHT - DISP_IMAGE_H)/2;
localparam 
    BLACK = 16'h0000, //黑色
    BLUE = 16'h001F, //蓝色
    RED = 16'hF800, //红色
    PURPPLE	= 16'hF81F, //紫色
    GREEN = 16'h07E0, //绿色
    CYAN = 16'h07FF, //青色
    YELLOW	= 16'hFFE0, //黄色
    WHITE = 16'hFFFF; //白色
/**********************fsm***********************/
/**********************wire**********************/	
 
  //rom
 wire [ROM_ADDR_WIDTH-1:0]    rom_addra   ;
 wire [ROM_DATA_WIDTH-1:0]    rom_data    ;
 // data_transfer
 wire clk10m;
 wire clk5m;
 wire uart_tx_state;
 wire error_flag;
 wire tx_send_en;
 wire tran_done;
 wire [15:0] tx_ram_dout;
 wire [2:0] nstate;
 wire [2:0] cstate;
 //uart_tx
 wire tx_done;   
 //reset
 wire reset_p;

 


/************************reg***********************/
/**********************assign**********************/	
 assign reset_p = ~reset_n;
/**********************always**********************/
/*********************instance*********************/

  clk_wiz_1 pll
   (
    .clk_out1       (clk10m     ),   
    .clk_out2       (      ),  
    .reset          (reset_p    ), 
    .clk_in1        (clk_sys    )
   );  

  
blk_mem_gen_0 data_tx_buf (
  .clka     (clk5m          ),    // input wire clka
  .addra    (rom_addra      ),  // input wire [15 : 0] addra
  .douta    (rom_data       )  // output wire [15 : 0] douta
);

clk_div clk_div(
    .clk            (clk10m   ),
    .rst            (reset_p   ),
    .clk_out        (clk5m   )
    );

Data_Transfer
#(
    .DATA_BITS      (ROM_DATA_WIDTH    ),
    .ADDR_MAX       (ROM_DEPTH         ) //130560  //480*272
) Data_Transfer
(
    .clk_tx         (clk5m          ),
    .rst_n          (reset_n        ),
    .uart_tx_state  (uart_tx_state  ),
    .error_flag     (1'b0           ),
    .data_in        (rom_addra      ),
    .send_en        (tx_send_en     ),
    .tran_done      (tran_done      ),
    .addr           (rom_addra      ),
    .data_out       (tx_ram_dout    ),
    .tx_done        (tx_done        )
);

Uart_Tx
#(
    .START_BIT   (1              ),
    .DATA_BITS   (16             ),
    .PARITY_BIT  (1              ),
    .STOP_BIT    (1              ),
    .OSR         (15             )
)
(
	.clk           (clk5m          ),
	.clk_div       (clk10m         ),
  .rst_n         (reset_n        ),
	.uart_tx_din   (tx_ram_dout    ),
	.send_en       (tx_send_en     ),   
	.data_out      (top_out        ),  
	.tx_done       (tx_done        ),   
	.uart_state    (uart_tx_state  )
);
/*
  image_extract
  #(
    .H_Visible_area (TFT_WIDTH      ), //屏幕显示区域宽度
    .V_Visible_area (TFT_HEIGHT     ), //屏幕显示区域高度
    .IMG_WIDTH      (DISP_IMAGE_W   ), //图片宽度
    .IMG_HEIGHT     (DISP_IMAGE_H   ), //图片高度
    .IMG_DATA_WIDTH (16             ), //图片像素点位宽
    .ROM_ADDR_WIDTH (ROM_ADDR_WIDTH )  //存储图片ROM的地址位宽
  )image_extract
  (
    .clk_ctrl        (clk9m              ),
    .reset_n         (reset_n            ),
    .img_disp_hbegin (DISP_HBEGIN        ),
    .img_disp_vbegin (DISP_VBEGIN        ),
    .disp_back_color (DISP_BACK_COLOR    ),   
    .rom_addra       (image_extract_addr ),
    .rd_en           (image_extract_rden ),
    .rom_data        (image_extract_data ),
    .frame_begin     (frame_begin        ),
    .disp_data_req   (disp_data_req      ),
    .visible_hcount  (visible_hcount     ),
    .visible_vcount  (visible_vcount     ),
    .disp_data       (disp_data          )
  );


disp_driver disp_driver(
    .ClkDisp         (clk9m             ),  
    .Rst_p           (reset_p           ),
    .Data            (disp_data         ),
    .DataReq         (disp_data_req     ),
    .H_Addr          (visible_hcount    ),
    .V_Addr          (visible_vcount    ),
                                   
    .Disp_HS         (TFT_hs            ),
    .Disp_VS         (TFT_vs            ),
    .Disp_Red        (Disp_Red          ),
    .Disp_Green      (Disp_Green        ),
    .Disp_Blue       (Disp_Blue         ),
    .Frame_Begin     (frame_begin       ),
             
    .Disp_DE         (TFT_de            ),
    .Disp_PCLK       (Disp_PCLK         )
	);
	*/
	
	
	
endmodule