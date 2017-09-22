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
  parameter size_of_states_init = 7, size_of_header_vars = 8;
  parameter size_of_header_in_bytes = 4;
  parameter CERTIFICATE_timeout = 135, CHALLENGE_AUTH_timeout = 635; //ms
  parameter GET_DIGESTS_timeout = 135;                               //ms
  //states
  parameter IDLE = 7'b0000001, GET_DATA = 7'b0000010, GEN_ERROR = 7'b0000100;
  parameter WHICH_REQ = 7'b0001000, GET_CERTIFICATE = 7'b0010000;
  parameter CHALLENGE = 7'b0100000, GET_DIGESTS = 7'b1000000;
  //variables
  integer current_timeout;
  reg Error_Busy,Error_Unsupported_Protocol,Error_Invalid_Request,Error_Unspecified = 0;
  reg [size_of_header_vars-1:0] ProtocolVersion_in,MessageType_in,Param1_in,Param2_in;
  wire [(size_of_header_vars-1)*size_of_header_in_bytes:0] header = {ProtocolVersion_in,MessageType_in,Param1_in,Param2_in};
  reg [size_of_states_init-1:0] state, next_state;

  integer resp_timeout_counter = 0;


  //-------------------------Inicio del código---------------------------------

  //Para el manejo de los timeout
  always @(posedge clk) begin
    if (resp_req_out | reset) begin
      resp_timeout_counter = 0;
    end
    else if (resp_req_in) begin
      resp_timeout_counter += 1;
    end
  end

 //----------------------Lógica combinacional ---------------------------------
 always @ (*)
  begin : RESPONDER_COMB
   next_state = 7'b0;
   case (state)
     IDLE: begin
           if (reset == 1'b1) begin
             next_state = GET_DATA;
           end
           else begin
             next_state = IDLE;
           end
     end //IDLE

     GET_DATA:
     begin
          ProtocolVersion_in = auth_msg_resp_in[size_of_header_vars-1:0];
          if (ProtocolVersion_in != 1) begin
              Error_Unsupported_Protocol <= 1'b1;
          end else begin
              Error_Unsupported_Protocol <= 1'b0;
          end
          MessageType_in = auth_msg_resp_in[(2*size_of_header_vars)-1:size_of_header_vars];
          Param1_in = auth_msg_resp_in[(3*size_of_header_vars)-1:(2*size_of_header_vars)];
          Param2_in = auth_msg_resp_in[(4*size_of_header_vars)-1:(3*size_of_header_vars)];
          next_state = WHICH_REQ;
     end // GET_DATA

     WHICH_REQ:
     begin
        case(MessageType_in)
          129: next_state = GET_DIGESTS;
          130: next_state = GET_CERTIFICATE;
          131: next_state = CHALLENGE;

          default: Error_Invalid_Request = 1'b1;
        endcase
     end // WHICH_REQ

     GET_DIGESTS: begin
        next_state = IDLE;
     end

     GET_CERTIFICATE: begin
        next_state = IDLE;
     end

     CHALLENGE: begin
        next_state = IDLE;
     end

     GEN_ERROR: begin
        next_state = IDLE;
     end

     default: next_state = IDLE;
    endcase

  end //Always

//-------------------------Lógica secuencial------------------------------------

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
