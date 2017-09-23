/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo contiene la FSM de lógica de obtención, lectura y
* entrega de certificados y/ o información sobre estos
*/

module driver_authentication_test
  (
    input wire CC1,
    input wire CC2,
    input wire clk,
    input wire reset,
    output wire TX2_m,
    output wire TX2_p
  );

//Constants in bits
  parameter size_of_states_reg = 3;
//states
  parameter IDLE = 3'b001, STATE1 = 3'b010, STATE2 = 3'b100;
//Constants in bytes
  parameter MaxLeafCertSize = 640, MaxIntermediateCertSize = 512, MaxACDSize = 128, MaxCertChainSize = 4096;
//Internal variables
  reg [size_of_states_reg-1:0] state, next_state;
  reg TX2_m_Temp, TX2_p_Temp;

//----------------------Combinational Logic-------------------------------------
  always @ (*) begin : FSM_COMB
    next_state = 3'b000;
    case (state)
        IDLE: begin
              if (CC1 == 1'b1) begin
                next_state = STATE1;
              end
              else if (CC2 == 1'b1) begin
                next_state = STATE2;
              end
              else begin
                next_state = IDLE;
              end
        end //IDLE

        STATE1: begin
              if (CC1 == 1'b1) begin
                next_state = STATE1;
              end
              else begin
                next_state = IDLE;
              end
        end //STATE1

        STATE2: begin
              if (CC2 == 1'b1) begin
                next_state = STATE2;
              end
              else begin
                next_state = IDLE;
              end
        end //STATE2

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
  always @ (posedge clk) begin : FSM_OUTPUT
    if (reset == 1'b1) begin
      TX2_m_Temp <= 1'b0;
      TX2_p_Temp <= 1'b0;
    end
    else begin
      case (state)

        IDLE: begin
          TX2_m_Temp <= 1'b0;
          TX2_p_Temp <= 1'b0;
        end

        STATE1: begin
          TX2_m_Temp <= 1'b1;
          TX2_p_Temp <= 1'b0;
        end

        STATE2: begin
          TX2_m_Temp <= 1'b0;
          TX2_p_Temp <= 1'b1;
        end

        default: begin
          TX2_m_Temp <= 1'b0;
          TX2_p_Temp <= 1'b0;
        end

      endcase
    end
  end //Always-FSM_OUTPUT
//---------------------------End of always Code---------------------------------

assign TX2_m = TX2_m_Temp;
assign TX2_p = TX2_p_Temp;

endmodule // driver_authentication
