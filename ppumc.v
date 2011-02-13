///////////////////////////////////////////////////////////////////////////////////////////////////
// Module Name: ppumc
//
// Author:      Brian Bennett (brian.k.bennett@gmail.com)
// Create Date: 02/11/2011
//
// Description:
// 
// PPU Memory Controller.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
module ppumc
(
  input  wire        clk,   // 50MHz system clock signal
  input  wire        wr,    // write enable signal
  input  wire [13:0] addr,  // 16-bit memory address
  input  wire [ 7:0] din,   // data input bus
  output reg  [ 7:0] dout   // data output bus
);

wire [12:0] pattern_tbl_addr;
wire [ 7:0] pattern_tbl_rd_data;
reg         pattern_tbl_wr;

wire [10:0] name_tbl_addr;
wire [ 7:0] name_tbl_rd_data;
reg         name_tbl_wr;

// PPU Memory Map
//   0x0000 - 0x1FFF Pattern Tables
//   0x2000 - 0x27FF Name / Attribute Tables
//   0x2800 - 0x2FFF Configurable Mirror (0x2000 - 0x27FF)
//   0x3000 - 0x3FFF Mirrors 0x2000 - 0x2FFF
//   0x4000 - 0xFFFF Mirrors 0x0000 - 0x3FFF

// Block ram instance for "Pattern Table" memory range (0x0000 - 0x1FFF).
single_port_ram_sync #(.ADDR_WIDTH(13),
                       .DATA_WIDTH(8)) pattern_tbl(
  .clk(clk),
  .we(pattern_tbl_wr),
  .addr_a(pattern_tbl_addr),
  .din_a(din),
  .dout_a(pattern_tbl_rd_data)
);

assign pattern_tbl_addr = addr[12:0];

// Block ram instance for "Name Table" memory range (0x2000 - 0x27FF).
single_port_ram_sync #(.ADDR_WIDTH(11),
                       .DATA_WIDTH(8)) name_tbl(
  .clk(clk),
  .we(name_tbl_wr),
  .addr_a(name_tbl_addr),
  .din_a(din),
  .dout_a(name_tbl_rd_data)
);

assign name_tbl_addr = addr[10:0];

always @*
  begin
    pattern_tbl_wr = 1'b0;
    name_tbl_wr    = 1'b0;

    if (addr[13] == 0)
      begin
        // Pattern Table range (0x0000 - 0x1FFF, 0x4000 - 0x5FFF, etc)
        dout           = pattern_tbl_rd_data;
        pattern_tbl_wr = wr;
      end
    else
      begin
        // Name Table range (0x2000 - 0x3FFF, 0x6000 - 0x7FFF, etc)
        dout        = name_tbl_rd_data;
        name_tbl_wr = wr;
      end
  end

endmodule

