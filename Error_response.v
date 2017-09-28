/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es para crear los mensajes de respuesta de error
*/


module error_response
  (
    input wire clk,
    input wire Enable,
    input wire Error_Invalid_Request,
    input wire Error_Invalid_Request_challenge,
    input wire Error_Busy,
    input wire Error_Unsupported_Protocol,
    input wire Error_Unspecified,
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header,
    output wire payload,
    output wire MSG_ready
  );

  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp;
  reg payload_temp = 0;
  reg MSG_ready_temp;
  reg [`SIZE_OF_HEADER_VARS-1:0] Param1,Param2;
  reg [4:0] Error;

  always @ (posedge clk) begin
    if (Enable) begin
    Error = {Error_Invalid_Request,Error_Invalid_Request_challenge,Error_Busy,Error_Unsupported_Protocol,Error_Unspecified};
      case (Error)
        16: begin           //Invalid_Request
          Param1 = 8'h01;
          Param2 = 8'h00;
        end

        8: begin            //Invalid_Request
          Param1 = 8'h01;
          Param2 = 8'h00;
        end

        4: begin            //Busy(Timeout)
          Param1 = 8'h03;
          Param2 = 8'h00;
        end

        2: begin            //Unsupported_Protocol
          Param1 = 8'h02;
          Param2 = 8'h01;
        end

        1: begin      //Unspecified
          Param1 = 8'h04;
          Param2 = 8'h00;
        end

        default: begin           //Invalid_Request-Challenge
          Param1 = 8'h01;
          Param2 = 8'h00;
        end
      endcase

      header_temp = {`PROTOCOL_VERSION,`ERROR_RESP_CMD,Param1,Param2};
      MSG_ready_temp = 1'b1;
    end //If Enable
    else begin
      header_temp <= 0;
      MSG_ready_temp <= 1'b0;
    end
  end //Always


  assign header = header_temp;
  assign payload = payload_temp;
  assign MSG_ready = MSG_ready_temp;

endmodule // error_response
