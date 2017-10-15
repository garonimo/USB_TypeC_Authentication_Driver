/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo contiene
*/

`include "Parameters.v"

module authentication_driver
  (
    input wire clk,
    input wire reset,
    input wire resp_req_in,
    input wire [`MSG_LEN-1:0] auth_msg_resp_in,
    input wire Ack_in,
    input wire [7:0] pending_auth_request,
    output wire PD_in_ready,
    output wire DEGUG_in_ready,
    output wire resp_req_out,
    output wire [`MSG_LEN-1:0] auth_msg_resp_out
  );

  //-------------------------------Parámetros-----------------------------------
  //estados
  parameter IDLE = 9'b000000001, GET_DATA_OF_REQUESTER = 9'b000000010;
  parameter GET_REQUESTER_MSG = 9'b000000100;
  parameter RESPONDER = 9'b000001000, INITIATOR = 9'b000010000;
  parameter USB_MSG = 9'b000100000, EXTERNAL_ERROR = 9'b001000000;
  parameter SEND_MSG = 9'b010000000, ACK = 9'b100000000;

//Internal variables
  reg [`SIZE_OF_STATES_DRIVER-1:0] state, next_state;
  reg [7:0] current_auth_request;
  reg [1:0] requester,initiator_or_responder,USB_or_not;

//handshakes
  wire Responder_Enable, Responder_ready;
  wire Initiator_Enable, Initiator_ready;
  reg  Responder_Enable_temp, Initiator_Enable_temp;
  wire auth_msg_ready;
  reg auth_msg_ready_temp;
  reg PD_in_ready_temp,DEBUG_in_ready_temp;
  reg [7:0] auth_msg_resp_out_temp, pending_auth_request_temp;

//----------------------Combinational Logic-------------------------------------
  always @ (*) begin : FSM_COMB
    next_state = 0;
    case (state)

        IDLE: begin
              if (pending_auth_request) begin
                next_state = GET_REQUESTER_MSG;
              end
              else begin
                next_state = IDLE;
              end
        end //IDLE


        GET_DATA_OF_REQUESTER: begin
              current_auth_request = pending_auth_request;
              requester = current_auth_request[7:6];
              initiator_or_responder = current_auth_request[5:4];
              USB_or_not = current_auth_request[3:2];
              if ((requester == 2'b01) || (requester == 2'b10)) begin
                next_state = GET_REQUESTER_MSG;
              end
              else begin
                pending_auth_request_temp = 0;
                next_state = IDLE;
              end
        end //GET_DATA_OF_REQUESTER


        GET_REQUESTER_MSG:
        begin
            if (requester == 2'b01) begin
              next_state = RESPONDER;
            end
            else if (requester == 2'b10) begin
              next_state = INITIATOR;
            end
            else begin
              next_state = IDLE;
            end
        end //GET_REQUESTER_MSG


        RESPONDER:
        begin
            if (Responder_ready == 1'b1) begin
              if (USB_or_not == 1'b1) begin
                next_state = USB_MSG;
              end else begin
                next_state = SEND_MSG;
              end
            end else begin
              next_state = RESPONDER;
            end
        end //RESPONDER


        INITIATOR:
        begin
            if (Initiator_ready == 1'b1) begin
              if (USB_or_not == 1'b1) begin
                next_state = USB_MSG;
              end else begin
                next_state = SEND_MSG;
              end
            end else begin
              next_state = INITIATOR;
            end
        end //INITIATOR


        USB_MSG:
        begin
            next_state = SEND_MSG;
        end //USB_MSG


        SEND_MSG:
        begin
            if (auth_msg_resp_out) begin
              next_state = ACK;
            end else begin
              next_state = SEND_MSG;
            end
        end //SEND_MSG


        ACK:
        begin
            if (Ack_in) begin
              next_state = IDLE;
            end else begin
              next_state = ACK;
            end
        end //ACK

        default: next_state = IDLE;

    endcase
  end //ALWAYS

//-------------------------sequential logic-------------------------------------
  always @ (posedge clk) begin : FSM_SEQ
    if (reset == 1'b1) begin
      state <= IDLE;
    end
    else begin
      state <= next_state;
    end
  end // Always

//---------------------------output logic---------------------------------------
  always @ (negedge clk) begin : FSM_OUTPUT
    if (reset == 1'b1) begin
      auth_msg_resp_out_temp <= 1'b0;
    end
    else begin
      case (state)

        IDLE: begin
          auth_msg_resp_out_temp <= 1'b0;
          PD_in_ready_temp <= 1'b0;
          DEBUG_in_ready_temp <= 1'b0;
          auth_msg_ready_temp <= 1'b0;
        end

        GET_REQUESTER_MSG:
        begin
          pending_auth_request_temp <= 0;
          if (requester == 2'b01) begin
            PD_in_ready_temp <= 1'b1;
          end
          else if (requester == 2'b10) begin
            DEBUG_in_ready_temp <= 1'b1;
          end
          else begin
            PD_in_ready_temp <= 1'b0;
            DEBUG_in_ready_temp <= 1'b0;
          end
        end

        RESPONDER:
        begin
          Responder_Enable_temp <= 1'b1;
        end

        INITIATOR:
        begin
          Initiator_Enable_temp <= 1'b1;
        end

        USB_MSG:
        begin
          Responder_Enable_temp <= 1'b0;
          Initiator_Enable_temp <= 1'b0;
        end

        SEND_MSG:
        begin
          Responder_Enable_temp <= 1'b0;
          Initiator_Enable_temp <= 1'b0;
          auth_msg_resp_out_temp <= 256;
        end

        ACK:
        begin
          auth_msg_ready_temp <= 1'b1;
        end

        default: begin
          auth_msg_resp_out_temp <= 1'b0;
          PD_in_ready_temp <= 1'b0;
          DEBUG_in_ready_temp <= 1'b0;
        end

      endcase
    end
  end //Always-FSM_OUTPUT
//---------------------------End of always Code---------------------------------

assign Responder_Enable = Responder_Enable_temp;
assign Initiator_Enable = Initiator_Enable_temp;
assign auth_msg_ready = auth_msg_ready_temp;
assign auth_msg_resp_out = auth_msg_resp_out_temp;
assign PD_in_ready = PD_in_ready_temp;
assign DEBUG_in_ready = DEBUG_in_ready_temp;

endmodule // driver_authentication
