`timescale 1ns/1ps

// Ogni stadio e' composto da:
//   - un banco di WIDTH d_latch
//   - un latch di controllo che genera il segnale "done" a partire da "req"
//   - un controllore fatto da UNA sola porta XNOR
//
// Semantica MOUSETRAP:
//   - finche' done e ack sono uguali (stesso "colore" del dato) il latch
//     resta trasparente (en=1): lo stadio e' considerato "vuoto";
//   - quando arriva un nuovo dato (done cambia) prima che l'ack corrispondente
//     sia arrivato, en si abbassa e il latch si chiude (protegge il dato);
//   - quando arriva l'ack dallo stadio successivo, en torna alto e il latch
//     si riapre per il prossimo dato.
//
// NOTA SU X-STATE: essendo latch NAND incrociati, in simulazione lo stato
// iniziale e' indefinito (X) finche' req/ack non vengono guidati a un valore
// noto (0) dal testbench.

module mousetrap_stage #(
    parameter WIDTH    = 1,
    parameter tPD_NOT  = 1,
    parameter tPD_NAND = 1,
    parameter tPD_XNOR = 1
)(
    input  wire [WIDTH-1:0] D,     	// dati in ingresso 
    input  wire              req,   // request in ingresso
    input  wire              ack,   // ack dallo stadio successivo 
    output wire [WIDTH-1:0] Q,     	// dati latchati
    output wire              done,  // verso: ack dello stadio precedente E req dello stadio successivo
    output wire              en     // enable dei latch
);

    xnor #(tPD_XNOR) u_ctrl (en, done, ack);

    D_latch_structural #(.tPD_NOT(tPD_NOT), .tPD_NAND(tPD_NAND)) u_ctrl_latch (
        .D(req), .EN(en), .Q(done), .Qbar()
    );

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_data_latch
            D_latch_structural #(.tPD_NOT(tPD_NOT), .tPD_NAND(tPD_NAND)) u_data_latch (
                .D(D[i]), .EN(en), .Q(Q[i]), .Qbar()
            );
        end
    endgenerate

endmodule
