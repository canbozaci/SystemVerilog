module spi(
  input clk,
  input newd,
  input rst,
  input [11:0] din, 
  output reg sclk,
  output reg cs,
  output reg mosi
  );
      
  parameter idle = 1'b0,
            send = 1'b1;
  reg  state;
      
  integer countc = 0; // 
  integer count = 0;
     
  /////////////////////////generation of sclk
  always@(posedge clk) begin
      if(rst) begin
        countc <= 0;
        sclk   <= 1'b0;
      end
      else begin 
        if(countc < 50 ) begin // if clk 100 MHz, sclk is 1 MHz, it could be parametrized
          countc <= countc + 1;
        end
        else begin
          countc <= 0;
          sclk   <= ~sclk;
        end
      end
  end
  //////////////////state machine
  reg [11:0] temp;
     
  always@(posedge sclk) begin
    if(rst) begin
      cs   <= 1'b1; 
      mosi <= 1'b0;
    end
    else begin
      case(state)
        idle: begin
          if(newd) begin
            cs    <= 1'b0;
            temp  <= din; 
            state <= send;
          end
          else begin
            temp  <= 8'h00;
            state <= idle;
          end
        end
      send : begin
        if(count <= 11) begin
          count <= count + 1;
          mosi  <= temp[count]; /////sending lsb first
        end
        else begin
          cs    <= 1'b1;
          mosi  <= 1'b0;
          count <= 0;
          state <= idle;
        end
      end  
      default : state <= idle; 
      endcase
    end 
  end
    
endmodule
