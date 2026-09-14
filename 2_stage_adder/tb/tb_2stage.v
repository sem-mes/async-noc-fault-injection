`timescale 1ps / 1ps

module tb_pipeline_fault;

    // Segnali di interfaccia
    reg  [1:0] A, B, C, D;
    reg        req_in;
    reg        ack_in;
    wire [3:0] Sum_Tot;
    wire       ack_out;
    wire       req_out;

    // Registro temporaneo per aggirare il limite del "force" dinamico
    reg        temp_fault_val;

    // Dimensionamento STA
    localparam D1 = 6;
    localparam D2 = 8;

    mousetrap_pipeline_top #(
        .DELAY_STAGE1(D1),
        .DELAY_STAGE2(D2)
    ) uut (
        .A(A), .B(B), .C(C), .D(D),
        .req_in(req_in), .ack_in(ack_in),
        .Sum_Tot(Sum_Tot),
        .ack_out(ack_out), .req_out(req_out)
    );

    reg expected_req_out;

    initial begin
        $dumpfile("pipeline_test.vcd");
        $dumpvars(0, tb_pipeline_fault);

        A = 0; B = 0; C = 0; D = 0;
		req_in = 0; ack_in = 0; expected_req_out = 0;
		temp_fault_val = 0;
		
		// Sblocco forzato dello stato X iniziale
		force uut.stage1.en = 1;
		force uut.stage2.en = 1;
		force uut.stage3.en = 1;
		#10;
		release uut.stage1.en;
		release uut.stage2.en;
		release uut.stage3.en;
		
		#40; // Completa l'attesa iniziale

        // TEST 1: Baseline
        $display("[%0t] INIZIO TEST 1: Transazione pulita", $time);
        A = 2'd1; B = 2'd2; 
        C = 2'd3; D = 2'd1; 
        req_in = ~req_in;

        wait(req_out != expected_req_out);
        $display("[%0t] TEST 1 Completato: Risultato = %d (Atteso: 7)", $time, Sum_Tot);

        ack_in = ~ack_in; 
        expected_req_out = req_out;
        #50;

        // TEST 2: SEU Datapath
        $display("[%0t] INIZIO TEST 2: SEU su Latch Dati", $time);
        A = 2'd2; B = 2'd2; 
        C = 2'd1; D = 2'd1; 
        req_in = ~req_in;

        wait(ack_out == req_in);
        #2; 

        $display("[%0t] INIEZIONE FORCE: Alterazione di uut.latched_inputs[4]", $time);
        force uut.latched_inputs[4] = 1'b1;

        #50; 
        release uut.latched_inputs[4];
        $display("[%0t] RELEASE eseguito", $time);

        wait(req_out != expected_req_out);
        $display("[%0t] TEST 2 Completato: Risultato = %d (Atteso pulito: 6)", $time, Sum_Tot);

        ack_in = ~ack_in;
        expected_req_out = req_out;
        #50;

        // TEST 3: SEU Controllo
        $display("[%0t] INIZIO TEST 3: SEU su Latch di Controllo", $time);
        A = 2'd3; B = 2'd3; 
        C = 2'd0; D = 2'd1; 
        req_in = ~req_in;

        wait(ack_out == req_in);
        #2;

        $display("[%0t] INIEZIONE FORCE: Alterazione di uut.done_2", $time);
        
        // FIX: Campionamento statico del guasto
        temp_fault_val = ~uut.done_2;
        force uut.done_2 = temp_fault_val;

        #50;
        release uut.done_2;
        $display("[%0t] RELEASE eseguito", $time);

        begin : timeout_block
            fork
                begin
                    wait(req_out != expected_req_out);
                    $display("[%0t] TEST 3 Completato: Risultato = %d", $time, Sum_Tot);
                    ack_in = ~ack_in;
                    expected_req_out = req_out;
                    disable timeout_block;
                end
                begin
                    #200;
                    $display("[%0t] TEST 3 ERRORE FATALE: Stallo della pipeline rilevato (Deadlock).", $time);
                    disable timeout_block; 
                end
            join
        end

        #50;
        $display("[%0t] Simulazione Terminata.", $time);
        $finish;
    end
endmodule