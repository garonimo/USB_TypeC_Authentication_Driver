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
    input wire Enable,
    input wire reset,
    input wire auth_msg_ready,
    input wire current_timeout,
    output wire Error_Busy
  );

  reg [31:0] Timeout_counter;
  reg Error_Busy_temp;

  always @(posedge clk) begin
    if (auth_msg_ready | reset) begin
      Timeout_counter = 0;
    end
    else if (Enable) begin
      Timeout_counter += 1;
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
