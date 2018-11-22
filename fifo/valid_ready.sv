interface valid_ready #(parameter DATA_WIDTH = 8)();
  logic                   valid;
  logic                   ready;  
  logic [DATA_WIDTH-1:0]  data;
  
  modport Master
    (input ready, output valid, data);
  
  modport Slave
    (input valid, data, output ready);
  
endinterface