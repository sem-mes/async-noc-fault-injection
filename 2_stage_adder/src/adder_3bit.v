`timescale 1ns/1ps

module adder_3bit #(
    parameter tPD_XOR = 1,
    parameter tPD_AND = 1,
    parameter tPD_OR  = 1
) (
    input  wire [2:0] A,
    input  wire [2:0] B,
    input  wire       Cin,
    output wire [2:0] S,
    output wire       Cout
);

    wire c1, c2; // carry propagati tra i bit

    full_adder #(.tPD_XOR(tPD_XOR), .tPD_AND(tPD_AND), .tPD_OR(tPD_OR))
        fa0 (.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(c1));
    full_adder #(.tPD_XOR(tPD_XOR), .tPD_AND(tPD_AND), .tPD_OR(tPD_OR))
        fa1 (.A(A[1]), .B(B[1]), .Cin(c1),  .S(S[1]), .Cout(c2));
    full_adder #(.tPD_XOR(tPD_XOR), .tPD_AND(tPD_AND), .tPD_OR(tPD_OR))
        fa2 (.A(A[2]), .B(B[2]), .Cin(c2),  .S(S[2]), .Cout(Cout));

endmodule

// STA: T_3bit = tPD_XOR + 3*(tPD_AND + tPD_OR)
