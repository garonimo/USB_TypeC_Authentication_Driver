/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo genera el mensaje de GET_CERTIFICATE correspondiente
* a cada solicitud hecha por get_certificate_control
*
*/

module Get_Cert_generator
  (
    input wire clk,
    input wire reset,
    input wire Enable,
    input wire [1:0] slot,
    input wire [7:0] counter,
    input wire Ack_in,
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header,
    output wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload,
    output wire [7:0] expected_certificates,
    output wire Ack_out
  );

  parameter SLOT0 = 2'b00, SLOT1 = 2'b01, SLOT2 = 2'b10;

  reg [7:0] expected_certificates_temp = 0;
  reg [15:0] offset_counter = 0;
  reg offset_counter_enable = 1;
  reg Ack_out_temp = 0;
  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp = 0;
  reg [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp = 0;

//------------------------------------------------------------------------------

  always @ (posedge clk) begin
    if (Ack_in == 1'b1) begin
      offset_counter_enable = 1;
    end else begin
      offset_counter_enable = offset_counter_enable;
    end
    if (Enable == 1'b1) begin
      case(slot)

        SLOT0:
        begin
          expected_certificates_temp <= 6;
          header_temp <= `HEADER_CERTIFICATE_SLOT0;
          case(counter)

            1:
            begin
              offset_counter = 16'h0000;
              payload_temp = {offset_counter,`SLOT0_CERT1_LENGTH,2016'h0};
            end

            2:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT0_CERT1_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT0_CERT2_LENGTH,2016'h0};
            end

            3:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT0_CERT2_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT0_CERT3_LENGTH,2016'h0};
            end

            4:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT0_CERT3_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT0_CERT4_LENGTH,2016'h0};
            end

            5:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT0_CERT4_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT0_CERT5_LENGTH,2016'h0};
            end

            6:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT0_CERT5_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT0_CERT6_LENGTH,2016'h0};
            end

            default: Ack_out_temp <= 0;
          endcase
        end //SLOT0

//------------------------------------------------------------------------------

        SLOT1:
        begin
          expected_certificates_temp <= 4;
          header_temp <= `HEADER_CERTIFICATE_SLOT1;
          case(counter)

            1:
            begin
              offset_counter = 16'h0000;
              payload_temp = {offset_counter,`SLOT1_CERT1_LENGTH,2016'h0};
            end

            2:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT1_CERT1_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT1_CERT2_LENGTH,2016'h0};
            end

            3:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT1_CERT2_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT1_CERT3_LENGTH,2016'h0};
            end

            4:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT1_CERT3_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT1_CERT4_LENGTH,2016'h0};
            end

            default: Ack_out_temp <= 0;
          endcase
        end //SLOT1

//------------------------------------------------------------------------------

        SLOT2:
        begin
          expected_certificates_temp <= 5;
          header_temp <= `HEADER_CERTIFICATE_SLOT2;
          case(counter)

            1:
            begin
              offset_counter = 16'h0000;
              payload_temp = {offset_counter,`SLOT2_CERT1_LENGTH,2016'h0};
            end

            2:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT2_CERT1_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT2_CERT2_LENGTH,2016'h0};
            end

            3:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT2_CERT2_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT2_CERT3_LENGTH,2016'h0};
            end

            4:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT2_CERT3_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT2_CERT4_LENGTH,2016'h0};
            end

            5:
            begin
              if (offset_counter_enable) begin
                offset_counter = offset_counter + `SLOT2_CERT4_LENGTH;
                offset_counter_enable = 0;
              end else begin
                offset_counter = offset_counter;
              end
              payload_temp = {offset_counter,`SLOT2_CERT5_LENGTH,2016'h0};
            end

            default: Ack_out_temp <= 0;
          endcase
        end //SLOT2
//------------------------------------------------------------------------------

        default: Ack_out_temp <= 0;

      endcase // slot

      Ack_out_temp <= 1'b1;
    end  // if (Enable == 1'b1)
    else begin
      offset_counter_enable <= offset_counter_enable;
      Ack_out_temp <= 0;
      header_temp <= 0;
      payload_temp <= 0;
      offset_counter <= offset_counter;
    end
  end //Always


  assign expected_certificates = expected_certificates_temp;
  assign header = header_temp;
  assign payload = payload_temp;
  assign Ack_out = Ack_out_temp;

endmodule // Get_Cert_generator
