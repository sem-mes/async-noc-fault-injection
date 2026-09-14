module adder_2bit (
    input  wire [1:0] A,
    input  wire [1:0] B,
    input  wire       Cin,
    output wire [1:0] S,
    output wire       Cout
);

    wire c1; // carry propagato dal bit 0 al bit 1

    full_adder fa0 (.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(c1));
    full_adder fa1 (.A(A[1]), .B(B[1]), .Cin(c1),  .S(S[1]), .Cout(Cout));

endmodule
