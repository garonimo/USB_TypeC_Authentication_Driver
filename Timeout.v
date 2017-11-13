/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo contiene el manejo de los Timeout
*/


module timeout
  (
    input wire clk,
    input wire [7:0] Enable,
    input wire Enable_Init_or_Resp,
    input wire reset,
    input wire auth_msg_ready,
    input wire [31:0] current_timeout,
    output wire Error_Busy
  );

  reg [31:0] Timeout_counter = 0;
  reg Error_Busy_temp = 0;

  always @(posedge clk) begin
    if (auth_msg_ready | reset) begin
      Timeout_counter = 0;
    end
    else if (Enable | Enable_Init_or_Resp) begin
      Timeout_counter = Timeout_counter + 1;
    end else begin
      Timeout_counter = 0;
    end

    if (Timeout_counter >= current_timeout) begin
      Error_Busy_temp <= 1'b1;
    end else begin
      Error_Busy_temp <= 1'b0;
    end

  end

  assign Error_Busy = Error_Busy_temp;

endmodule // timeout
