`timescale 10ns/1ps

module BUF(A, Y);
input A;
output Y;
//assign #(0.2) Y = A;
assign Y = A;
endmodule

module NOT(A, Y);
input A;
output Y;
//assign #(0.2) Y = ~A;
assign Y = ~A;
endmodule

module NAND(A, B, Y);
input A, B;
output Y;
//assign #(0.2) Y = ~(A & B);
assign Y = ~(A & B);
endmodule

module NOR(A, B, Y);
input A, B;
output Y;
//assign #(0.2) Y = ~(A | B);
assign Y = ~(A | B);
endmodule

/* resto de la biblioteca */
