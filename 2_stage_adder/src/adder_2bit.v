`timescale 1ns/1ps
// adder_2bit.v
// Adder a 2 bit (ripple carry) - implementazione STRUTTURALE
// Richiede full_adder.v nello stesso progetto di compilazione

module adder_2bit #(
    parameter tPD_XOR = 1,
    parameter tPD_AND = 1,
    parameter tPD_OR  = 1
) (
    input  wire [1:0] A,
    input  wire [1:0] B,
    input  wire       Cin,
    output wire [1:0] S,
    output wire       Cout
);

    wire c1; // carry propagato dal bit 0 al bit 1

    full_adder #(.tPD_XOR(tPD_XOR), .tPD_AND(tPD_AND), .tPD_OR(tPD_OR))
        fa0 (.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(c1));
    full_adder #(.tPD_XOR(tPD_XOR), .tPD_AND(tPD_AND), .tPD_OR(tPD_OR))
        fa1 (.A(A[1]), .B(B[1]), .Cin(c1),  .S(S[1]), .Cout(Cout));

endmodule

// STA: ingressi A,B,Cin assunti stabili nello stesso istante (provengono
// dallo stesso rango di latch). Percorso critico verso Cout finale:
//   T_2bit = tPD_XOR + 2*(tPD_AND + tPD_OR)
