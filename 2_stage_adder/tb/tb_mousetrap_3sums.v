`timescale 1ns/1ps
// tb_mousetrap_3sums.v
//
// Testbench FUNZIONALE (nessuna iniezione di guasti) per la pipeline
// MOUSETRAP a 2 stadi: esegue 3 somme differenti e verifica il risultato
// atteso, seguendo correttamente il protocollo a transizione (transition
// signaling) su req_in/ack_in e req_out/ack_out.
//
// L'unico uso di force/release e' quello, non legato ai guasti, necessario
// per inizializzare lo stato della pipeline: essendo i latch realizzati con
// NAND incrociate, allo start della simulazione la coppia di segnali
// (done, ack) che pilota ciascuna porta XNOR di controllo e' indefinita
// (X), e XNOR(X,X) resta X: si forzano quindi per un breve intervallo gli
// "enable" a 1 (latch trasparenti), dando tempo a tutta la catena di
// assestarsi su dati noti, poi si rilascia. Da quel momento la pipeline
// e' in stato "vuoto" coerente e si comporta come da specifica.

module tb_mousetrap_3sums;

    reg  [1:0] A0, B0, A1, B1;
    reg        req_in, ack_out;
    wire       ack_in, req_out;
    wire [3:0] Result;

    integer errors = 0;

    mousetrap_pipeline_2stage dut (
        .A0(A0), .B0(B0), .A1(A1), .B1(B1),
        .req_in(req_in), .ack_in(ack_in),
        .Result(Result), .req_out(req_out), .ack_out(ack_out)
    );

    // Invia un dato e verifica il risultato, seguendo il protocollo a
    // transizione: ogni nuovo dato inverte req_in; il consumo del
    // risultato inverte ack_out.
    task send_item;
        input [1:0] a0, b0, a1, b1;
        input [3:0] expected;
        begin
            A0 = a0; B0 = b0; A1 = a1; B1 = b1;
            #2; // i dati devono essere stabili PRIMA della request (bundled-data)
            req_in = ~req_in;

            wait (ack_in == req_in);
            $display("t=%0t  [ack_in]  stadio1 ha accettato A0=%0d B0=%0d A1=%0d B1=%0d",
                      $time, a0, b0, a1, b1);

            wait (req_out != ack_out);
            #1; // margine di osservazione dopo la request (coerente con la STA)
            if (Result === expected) begin
                $display("t=%0t  [req_out] Result=%0d  atteso=%0d  -> PASS", $time, Result, expected);
            end else begin
                $display("t=%0t  [req_out] Result=%0d  atteso=%0d  -> FAIL", $time, Result, expected);
                errors = errors + 1;
            end

            ack_out = ~ack_out;
        end
    endtask

    initial begin
        // ---- Inizializzazione della pipeline (non e' iniezione di guasti) ----
        A0 = 0; B0 = 0; A1 = 0; B1 = 0; req_in = 0; ack_out = 0;
        force dut.en_1 = 1'b1;
        force dut.en_2 = 1'b1;
        #25;
        release dut.en_1;
        release dut.en_2;
        #10;
        $display("t=%0t  --- pipeline inizializzata (stato vuoto, tutti i segnali noti) ---", $time);

        // ---- 3 somme differenti ----
        // Test 1: (1+2) + (3+1) = 3 + 4  = 7
        send_item(2'd1, 2'd2, 2'd3, 2'd1, 4'd7);

        // Test 2: (2+2) + (1+1) = 4 + 2  = 6
        send_item(2'd2, 2'd2, 2'd1, 2'd1, 4'd6);

        // Test 3: (3+3) + (3+3) = 6 + 6  = 12  (esercita entrambi i riporti)
        send_item(2'd3, 2'd3, 2'd3, 2'd3, 4'd12);

        #20;
        if (errors == 0)
            $display("\n*** TUTTI I TEST PASSATI (3/3) ***");
        else
            $display("\n*** %0d TEST FALLITI ***", errors);

        $finish;
    end

endmodule
