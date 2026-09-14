//   S    = A xor B xor Cin
//   Cout = (A and B) or (Cin and (A xor B))

module full_adder (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire S,
    output wire Cout
);

    wire axb;          // A xor B
    wire a_and_b;       // A and B
    wire axb_and_cin;   // (A xor B) and Cin

    xor g1 (axb, A, B);
    xor g2 (S, axb, Cin);

    and g3 (a_and_b, A, B);
    and g4 (axb_and_cin, axb, Cin);
    or  g5 (Cout, a_and_b, axb_and_cin);

endmodule
