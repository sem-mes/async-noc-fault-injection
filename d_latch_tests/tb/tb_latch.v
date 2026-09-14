`timescale 1ns / 1ps

module tb_latch_fault;

    // Segnali di stimolo
    reg D;
    reg EN;

    // Uscite dei due latch
    wire Q_beh;
    wire Q_str;
    wire Qbar_str;

    D_latch_behavioral uut_beh (
        .D(D),
        .EN(EN),
        .Q(Q_beh)
    );

    D_latch_structural uut_str (
        .D(D),
        .EN(EN),
        .Q(Q_str),
        .Qbar(Qbar_str)
    );

    initial begin
        $dumpfile("latch_test.vcd");
        $dumpvars(0, tb_latch_fault);

        // CASO 1: Guasto in stato di HOLD (Memoria)

        D = 0; EN = 0;
        #10;

        // Scrittura di un dato valido
        D = 1; EN = 1;
        #10; // Q = 1 per entrambi

        // Fase di Hold
        EN = 0;
        #10;

        // INIEZIONE DEL GUASTO
        force uut_beh.Q = 1'b0;
        force uut_str.Q = 1'b0;
        #5; // Durata del guasto

        // RILASCIO DEL GUASTO
        release uut_beh.Q;
        release uut_str.Q;
        #20;

        // CASO 2: Guasto in stato di TRASPARENZA
        D = 1; EN = 1;
        #15; // Q torna a 1 per entrambi

        // INIEZIONE DEL GUASTO
        force uut_beh.Q = 1'b0;
        force uut_str.Q = 1'b0;
        #5;

        // RILASCIO DEL GUASTO
        release uut_beh.Q;
        release uut_str.Q;
        #20;


        // CASO 3: Sblocco del modello comportamentale
        D = 0;
        #10;
        D = 1;
        #10;

        $display("Test concluso. Controlla il file VCD.");
        $finish;
    end

endmodule
