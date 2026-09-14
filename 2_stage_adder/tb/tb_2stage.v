`timescale 1ps / 1ps

module tb_baseline;
    reg  [1:0] A, B, C, D;
    reg        req_in, ack_in;
    wire [3:0] Sum_Tot;
    wire       ack_out, req_out;

    mousetrap_pipeline_top #(.DELAY_STAGE1(6), .DELAY_STAGE2(8)) uut (
        .A(A), .B(B), .C(C), .D(D),
        .req_in(req_in), .ack_in(ack_in),
        .Sum_Tot(Sum_Tot), .ack_out(ack_out), .req_out(req_out)
    );

    reg expected_req_out;

    initial begin
        $dumpfile("baseline_test.vcd");
        $dumpvars(0, tb_baseline);

        A = 0; B = 0; C = 0; D = 0;
        req_in = 0; ack_in = 0; 
        expected_req_out = 0;
        
        // Attendiamo che i Latch completino il rilascio a 100ps
        #150; 

        $display("[%0t] INIZIO TEST BASELINE", $time);
        
        A = 2'd1; B = 2'd2; 
        C = 2'd3; D = 2'd1; 
        req_in = 1; // Fronte di salita pulito

        wait(req_out != expected_req_out);
        $display("[%0t] BASELINE Completato: Risultato = %d (Atteso: 7)", $time, Sum_Tot);

        ack_in = 1; 
        expected_req_out = req_out;
        #50;

        $display("[%0t] Simulazione Baseline Terminata.", $time);
        $finish;
    end
endmodule