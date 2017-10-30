/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo contiene
*/


module authentication_driver
  (
    input wire clk,
    input wire reset,
    input wire [`MSG_LEN-1:0] auth_msg_in,
    input wire Ack_in,
    input wire [7:0] pending_auth_request_PD,
    input wire [7:0] pending_auth_request_DEBUG,
    output wire pending_auth_request_PD_erase,
    output wire pending_auth_request_DEBUG_erase,
    output wire PD_in_ready,
    output wire DEBUG_in_ready,
    output wire auth_msg_ready,
    output wire Error_authentication_failed,
    output wire [`MSG_LEN-1:0] auth_msg_out
  );

  //-------------------------------Parámetros-----------------------------------
  //estados
  parameter IDLE = 9'b000000001, GET_DATA_OF_REQUESTER_PD = 9'b000000010;
  parameter GET_REQUESTER_MSG = 9'b000000100;
  parameter RESPONDER = 9'b000001000, INITIATOR = 9'b000010000;
  parameter USB_MSG = 9'b000100000, GET_DATA_OF_REQUESTER_DEBUG = 9'b001000000;
  parameter SEND_MSG = 9'b010000000, ACK = 9'b100000000;

//Internal variables
  reg [`SIZE_OF_STATES_DRIVER-1:0] state, next_state;
  reg [7:0] current_auth_request;
  reg counter = 0;
  reg [1:0] requester,initiator_or_responder,USB_or_not;
  wire Error_Busy_Responder, Error_Busy_Initiator;

//handshakes
  wire Responder_Enable, Responder_ready;
  wire Initiator_Enable, Initiator_ready;
  wire pending_init_msg;
  wire [1:0] slot;
  reg [1:0] slot_temp;
  reg  Responder_Enable_temp, Initiator_Enable_temp;
  reg auth_msg_ready_temp;
  reg PD_in_ready_temp,DEBUG_in_ready_temp;
  reg [7:0] auth_msg_resp_out_temp;
  reg pending_auth_request_PD_erase_temp = 0;
  reg pending_auth_request_DEBUG_erase_temp = 0;

//Auth MSG Variables
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header;
  reg [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp;
  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp;
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_responder;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_responder;
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_initiator;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_initiator;
  reg [`MSG_LEN-1:0] auth_msg_out_temp;
  wire Ack_out_resp, Ack_out_init;
  reg Ack_out_resp_temp, Ack_out_init_temp;
  wire [7:0] bmRequestType, bmRequestType_Responder, bmRequestType_Initiator;
  wire [7:0] bRequest, bRequest_Responder, bRequest_Initiator;
  wire [15:0] wLength, wLength_Responder, wLength_Initiator;
  reg [7:0] bmRequestType_temp;
  reg [7:0] bRequest_temp;
  reg [15:0] wLength_temp;
  wire [31:0] current_timeout_responder;
  wire [31:0] current_timeout_initiator;
  wire [1:0] type_of_request;
  reg [1:0] type_of_request_temp;

////////////////////////////////////////////////////////////////////////////////
//-------------------------Inicio del código------------------------------------
////////////////////////////////////////////////////////////////////////////////

  responder resp_test
    (
      .clk(clk),
      .reset(reset),
      .resp_req_in(Responder_Enable),
      .auth_msg_resp_in(auth_msg_in),
      .Ack_in(Ack_out_resp),
      .resp_req_out(Responder_ready),
      .bmRequestType(bmRequestType_Responder),
      .bRequest(bRequest_Responder),
      .wLength(wLength_Responder),
      .current_timeout(current_timeout_responder),
      .header(header_responder),
      .payload(payload_responder)
    );

  initiator initiator_driver
    (
      .clk(clk),
      .reset(reset),
      .init_req_in(Initiator_Enable),
      .auth_msg_init_in(auth_msg_in),
      .Ack_in(Ack_out_init),
      .type_of_request(type_of_request),
      .Ack_out(Initiator_ready),
      .bmRequestType(bmRequestType_Initiator),
      .bRequest(bRequest_Initiator),
      .wLength(wLength_Initiator),
      .current_timeout(current_timeout_initiator),
      .pending_auth_msg_to_send(pending_init_msg),
      .payload(payload_initiator),
      .slot(slot),
      .Error_authentication_failed(Error_authentication_failed),
      .header(header_initiator)
    );

  timeout timeout_controller_responder
    (
      .clk(clk),
      .Enable(pending_auth_request_PD),
      .Enable_Init_or_Resp(Responder_Enable),
      .reset(reset),
      .auth_msg_ready(auth_msg_ready),
      .current_timeout(current_timeout_responder),
      .Error_Busy(Error_Busy_Responder)
    );

  timeout timeout_controller_initiator
    (
      .clk(clk),
      .Enable(pending_auth_request_DEBUG),
      .Enable_Init_or_Resp(Responder_Enable),
      .reset(reset),
      .auth_msg_ready(auth_msg_ready),
      .current_timeout(current_timeout_initiator),
      .Error_Busy(Error_Busy_Initiator)
    );


////////////////////////////////////////////////////////////////////////////////
//-------------------------Máquina de estados-----------------------------------
////////////////////////////////////////////////////////////////////////////////

