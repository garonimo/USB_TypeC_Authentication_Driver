/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es el control para la obtencion de una cadena de
* certificados.
*/

`include "Parameters.v"

module certificate_control
  (
    input wire clk,
    input wire reset,
    input wire Enable,
    input wire [1:0] slot,
    input wire [`MSG_LEN-1:0] auth_msg_init_in,
    input wire Ack_in,
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header,
    output wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload,
    output wire Ack_out,
    output wire pending_authentication,
    output wire Certification_done,
    output wire Certification_failed
  );

  //-------------------------------Parámetros-----------------------------------
  parameter IDLE = 9'b000000001, CREATE_CERTIFICATE_MSG = 9'b000000010;
  parameter WAIT_CERTIFICATE_RESPONSE = 9'b00001000;
  parameter ACK = 9'b000000100, NUMB_OF_CERTIFICATES = 9'b000010000;
  parameter END  = 9'b000100000;

  //--------------------------------Variables-----------------------------------
  wire [7:0] counter;
  reg counter_enable = 1;
  reg [7:0] counter_temp = 0;
  reg Error_authentication_failed = 0;
  wire [7:0] expected_certificates;
  //Handshakes
  reg Ack_out_temp;
  wire Cert_Generator_enable;
  wire Ack_in_Cert_Generator;
  wire Ack_out_GetCert;
  reg Ack_out_GetCert_temp;
  reg Cert_Generator_enable_temp;
  reg pending_authentication_temp;
  reg Certification_done_temp, Certification_failed_temp;
  reg Valid_Certificate = 1;
  //Variables de estado
  reg [`SIZE_OF_STATES_INIT-1:0] state, next_state;

  //////////////////////////////////////////////////////////////////////////////
  //-------------------------Inicio del código----------------------------------
  //////////////////////////////////////////////////////////////////////////////

  Get_Cert_generator Gen_of_GetCertificates
    (
      .clk(clk),
      .reset(reset),
      .Enable(Cert_Generator_enable),
      .slot(slot),
      .counter(counter),
      .Ack_in(Ack_out_GetCert),
      .header(header),
      .payload(payload),
      .expected_certificates(expected_certificates),
      .Ack_out(Ack_in_Cert_Generator)
    );

  ////////////////////////////////////////////////////////////////////////////////
  //-------------------------Máquina de estados-----------------------------------
  ////////////////////////////////////////////////////////////////////////////////

  //----------------------Lógica combinacional------------------------------------

  always @ (*) begin : CERT_CTRL_COMB
    next_state = 0;
    case (state)

      IDLE:
      begin
        if (Enable == 1'b1) begin
          next_state = CREATE_CERTIFICATE_MSG;
        end
        else begin
          next_state = IDLE;
        end
      end //IDLE


      CREATE_CERTIFICATE_MSG:
      begin
        if (Ack_in_Cert_Generator == 1'b1) begin
          next_state = ACK;
        end else begin
          next_state = CREATE_CERTIFICATE_MSG;
        end
      end //CREATE_CERTIFICATE_MSG


      ACK:
      begin
        if (Ack_in == 1'b1) begin
          next_state = WAIT_CERTIFICATE_RESPONSE;
        end else begin
          next_state = ACK;
        end
      end //ACK


      WAIT_CERTIFICATE_RESPONSE:
      begin
        if ((Enable == 1'b1) && (Ack_in == 1'b0)) begin
          //Aqui se determina si el certificado es valido o no, pero esto se
          //hace en alto nivel
          if (Valid_Certificate) begin
            next_state = NUMB_OF_CERTIFICATES;
          end else begin
            next_state = END;
          end
        end // if (Enable == 1'b1) && (Ack_in == 1'b0)
        else begin
          next_state = WAIT_CERTIFICATE_RESPONSE;
        end
      end //WAIT_CERTIFICATE_RESPONSE


      NUMB_OF_CERTIFICATES:
      begin
        if (counter_temp == expected_certificates) begin
          next_state = END;
        end else begin
          next_state = CREATE_CERTIFICATE_MSG;
        end
      end //NUMB_OF_CERTIFICATES


      END:
      begin
        if (pending_authentication == 1'b0) begin
          next_state <= IDLE;
        end else begin
          next_state <= END;
        end
      end //END

      default: next_state = IDLE;
    endcase

  end //Always-CERT_CTRL

  //---------------------------Lógica secuencial---------------------------------
  always @ (posedge clk) begin : GET_CERT_SEQ
    if (reset == 1'b1) begin
        state <= IDLE;
    end
    else if (Error_authentication_failed) begin
        state <= END;
    end
    else begin
        state <= next_state;
      end
  end // Always

  //---------------------------Lógica de salida------------------------------------

  always @ (negedge clk) begin : GET_CERT_OUTPUT
    if (reset == 1'b1) begin
      Certification_done_temp <=  1'b0;
    end//If-reset
    else begin
      case (state)

        IDLE:
        begin
          counter_temp <= 0;
          Ack_out_temp <= 1'b0;
        end

        CREATE_CERTIFICATE_MSG:
        begin
          pending_authentication_temp <= 1'b1;
          Ack_out_temp <= 1'b0;
          Cert_Generator_enable_temp <= 1'b1;
          if (counter_enable) begin
            counter_temp  <= counter_temp + 1;
            counter_enable  <= 1'b0;
          end else begin
            counter_temp  <= counter_temp;
          end
        end

        ACK:
        begin
          Ack_out_GetCert_temp <= 1'b1;
          counter_enable  <= 1'b1;
          Cert_Generator_enable_temp <= 1'b0;
          Ack_out_temp <= 1'b1;
        end

        WAIT_CERTIFICATE_RESPONSE:
        begin
          Ack_out_temp <= 1'b0;
        end

        NUMB_OF_CERTIFICATES:
        begin
          Ack_out_GetCert_temp <= 1'b0;
        end

        END:
        begin
          Ack_out_GetCert_temp <= 1'b0;
          if (!Error_authentication_failed) begin
            Certification_done_temp <=  1'b1;
          end else begin
            Certification_failed_temp <= 1'b1;
            Error_authentication_failed <= 0;
          end
          pending_authentication_temp <= 1'b0;
        end

        default: Ack_out_temp <= 1'b0;
      endcase
    end//else -If reset

  end //Always-GET_CERT_OUTPUT

  //---------------------------Fin de FSM---------------------------------------

  assign Ack_out = Ack_out_temp;
  assign Cert_Generator_enable = Cert_Generator_enable_temp;
  assign pending_authentication = pending_authentication_temp;
  assign Certification_done = Certification_done_temp;
  assign counter = counter_temp;
  assign Certification_failed = Certification_failed_temp;
  assign Ack_out_GetCert = Ack_out_GetCert_temp;

endmodule // certificate_control
