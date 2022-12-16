`timescale 1ns / 1ps

module cache(
    input            clk             ,  // clock, 100MHz
    input            rst             ,  // active low

    //  Sram-Like接口信号定义:
    //  1. cpu_req     标识CPU向Cache发起访存请求的信号，当CPU需要从Cache读取数据时，该信号置为1
    //  2. cpu_addr    CPU需要读取的数据在存储器中的地址,即访存地址
    //  3. cache_rdata 从Cache中读取的数据，由Cache向CPU返回
    //  4. addr_ok     标识Cache和CPU地址握手成功的信号，值为1表明Cache成功接收CPU发送的地址
    //  5. data_ok     标识Cache和CPU完成数据传送的信号，值为1表明CPU在本时钟周期内完成数据接收
    input         cpu_req      ,    //由CPU发送至Cache
    input  [31:0] cpu_addr     ,    //由CPU发送至Cache
    output [31:0] cache_rdata  ,    //由Cache返回给CPU
    output        cache_addr_ok,    //由Cache返回给CPU
    output        cache_data_ok,    //由Cache返回给CPU

    //  AXI接口信号定义:
    //  Cache与AXI的数据交换分为两个阶段：地址握手阶段和数据握手阶段
    output [3 :0] arid   ,              //Cache向主存发起读请求时使用的AXI信道的id号，设置为0即可
    output [31:0] araddr ,              //Cache向主存发起读请求时所使用的地址
    output        arvalid,              //Cache向主存发起读请求的请求信号
    input         arready,              //读请求能否被接收的握手信号

    input  [3 :0] rid    ,              //主存向Cache返回数据时使用的AXI信道的id号，设置为0即可
    input  [31:0] rdata  ,              //主存向Cache返回的数据
    input         rlast  ,              //是否是主存向Cache返回的最后一个数据
    input         rvalid ,              //主存向Cache返回数据时的数据有效信号
    output        rready                //标识当前的Cache已经准备好可以接收主存返回的数据  
);

    /*-----------state-----------*/
    parameter idle    = 0;
    parameter run     = 1;
    parameter sel_way = 2;
    parameter miss    = 3;
    parameter refill  = 4;
    parameter finish  = 5;
    parameter resetn  = 6;

    reg [2:0] state;
    reg [6:0] reset_cnt;
    reg rb_work;

    wire [1 :0] hit_array;
    
    /* DFA */
    always @(posedge clk) begin
        if (!rst) begin
            state <= resetn;
            reset_cnt <= 0;
        end
        else begin
            case (state)
                resetn: begin
                    if (reset_cnt == 7'd127) state <= idle;
                    reset_cnt <= reset_cnt + 1;
                end
                idle:    if (cpu_req) state <= run;
                run: begin
                    if (rb_work) begin
                        #1;
                        if (hit_array == 2'b00) state <= sel_way;
                    end
                end
                sel_way: state <= miss;
                miss:    if (arready) state <= refill;
                refill:  if (rlast) state <= finish;
                finish:  state <= run;
            endcase
        end
    end

    /*-----------Request Buffer-----------*/
    reg [31:0] rb_addr;
    reg [31:0] rb_last_addr;
 
    wire [19:0] rb_tag         = rb_addr[31:12];
    wire [6 :0] rb_index       = rb_addr[11:5];
    wire [4 :0] rb_offset      = rb_addr[4:0];
    wire [19:0] rb_last_tag    = rb_last_addr[31:12];
    wire [6 :0] rb_last_index  = rb_last_addr[11:5];
    wire [4 :0] rb_last_offset = rb_last_addr[4:0];
    

    always @(posedge clk) begin
        if (!rst) begin
            rb_work <= 0;
            rb_addr <= 0;
            rb_last_addr <= 0;
        end else begin
            if (state == run) begin
                rb_work <= 1;
                rb_addr <= cpu_addr;
                rb_last_addr <= rb_addr;
            end
        end
    end
    


    /*-----------LRU-----------*/
    reg [127:0] lru;
    reg lru_sel;

    // LRU Update: 在命中的 RUN 状态和不命中的 MISS 状态进行 LRU 的更新
    always @(posedge clk) begin
        if (!rst) lru <= 0;
        else begin
            if (state == run) case (hit_array)
                2'b00: lru[rb_index] <= ~lru[rb_index];
                2'b01: lru[rb_index] <= 0;
                2'b10: lru[rb_index] <= 1;
            endcase
        end
    end

    // LRU Select Way
    always @(posedge clk) begin
        if (state == sel_way) lru_sel = lru[rb_index];
    end

    /*-----------Refill-----------*/
    /*TODO: 设计一个计数器，用于记录当前refill的指令个数*/
    reg [2:0] refill_cnt;
    always @(posedge clk) begin
        if (state == refill) refill_cnt <= refill_cnt + 1;
        else refill_cnt <= 0;
    end


    /*-----------tagv && data-----------*/
    wire valid_wdata;
    wire [1 :0] tagv_wen;
    wire [6 :0] tagv_index;
    wire [19:0] tagv_tag;

    assign valid_wdata = state != resetn;
    assign tagv_wen[0] = state == resetn || (state == refill && lru_sel == 0);
    assign tagv_wen[1] = state == resetn || (state == refill && lru_sel == 1);
    assign tagv_index  = state == resetn ? reset_cnt :
                         state == run ? rb_index :
                         rb_last_index;
    assign tagv_tag    = state == resetn ? 0 :
                         state == run ? rb_tag :
                         rb_last_tag;

    wire [31 :0] data_wen[1:0];
    wire [6  :0] data_index;
    wire [4  :0] data_offset;
    wire [31 :0] data_rdata[1:0];
    wire [255:0] data_wdata;

    assign data_wen[0] = (state == resetn) ? 32'hffffffff :
                         (state == refill && lru_sel == 0) ? 32'hf << (refill_cnt * 4) :
                         32'h0;
    assign data_wen[1] = (state == resetn) ? 32'hffffffff :
                         (state == refill && lru_sel == 1) ? 32'hf << (refill_cnt * 4) :
                         32'h0;
    assign data_index  = state == resetn ? reset_cnt :
                         state == run ? rb_index :
                         rb_last_index;
    assign data_offset = state == run ? rb_offset : rb_last_offset;
    assign data_wdata  = state == resetn ? 32'h0 :
                         state == refill ? rdata << (refill_cnt * 32) :
                         32'h0;

    generate
        genvar j;
        for (j = 0 ; j < 2 ; j = j + 1) begin
            icache_tagv Cache_TagV (
                .clk        (clk         ),
                .wen        (tagv_wen[j] ),
                .index      (tagv_index  ),
                .tag        (tagv_tag    ),
                .valid_wdata(valid_wdata ),
                .hit        (hit_array[j])
            );
            icache_data Cache_Data (
                .clk          (clk          ),
                .wen          (data_wen[j]  ),
                .index        (data_index   ),
                .offset       (data_offset  ),
                .wdata        (data_wdata   ),
                .rdata        (data_rdata[j])
            );
        end
    endgenerate

    /*------------ CPU<->Cache -------------*/
    assign cache_addr_ok = state == run;
    assign cache_data_ok = state == run && rb_work && hit_array != 2'b00;

    // select way
    assign cache_rdata = state == run ? data_rdata[lru[rb_index]] : data_rdata[lru_sel];

    /*-----------------AXI------------------*/
    // Read
    assign arid    = 4'd0;
    assign arvalid = state == miss;
    assign araddr  = {rb_last_addr[31:5], 5'b0};
    
    assign rready  = state == refill;
endmodule