//----------------------Lógica combinacional------------------------------------
  always @ (*) begin : FSM_COMB
    next_state = 0;
    case (state)

        IDLE: begin
            case (counter)

              0:
              begin
                if (pending_auth_request_DEBUG) begin
                  next_state = GET_DATA_OF_REQUESTER_DEBUG;
                end
                else begin
                  next_state = IDLE;
                end
              end // 0

              1:
              begin
                if (pending_auth_request_PD) begin
                  next_state = GET_DATA_OF_REQUESTER_PD;
                end
                else begin
                  next_state = IDLE;
                end
              end // 1


              default: next_state = IDLE;
            endcase
        end //IDLE


        GET_DATA_OF_REQUESTER_PD:
        begin
              current_auth_request = pending_auth_request_PD;
              slot_temp = current_auth_request[7:6];
              initiator_or_responder = current_auth_request[5:4];
              USB_or_not = current_auth_request[3:2];
              type_of_request_temp = current_auth_request[1:0];
              next_state = GET_REQUESTER_MSG;
        end //GET_DATA_OF_REQUESTER_PD


        GET_DATA_OF_REQUESTER_DEBUG:
        begin
              current_auth_request = pending_auth_request_DEBUG;
              slot_temp = current_auth_request[7:6];
              initiator_or_responder = current_auth_request[5:4];
              USB_or_not = current_auth_request[3:2];
              type_of_request_temp = current_auth_request[1:0];
              next_state = GET_REQUESTER_MSG;
        end //GET_DATA_OF_REQUESTER_DEBUG


        GET_REQUESTER_MSG:
        begin
            if (initiator_or_responder == 2'b01) begin
              next_state = RESPONDER;
            end
            else if (initiator_or_responder == 2'b10) begin
              next_state = INITIATOR;
            end
            else begin
              next_state = IDLE;
            end
        end //GET_REQUESTER_MSG


        RESPONDER:
        begin
            if (Responder_ready == 1'b1) begin
                next_state = SEND_MSG;
            end else begin
              next_state = RESPONDER;
            end
        end //RESPONDER


        INITIATOR:
        begin
            if (Initiator_ready == 1'b1) begin
                next_state = SEND_MSG;
            end else begin
              next_state = INITIATOR;
            end
        end //RESPONDER


        SEND_MSG:
        begin
            if (auth_msg_out) begin
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
      auth_msg_out_temp <= 1'b0;
    end
    else begin
      case (state)

        IDLE:
        begin
          counter += 1;
          Ack_out_resp_temp <= 1'b0;
          auth_msg_out_temp <= 1'b0;
          PD_in_ready_temp <= 1'b0;
          DEBUG_in_ready_temp <= 1'b0;
          auth_msg_ready_temp <= 1'b0;
        end

        GET_DATA_OF_REQUESTER_PD:
        begin
          PD_in_ready_temp <= 1'b1;
        end

        GET_DATA_OF_REQUESTER_DEBUG:
        begin
          DEBUG_in_ready_temp <= 1'b1;
        end

        GET_REQUESTER_MSG:
        begin
          if (!counter) begin
            pending_auth_request_DEBUG_erase_temp <= 1'b1;
          end else begin
            pending_auth_request_PD_erase_temp <= 1'b1;
          end
        end

        RESPONDER:
        begin
          header_temp <= header_responder;
          payload_temp <= payload_responder;
          bmRequestType_temp <= bmRequestType_Responder;
          bRequest_temp <= bRequest_Responder;
          wLength_temp <= wLength_Responder;
          Responder_Enable_temp <= 1'b1;
        end

        INITIATOR:
        begin
          header_temp <= header_initiator;
          payload_temp <= payload_initiator;
          bmRequestType_temp <= bmRequestType_Initiator;
          bRequest_temp <= bRequest_Initiator;
          wLength_temp <= wLength_Initiator;
          Initiator_Enable_temp <= 1'b1;
        end

        SEND_MSG:
        begin
          Ack_out_init_temp <= 1'b1;
          Ack_out_resp_temp <= 1'b1;
          Responder_Enable_temp <= 1'b0;
          Initiator_Enable_temp <= 1'b0;
          if (USB_or_not) begin
            auth_msg_out_temp <= {bmRequestType,bRequest,header,wLength,payload};
          end else begin
            auth_msg_out_temp <= {header,payload};
          end
        end

        ACK:
        begin
          Ack_out_init_temp <= 1'b0;
          Ack_out_resp_temp <= 1'b0;
          auth_msg_ready_temp <= 1'b1;
        end

        default: begin
          auth_msg_out_temp <= 1'b0;
          PD_in_ready_temp <= 1'b0;
          DEBUG_in_ready_temp <= 1'b0;
          auth_msg_ready_temp <= 1'b0;
        end

      endcase
    end
  end //Always-FSM_OUTPUT
//---------------------------End of always Code---------------------------------

assign Responder_Enable = Responder_Enable_temp;
assign Initiator_Enable = Initiator_Enable_temp;
assign auth_msg_ready = auth_msg_ready_temp;
assign auth_msg_out = auth_msg_out_temp;
assign PD_in_ready = PD_in_ready_temp;
assign DEBUG_in_ready = DEBUG_in_ready_temp;
assign Ack_out_resp = Ack_out_resp_temp;
assign type_of_request = type_of_request_temp;
assign bmRequestType = bmRequestType_temp;
assign bRequest = bRequest_temp;
assign wLength = wLength_temp;
assign header = header_temp;
assign payload = payload_temp;
assign Ack_out_init = Ack_out_init_temp;
assign slot = slot_temp;
assign pending_auth_request_PD_erase = pending_auth_request_PD_erase_temp;
assign pending_auth_request_DEBUG_erase = pending_auth_request_DEBUG_erase_temp;

endmodule // driver_authentication
