`timescale 1ps / 1ps

module mousetrap_pipeline_top #(
    parameter DELAY_STAGE1 = 5, 
    parameter DELAY_STAGE2 = 7  
)(
    input  wire [1:0] A, B, C, D,
    input  wire       req_in,
    input  wire       ack_in,
    output wire [3:0] Sum_Tot,
    output wire       ack_out,
    output wire       req_out
);

    wire       done_1;
    wire       done_2;
    wire       done_3;
    wire       req_to_stage2;
    wire       req_to_stage3;
    
    wire [7:0] latched_inputs;
    wire [2:0] sum_1A, sum_1B;
    wire [5:0] latched_intermediate;
    wire [3:0] sum_final_comb;

    mousetrap_stage #(.WIDTH(8)) stage1 (
        .D({A, B, C, D}),
        .req(req_in),
        .ack(done_2),         
        .Q(latched_inputs),
        .done(done_1),
        .en()                 
    );

    assign ack_out = done_1;  

    adder_2bit add1A (
        .A(latched_inputs[7:6]), .B(latched_inputs[5:4]), .Cin(1'b0),
        .S(sum_1A[1:0]), .Cout(sum_1A[2])
    );
    
    adder_2bit add1B (
        .A(latched_inputs[3:2]), .B(latched_inputs[1:0]), .Cin(1'b0),
        .S(sum_1B[1:0]), .Cout(sum_1B[2])
    );

    delay_element #(.DELAY(DELAY_STAGE1)) delay1 (
        .in(done_1), .out(req_to_stage2)
    );

    mousetrap_stage #(.WIDTH(6)) stage2 (
        .D({sum_1A, sum_1B}),
        .req(req_to_stage2),
        .ack(done_3),         
        .Q(latched_intermediate),
        .done(done_2),
        .en()
    );

    adder_3bit add2 (
        .A(latched_intermediate[5:3]), .B(latched_intermediate[2:0]), .Cin(1'b0),
        .S(sum_final_comb[2:0]), .Cout(sum_final_comb[3])
    );

    delay_element #(.DELAY(DELAY_STAGE2)) delay2 (
        .in(done_2), .out(req_to_stage3)
    );

    mousetrap_stage #(.WIDTH(4)) stage3 (
        .D(sum_final_comb),
        .req(req_to_stage3),
        .ack(ack_in),         
        .Q(Sum_Tot),
        .done(done_3),
        .en()
    );

    assign req_out = done_3; 

endmodule