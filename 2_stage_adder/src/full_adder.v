`timescale 1ns/1ps

//   S    = A xor B xor Cin
//   Cout = (A and B) or (Cin and (A xor B))

module full_adder #(
    parameter tPD_XOR = 1, // ritardo delle porte XOR
    parameter tPD_AND = 1, // ritardo delle porte AND
    parameter tPD_OR  = 1  // ritardo della porta OR
) (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire S,
    output wire Cout
);

    wire axb;          	// A xor B
    wire a_and_b;       // A and B
    wire axb_and_cin;   // (A xor B) and Cin

    xor #(tPD_XOR) g1 (axb, A, B);
    xor #(tPD_XOR) g2 (S, axb, Cin);

    and #(tPD_AND) g3 (a_and_b, A, B);
    and #(tPD_AND) g4 (axb_and_cin, axb, Cin);
    or  #(tPD_OR)  g5 (Cout, a_and_b, axb_and_cin);

endmodule
