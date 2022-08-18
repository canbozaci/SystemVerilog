`timescale 1ns / 1ps
module fifo#(
    parameter DATA_SIZE = 8,
    parameter FIFO_DEPTH = 32
    )
    (
    input  clk_i,
    input  rst_i,
    input  rd_i,
    input  wr_i,
    input  [DATA_SIZE-1:0] data_i,
    output reg [DATA_SIZE-1:0] data_o,
    output full_o,
    output empty_o
    );

    integer i;

    reg [DATA_SIZE-1:0] mem [FIFO_DEPTH-1:0];
    reg [$clog2(FIFO_DEPTH):0] wr_ptr; // 1001
    reg [$clog2(FIFO_DEPTH):0] rd_ptr; // 0001

    assign empty_o = ((wr_ptr - rd_ptr) == 0)  ? 1'b1 : 1'b0;
    assign full_o =  ((wr_ptr[$clog2(FIFO_DEPTH)] ^ rd_ptr[$clog2(FIFO_DEPTH)]) && 
                     (wr_ptr[$clog2(FIFO_DEPTH)-1:0]) == rd_ptr[$clog2(FIFO_DEPTH)-1:0]) ? 1'b1 : 1'b0;

    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            data_o   <= 0;
            rd_ptr   <= 0;
            wr_ptr   <= 0;
            for(i = 0; i<FIFO_DEPTH; i = i+1) begin
                mem[i] <= 0;
            end
        end
        else begin
            if ((wr_i == 1'b1) && (full_o == 1'b0)) begin
                mem[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= data_i;
                wr_ptr      <= wr_ptr + 1'b1;
            end 
            if ((rd_i == 1'b1) && (empty_o == 1'b0)) begin
                data_o    <= mem[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];
                rd_ptr    <= rd_ptr + 1'b1;
            end
        end
    end
endmodule
