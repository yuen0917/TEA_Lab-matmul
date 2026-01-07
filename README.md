# Matmul module include input bram and output bram

Top module: datapath.v

## input

clk<br>
rst_n<br>

### start:

used to trigger this module start caculating <br>
should be triggered after input bram is full <br>

## output

### finish

when complete 256 groups of matmul, finish flag will be set to 1 for a clk period.

### valid_out0, valid_out1:

used for testing the two_pe operating correctly(You can ignore these two ports when using this module.)

### dout_{}_bram:

    output signed [64-1:0] dout_R0_bram,
    output signed [64-1:0] dout_I0_bram,
    output signed [64-1:0] dout_R1_bram,
    output signed [64-1:0] dout_I1_bram,

These ports used to check the output bram is operating correctly(You can ignore these ports when using this module.)

### Bram IO (use wR, wI as input. din0, din1 as weights)

Look into datapath.v <br>
Input brams and output brams are assigned True two ports RAM.<br>
For input brams, port A is assigned for intra module operation, port B is assigned for external access bram.<br>

For example. You can use the below IO ports to access bram R0i. R0i means input 0 real part.<br>

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i CLK" *)
    input  wire        bram_clk_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i RST" *)
    input  wire        bram_rst_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i EN" *)
    input  wire        bram_en_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i WE" *)
    input  wire  [3:0]  bram_we_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i ADDR" *)
    input  wire  [12:0] bram_addr_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i DIN" *)
    input  wire  [31:0] bram_din_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i DOUT" *)
    output wire [31:0] bram_dout_R0i,
X_INTERFACE_INFO used to generate bram bus in block diagram, you can ignore this.

## spec. of block memory generator

In case of you may need to regenerate the bram ip, the spec. of bram are shown below.<br>

### Input bram (included input and weight)

- Inter face type: native <br>
- generate addr 32 bits enable<br>
- Write & Read width : 32 bits
- Write depth: 2048
- Write first
- addr + 4 for accessing next data

### Output bram

- Inter face type: native <br>
- generate addr 32 bits enable<br>
- Write & Read width : 64 bits
- Write depth: 256
- Write first
- addr + 8 for accessing next data


## Other files

Other detailed notes have been placed at the beginning of each file.