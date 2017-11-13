/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es para responder los mensajes de solicitud de certificados
*
*/


module get_certificate_answer
  (
    input wire clk,
    input wire Enable,
    input wire [`MSG_LEN-1:0] auth_msg_resp_in,
    input wire [`SIZE_OF_HEADER_VARS-1:0] Param1, //Slot a enviar
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header,
    output wire Ack_out,
    output wire Error_Invalid_Request,
    output wire [15:0] wLength,
    output wire [`MSG_LEN-1-(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES):0] payload
  );

  parameter SLOT0 = 2'b00, SLOT1 = 2'b01, SLOT2 = 2'b10;

  reg Ack_out_temp = 0;
  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp = 0;
  reg [`MSG_LEN-1-(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp = 0;
  reg [`MSG_LEN-1-(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES):0] Payload_in = 0;
  reg [15:0] offset,length = 0;
  reg Error_Invalid_Request_temp = 0;
  reg [15:0] wLength_temp = 0;


  always @ (posedge clk) begin
    if (Enable) begin
      Payload_in = auth_msg_resp_in[2047:0];
      header_temp = 0;
      payload_temp = 0;
      Ack_out_temp = 0;
      Error_Invalid_Request_temp = 0;
      wLength_temp = 0;
      offset = auth_msg_resp_in[`MSG_LEN-1-(4*`SIZE_OF_HEADER_VARS):`MSG_LEN-(6*`SIZE_OF_HEADER_VARS)];
      length = auth_msg_resp_in[`MSG_LEN-1-(6*`SIZE_OF_HEADER_VARS):`MSG_LEN-(8*`SIZE_OF_HEADER_VARS)];

////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////

      case (Param1)

        SLOT0:
        begin
          case (offset)
              0:
              begin
                if (length == `SLOT0_CERT1_LENGTH) begin
                  payload_temp <= `SLOT0_CERT1;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 0

              `SLOT0_CERT1_LENGTH:
              begin
                if (length == `SLOT0_CERT2_LENGTH) begin
                  payload_temp <= `SLOT0_CERT2;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 1

              (`SLOT0_CERT1_LENGTH+`SLOT0_CERT2_LENGTH):
              begin
                if (length == `SLOT0_CERT3_LENGTH) begin
                  payload_temp <= `SLOT0_CERT3;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 2

              (`SLOT0_CERT1_LENGTH+`SLOT0_CERT2_LENGTH+`SLOT0_CERT3_LENGTH):
              begin
                if (length == `SLOT0_CERT4_LENGTH) begin
                  payload_temp <= `SLOT0_CERT4;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 3

              (`SLOT0_CERT1_LENGTH+`SLOT0_CERT2_LENGTH+`SLOT0_CERT3_LENGTH+`SLOT0_CERT4_LENGTH):
              begin
                if (length == `SLOT0_CERT5_LENGTH) begin
                  payload_temp <= `SLOT0_CERT5;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 4

              (`SLOT0_CERT1_LENGTH+`SLOT0_CERT2_LENGTH+`SLOT0_CERT3_LENGTH+`SLOT0_CERT4_LENGTH+`SLOT0_CERT5_LENGTH):
              begin
                if (length == `SLOT0_CERT6_LENGTH) begin
                  payload_temp <= `SLOT0_CERT6;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 5

              default: Error_Invalid_Request_temp <= 1'b1;

          endcase
        end //case SLOT0

//------------------------------------------------------------------------------

          SLOT1:
          begin
            case (offset)
              0:
              begin
                if (length == `SLOT1_CERT1_LENGTH) begin
                  payload_temp <= `SLOT1_CERT1;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 0

              `SLOT1_CERT1_LENGTH:
              begin
                if (length == `SLOT1_CERT2_LENGTH) begin
                  payload_temp <= `SLOT1_CERT2;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 1

              (`SLOT1_CERT1_LENGTH+`SLOT1_CERT2_LENGTH):
              begin
                if (length == `SLOT1_CERT3_LENGTH) begin
                  payload_temp <= `SLOT1_CERT3;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 2

              (`SLOT1_CERT1_LENGTH+`SLOT1_CERT2_LENGTH+`SLOT1_CERT3_LENGTH):
              begin
                if (length == `SLOT1_CERT4_LENGTH) begin
                  payload_temp <= `SLOT1_CERT4;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 3

              default: Error_Invalid_Request_temp <= 1'b1;

            endcase
          end //case SLOT1

//------------------------------------------------------------------------------

          SLOT2: begin
            case (offset)
              0:
              begin
                if (length == `SLOT2_CERT1_LENGTH) begin
                  payload_temp <= `SLOT2_CERT1;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 0

              `SLOT2_CERT1_LENGTH:
              begin
                if (length == `SLOT2_CERT2_LENGTH) begin
                  payload_temp <= `SLOT2_CERT2;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 1

              (`SLOT2_CERT1_LENGTH+`SLOT2_CERT2_LENGTH):
              begin
                if (length == `SLOT2_CERT3_LENGTH) begin
                  payload_temp <= `SLOT2_CERT3;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 2

              (`SLOT2_CERT1_LENGTH+`SLOT2_CERT2_LENGTH+`SLOT2_CERT3_LENGTH):
              begin
                if (length == `SLOT2_CERT2_LENGTH) begin
                  payload_temp <= `SLOT2_CERT4;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 3

              (`SLOT2_CERT1_LENGTH+`SLOT0_CERT2_LENGTH+`SLOT2_CERT3_LENGTH+`SLOT2_CERT4_LENGTH):
              begin
                if (length == `SLOT2_CERT5_LENGTH) begin
                  payload_temp <= `SLOT2_CERT5;
                end else begin
                  Error_Invalid_Request_temp <= 1'b1;
                end
              end //case 4

              default: Error_Invalid_Request_temp <= 1'b1;
            endcase
          end //case SLOT2

          default: Error_Invalid_Request_temp = 1'b1;

        endcase //Param1
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
        header_temp = {`PROTOCOL_VERSION, `CERTIFICATE_ANSWER_CMD, Param1, 8'h00};
        wLength_temp <= length;
        Ack_out_temp = 1'b1;

    end //(Enable)
    else begin
      Payload_in = 0;
      header_temp = 0;
      payload_temp = 0;
      Ack_out_temp = 0;
      Error_Invalid_Request_temp = 0;
      wLength_temp = 0;
      offset = 0;
      length = 0;
    end
  end //Always


  assign header = header_temp;
  assign payload = payload_temp;
  assign Ack_out = Ack_out_temp;
  assign Error_Invalid_Request = Error_Invalid_Request_temp;
  assign wLength = wLength_temp;

endmodule // get_certificate_answer
