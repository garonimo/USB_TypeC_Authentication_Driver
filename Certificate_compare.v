/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es para verificar los certificados
*
*/


module certificate_compare
  (
    input wire clk,
    input wire Enable,
    input wire Reset,
    input wire [1:0] slot,
    input wire [7:0] counter,
    input wire [`MSG_LEN-1-(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES):0] Payload_in,
    output wire Error_Invalid_Certificate,
    output wire Valid_Certificate
  );

  parameter SLOT0 = 2'b00, SLOT1 = 2'b01, SLOT2 = 2'b10;

  reg Error_Invalid_Certificate_temp, Valid_Certificate_temp;

  always @ (posedge clk) begin

    if ((Enable) && (!Reset)) begin

    ////////////////////////////////////////////////////////////////////////////////
    //------------------------------------------------------------------------------
    ////////////////////////////////////////////////////////////////////////////////

      case (slot)

        SLOT0:
        begin
          case(counter)

            1:
            begin
              if (Payload_in == `SLOT0_CERT1) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 1

            2:
            begin
              if (Payload_in == `SLOT0_CERT2) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 2

            3:
            begin
              if (Payload_in == `SLOT0_CERT3) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 3

            4:
            begin
              if (Payload_in == `SLOT0_CERT4) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 4

            5:
            begin
              if (Payload_in == `SLOT0_CERT5) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 5

            6:
            begin
              if (Payload_in == `SLOT0_CERT6) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 6

            default:
            begin
              Error_Invalid_Certificate_temp <= 1'b0;
              Valid_Certificate_temp <= 1'b0;
            end

          endcase //counter
        end // SLOT0

//------------------------------------------------------------------------------

        SLOT1:
        begin
          case(counter)

            1:
            begin
              if (Payload_in == `SLOT1_CERT1) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 1

            2:
            begin
              if (Payload_in == `SLOT1_CERT2) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 2

            3:
            begin
              if (Payload_in == `SLOT1_CERT3) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 3

            4:
            begin
              if (Payload_in == `SLOT1_CERT4) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 4

            default:
            begin
              Error_Invalid_Certificate_temp <= 1'b0;
              Valid_Certificate_temp <= 1'b0;
            end

          endcase //counter
        end // SLOT1

//------------------------------------------------------------------------------

        SLOT2:
        begin
          case(counter)

            1:
            begin
              if (Payload_in == `SLOT2_CERT1) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 1

            2:
            begin
              if (Payload_in == `SLOT2_CERT2) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 2

            3:
            begin
              if (Payload_in == `SLOT2_CERT3) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 3

            4:
            begin
              if (Payload_in == `SLOT2_CERT4) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 4

            5:
            begin
              if (Payload_in == `SLOT2_CERT5) begin
                Valid_Certificate_temp <= 1'b1;
              end else begin
                Error_Invalid_Certificate_temp <= 1'b1;
              end
            end // 5

            default:

            begin
              Error_Invalid_Certificate_temp <= 1'b0;
              Valid_Certificate_temp <= 1'b0;
            end

          endcase //counter
        end // SLOT2

//------------------------------------------------------------------------------

        default:
        begin
          Error_Invalid_Certificate_temp <= 1'b0;
          Valid_Certificate_temp <= 1'b0;
        end
      endcase //slot

    end //if ((Enable) && (!Reset))
    else begin
      Error_Invalid_Certificate_temp <= 1'b0;
      Valid_Certificate_temp <= 1'b0;
    end

  end //always


  assign Error_Invalid_Certificate = Error_Invalid_Certificate_temp;
  assign Valid_Certificate = Valid_Certificate_temp;

endmodule //certificate_compare
