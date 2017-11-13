/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es el authentication initiator, crea los mensajes
* de autenticación y recibe los certificados solicitados para verificar que
* estos son correctos
*/

`include "get_certificate_control.v"

module initiator
  (
    input wire clk,
    input wire reset,
    input wire init_req_in,
    input wire [`MSG_LEN-1:0] auth_msg_init_in,
    input wire Ack_in,
    input wire [1:0] type_of_request,
    input wire [1:0] slot,
    input wire Error_Busy,
    output wire Ack_out,
    output wire [7:0] bmRequestType,
    output wire [7:0] bRequest,
    output wire [15:0] wLength,
    output wire [31:0] current_timeout,
    output wire pending_auth_msg_to_send,
    output wire Certification_done,
    output wire Error_authentication_failed,
    output wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload,
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header
  );


  //-------------------------------Parámetros-----------------------------------
  parameter IDLE = 9'b000000001, WHICH_REQ = 9'b000000010;
  parameter GEN_ERROR = 9'b000000100;
  parameter GET_DATA = 9'b000001000, CERTIFICATE = 9'b000010000;
  parameter CHALLENGE = 9'b000100000, DIGESTS = 9'b001000000;
  parameter SEND_MSG = 9'b010000000, ACK = 9'b100000000;

  //--------------------------------Variables-----------------------------------
  reg Error_Unsupported_Protocol_temp = 0;
  reg Error_Invalid_Request_temp = 0;
  reg Error_Unspecified_temp = 0;
  reg Error_MSG_ready = 0;

  reg [31:0] current_timeout_temp = `CHALLENGE_TIMEOUT_AUTH;
  //Variables del mensaje de autenticacion
  reg [`SIZE_OF_HEADER_VARS-1:0] ProtocolVersion_in = 0;
  reg [`SIZE_OF_HEADER_VARS-1:0] MessageType_in = 0;
  reg [`SIZE_OF_HEADER_VARS-1:0] Param1_in = 0;
  reg [`SIZE_OF_HEADER_VARS-1:0] Param2_in = 0;
  wire [`SIZE_OF_HEADER_VARS-1:0] Param1;
  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp = 0;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_challenge,header_digests,header_error;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_Certificate;
  reg [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp = 0;
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_challenge,payload_digests;
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_Certificate;
  wire payload_error;
  //Variables para mensajes sobre USB
  reg [7:0] bmRequestType_temp = 0;
  reg [7:0] bRequest_temp = 0;
  reg [15:0] wLength_temp = 0;
  wire [15:0] wLength_GetCertificate;
  //Variables para "handshakes"
  reg Ack_out_temp = 0;
  wire GetCert_enable;
  wire Ack_in_GetCert, Ack_out_GetCert;
  reg GetCert_enable_temp = 0;
  reg Ack_out_GetCert_temp = 0;
  //Variables de estado
  reg [`SIZE_OF_STATES_INIT-1:0] state_initiator, next_state;

  ////////////////////////////////////////////////////////////////////////////////
  //-------------------------Inicio del código------------------------------------
  ////////////////////////////////////////////////////////////////////////////////

  certificate_control get_certificate_control
    (
      .clk(clk),
      .reset(reset),
      .Enable(GetCert_enable),
      .slot(slot),
      .auth_msg_init_in(auth_msg_init_in),
      .Ack_in(Ack_out_GetCert),
      .header(header_Certificate),
      .payload(payload_Certificate),
      .Ack_out(Ack_in_GetCert),
      .pending_authentication(pending_auth_msg_to_send),
      .Certification_done(Certification_done),
      .Certification_failed(Error_authentication_failed)
    );

  ////////////////////////////////////////////////////////////////////////////////
  //-------------------------Máquina de estados-----------------------------------
  ////////////////////////////////////////////////////////////////////////////////

  //----------------------Lógica combinacional------------------------------------

  always @ (*)
   begin : INITIATOR_COMB
    next_state = 9'b0;
    case (state_initiator)

      IDLE:
      begin
        if (init_req_in == 1'b1) begin
          next_state = WHICH_REQ;
        end
        else begin
          next_state = IDLE;
        end
      end //IDLE

      WHICH_REQ:
      begin
        case (type_of_request)

          1: next_state = CHALLENGE;
          2: next_state = DIGESTS;
          3: next_state = CERTIFICATE;

          default: next_state = IDLE;  //En este caso se estaria mandando mal el
        endcase                        //comando internamente, por lo que no hace nada en ese caso
      end

      CHALLENGE:
      begin
        if (header) begin
          next_state = SEND_MSG;
        end else begin
          next_state = CHALLENGE;
        end
      end


      DIGESTS:
      begin
        if (header) begin
          next_state = SEND_MSG;
        end else begin
          next_state = DIGESTS;
        end
      end


      CERTIFICATE:
      begin
        if (Ack_in_GetCert) begin
          next_state = SEND_MSG;
        end else begin
          next_state = CERTIFICATE;
        end
      end


      GEN_ERROR:
      begin
       if (Error_MSG_ready) begin
         next_state = SEND_MSG;
       end else begin
         next_state = GEN_ERROR;
       end
      end


      SEND_MSG:
      begin
        if (Ack_out) begin
          next_state = ACK;
        end else begin
          next_state = SEND_MSG;
        end
      end


      ACK:
      begin
        if (Ack_in) begin
          next_state = IDLE;
        end else begin
          next_state = ACK;
        end
      end

      default: next_state = IDLE;
    endcase

   end //Always-INITIATOR_COMB

  //---------------------------Lógica secuencial---------------------------------
  always @ (posedge clk) begin : INITIATOR_SEQ
    if ((reset == 1'b1) || (Error_authentication_failed == 1'b1) || (Error_Busy == 1'b1) || (init_req_in == 1'b0)) begin
        state_initiator <= IDLE;
      end
    else begin
        state_initiator <= next_state;
      end
  end // Always

  //---------------------------Lógica de salida-------------------------------------

  always @ (negedge clk) begin : INITIATOR_OUTPUT
    if (reset == 1'b1) begin
      header_temp <= 1'b0;
      payload_temp <= 1'b0;
      GetCert_enable_temp <= 1'b0;
    end
    else begin
      case (state_initiator)

        IDLE:
        begin
          Ack_out_temp <= 1'b0;
          Ack_out_GetCert_temp <= 1'b0;
          header_temp <= 0;
          payload_temp <= 0;
          GetCert_enable_temp <= 1'b0;
        end //IDLE


        CHALLENGE:
        begin
          bmRequestType_temp <= 128;
          bRequest_temp <= 24;
          wLength_temp <= 168;
          current_timeout_temp <= `CHALLENGE_TIMEOUT;
          case(slot)

            2'b00: header_temp <= `HEADER_CHALLENGE_SLOT0;
            2'b01: header_temp <= `HEADER_CHALLENGE_SLOT1;
            2'b10: header_temp <= `HEADER_CHALLENGE_SLOT2;

            default: header_temp <= 0;

          endcase
          payload_temp <= 0;
        end //CHALLENGE


        DIGESTS:
        begin
          bmRequestType_temp <= 128;
          bRequest_temp <= 24;
          wLength_temp <= 260;
          current_timeout_temp <= `DIGEST_REQ_TIMEOUT;
          header_temp <= `HEADER_DIGESTS_REQ;
          payload_temp <= 0;
        end//DIGESTS


        CERTIFICATE:
        begin
          bmRequestType_temp <= 0;
          bRequest_temp <= 25;
          wLength_temp <= 2052;
          header_temp <= header_Certificate;
          payload_temp <= payload_Certificate;
          current_timeout_temp <= `GET_CERTIFICATE_TIMEOUT;
          GetCert_enable_temp <= 1'b1;
        end//CERTIFICATE


        SEND_MSG:
        begin
          GetCert_enable_temp <= 1'b0;
          Ack_out_GetCert_temp <= 1'b1;
          GetCert_enable_temp <= 1'b0;
          Ack_out_temp <= 1'b1;
        end //SEND_MSG


        ACK:
        begin
          Ack_out_GetCert_temp <= 1'b0;
        end

        default: begin
          Ack_out_temp <= 1'b0;
        end

      endcase
    end
  end //Always-INITIATOR_OUTPUT

  //---------------------------Fin de FSM---------------------------------------


  assign Error_Unsupported_Protocol = Error_Unsupported_Protocol_temp;
  assign Error_Invalid_Request = Error_Invalid_Request_temp;
  assign Error_Unspecified = Error_Unspecified_temp;
  assign current_timeout = current_timeout_temp;
  assign Ack_out = Ack_out_temp;
  assign header = header_temp;
  assign payload = payload_temp;
  assign bmRequestType = bmRequestType_temp;
  assign bRequest = bRequest_temp;
  assign wLength = wLength_temp;
  assign GetCert_enable = GetCert_enable_temp;
  assign Ack_out_GetCert = Ack_out_GetCert_temp;

endmodule // initiator
