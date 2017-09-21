/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es el authentication responder
*/


module responder
  (
    input wire clk,
    input wire reset,
    input wire resp_req_in,
    input wire [999:0] auth_msg_resp_in,
    output wire resp_req_out,
    output wire [999:0] auth_msg_resp_out
  );

  //constantes
  parameter size_of_states_init = 7;
  parameter CERTIFICATE_timeout = 135, CHALLENGE_AUTH_timeout = 635; //ms
  parameter GET_DIGESTS_timeout = 135;                               //ms
  //states
  parameter IDLE = 7'b0000001, GET_DATA = 7'b0000010, GEN_ERROR = 7'b0000100;
  parameter WHICH_REQ = 7'b0001000, CERTIFICATE = 7'b0010000;
  parameter CHALLENGE_AUTH = 7'b0100000, GET_DIGESTS = 7'b1000000;
  //variables
  integer current_timeout;
  reg Error_Busy,Error_Unsupported_Protocol,Error_Invalid_Request,Error_Unspecified = 0;
  reg [7:0] ProtocolVersion,MessageType,Param1,Param2;
  reg [size_of_states_init-1:0] state, next_state;

  int resp_timeout_counter = 0;


  //-------------------------Inicio del código---------------------------------

  //Para el manejo de los timeout
  always @(posedge clk) begin
    if (resp_req_out | reset) begin
      init_timeout_counter = 0;
    end
    else if (resp_req_in) begin
      init_timeout_counter += 1;
    end
  end

 //----------------------Lógica combinacional ---------------------------------
 always @ (*) begin : RESPONDER_COMB
   next_state = 3'b000;
   case (state)
     IDLE: begin
           if (reset == 1'b1) begin
             next_state = GET_DATA;
           end
           else begin
             next_state = IDLE;
           end
     end //IDLE

     GET_DATA: begin


     end // GET_DATA

     default: next_state = IDLE;
    endcase

  end //Always

//----------------------Lógica secuencial---------------------------------

 always @ (posedge clk) begin : Resp_SEQ
   if (reset == 1'b1) begin
     state <= IDLE;
   end
   else if (Error_Busy | Error_Unsupported_Protocol | Error_Invalid_Request | Error_Unspecified) begin
     state <= GEN_ERROR;
   end
   else begin
     state <= next_state;
   end
 end // Always

endmodule // responder
