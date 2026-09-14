module adder_3bit (
    input  wire [2:0] A,
    input  wire [2:0] B,
    input  wire       Cin,
    output wire [2:0] S,
    output wire       Cout
);

    wire c1, c2; // carry propagati tra i bit

    full_adder fa0 (.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(c1));
    full_adder fa1 (.A(A[1]), .B(B[1]), .Cin(c1),  .S(S[1]), .Cout(c2));
    full_adder fa2 (.A(A[2]), .B(B[2]), .Cin(c2),  .S(S[2]), .Cout(Cout));

endmodule
