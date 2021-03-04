
//                              -*- Mode: Verilog -*-
// Filename        : memx.sv
// Description     : Topo de um controlador de memória (exercicio)
// Author          : George Camboim
// Created On      : Sat Sep 21 17:43:52 2019
// Last Modified By: George Camboim
// Last Modified On: Sat Sep 21 17:43:52 2019
// Update Count    : 0
// Status          : Unknown, Use with caution!

module memx
  #(
    parameter RAM_DATA_WIDTH = 16,
    parameter RAM_ADDR_WIDTH = 10,
    parameter RAM_N_OF_WORDS = 256
  )(
    // Interface de entrada e saídas externas
    input  logic 	                    clk_i,
    input  logic                      rst_n_i,
    input  logic 	                    mem_rd_i,
    input  logic 	                    mem_wr_i,
    input  logic [RAM_ADDR_WIDTH-1:0] mem_addr_i,
    input  logic [RAM_DATA_WIDTH-1:0] mem_wdt_i,
    output logic                      mem_busy_o,
    output logic [RAM_DATA_WIDTH-1:0] mem_rdt_o,
    output logic 	                    mem_wok_o,
    // Interface com o modelo de memória
    input  logic [RAM_DATA_WIDTH-1:0] data_i,
    output logic                      wr_o,
    output logic [RAM_ADDR_WIDTH-1:0] addr_o,
    output logic [RAM_DATA_WIDTH-1:0] data_o
  );

  localparam N_OF_CYCLES_WCASE = 200;

  logic                       valid_addr;
  logic [7:0]                 worst_case_counter;

  enum logic [6:0]
  {
    IDLE        = 7'b0000001,
    REQ_READ    = 7'b0000010,
    WAIT_READ   = 7'b0000100,
    RESP_READ   = 7'b0001000,
    REQ_WRITE   = 7'b0010000,
    WAIT_WRITE  = 7'b0100000,
    RESP_WRITE  = 7'b1000000
  } state, next_state;

  always_ff @(posedge clk_i)
  begin
    if(!rst_n_i)
      state <= IDLE;
    else
      state <= next_state;
  end

  always_comb
  begin
    case(state)
      IDLE:
      begin
        next_state = IDLE;
        if(valid_addr)
        begin
          if(mem_wr_i)
            next_state = REQ_WRITE;
          else if(mem_rd_i)
            next_state = REQ_READ;
        end
      end
      REQ_READ:
        next_state = (valid_addr) ? (WAIT_READ) : (IDLE);
      WAIT_READ:
        next_state = (worst_case_counter < N_OF_CYCLES_WCASE) ? (WAIT_READ) : (RESP_READ); 
      REQ_WRITE:
        next_state = (worst_case_counter < N_OF_CYCLES_WCASE) ? (REQ_WRITE) : (WAIT_WRITE);
      WAIT_WRITE:
        next_state = (data_i !== data_o) ? (WAIT_WRITE) : (RESP_WRITE);
      RESP_READ, RESP_WRITE:
        next_state = IDLE;
      default:
        next_state = IDLE;
    endcase
  end

  always_ff @(posedge clk_i)
  begin
    mem_busy_o      <= 1'b1;
    mem_wok_o       <= 1'b0;
    wr_o            <= 1'b0;
    case(state)
      IDLE:
      begin
        addr_o <= mem_addr_i;
        data_o <= mem_wdt_i;
        worst_case_counter <= 8'h00;
        mem_busy_o <= 1'b0;
      end
      REQ_READ:
        ;
      WAIT_READ:
        worst_case_counter <= worst_case_counter + 1;
      RESP_READ:
      begin
        mem_rdt_o <= data_i; 
        mem_busy_o <= 1'b0;
      end
      REQ_WRITE, WAIT_WRITE:
      begin
        worst_case_counter <= worst_case_counter + 1;
        wr_o <= 1'b1;
      end
      RESP_WRITE:
      begin
        mem_wok_o <= 1'b1;
        mem_busy_o <= 1'b0;
      end
      default:
        ;
    endcase
  end

  assign valid_addr = mem_addr_i < RAM_N_OF_WORDS;

endmodule

