`timescale 1ns/1ps
// mousetrap_stage.v
// Stadio generico di una pipeline asincrona MOUSETRAP (Singh & Nowick, 2001).
//
// Ogni stadio e' composto da:
//   - un banco di WIDTH latch dati (normalmente trasparenti)
//   - un latch di controllo che genera il segnale "done" a partire da "req"
//     (usa lo stesso enable dei latch dati)
//   - un controllore fatto da UNA sola porta XNOR:
//         en = XNOR(done, ack)
//     "ack" e' il done dello stadio successivo (o dell'ambiente destro).
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
// noto (0) dal testbench. E' lo stesso genere di inizializzazione che si
// discute con force/release sul D_latch strutturale.

module mousetrap_stage #(
    parameter WIDTH    = 1,
    parameter tPD_NOT  = 1,
    parameter tPD_NAND = 1,
    parameter tPD_XNOR = 1
)(
    input  wire [WIDTH-1:0] D,     // dati in ingresso (dalla logica dello stadio precedente)
    input  wire              req,   // request in ingresso
    input  wire              ack,   // ack dallo stadio successivo (= suo done)
    output wire [WIDTH-1:0] Q,     // dati latchati
    output wire              done,  // verso: ack dello stadio precedente E req (ritardato) dello stadio successivo
    output wire              en     // enable dei latch (utile per debug/STA in simulazione)
);

    // Controllore MOUSETRAP: singola porta XNOR
    xnor #(tPD_XNOR) u_ctrl (en, done, ack);

    // Latch di controllo: "done" e' la versione latchata di "req"
    D_latch_structural #(.tPD_NOT(tPD_NOT), .tPD_NAND(tPD_NAND)) u_ctrl_latch (
        .D(req), .EN(en), .Q(done), .Qbar()
    );

    // Banco di latch dati, un'istanza per bit, stesso enable dei latch di controllo
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_data_latch
            D_latch_structural #(.tPD_NOT(tPD_NOT), .tPD_NAND(tPD_NAND)) u_data_latch (
                .D(D[i]), .EN(en), .Q(Q[i]), .Qbar()
            );
        end
    endgenerate

endmodule
