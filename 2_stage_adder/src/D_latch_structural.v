`timescale 1ns/1ps
// D_latch_structural.v
// D-latch trasparente - implementazione STRUTTURALE con porte NAND + inverter
//
// Funzionamento:
//   EN = 1 -> Q segue D (latch trasparente)
//   EN = 0 -> Q mantiene il valore precedente (memoria)
//
// Struttura classica: 2 NAND generano S' e R' a partire da D e EN,
// che pilotano un latch SR realizzato con 2 NAND incrociate.

module D_latch_structural #(
    parameter tPD_NOT  = 1, // ritardo dell'inverter (unita' di tempo arbitrarie)
    parameter tPD_NAND = 1  // ritardo di ciascuna NAND (unita' di tempo arbitrarie)
) (
    input  wire D,
    input  wire EN,
    output wire Q,
    output wire Qbar
);

    wire Dn; // D negato
    wire S;  // set (attivo basso)
    wire R;  // reset (attivo basso)

    not  #(tPD_NOT)  n1 (Dn, D);
    nand #(tPD_NAND) n2 (S, D,  EN);
    nand #(tPD_NAND) n3 (R, Dn, EN);

    // Latch SR (NAND incrociate)
    nand #(tPD_NAND) n4 (Q,    S, Qbar);
    nand #(tPD_NAND) n5 (Qbar, R, Q);

endmodule

// Nota per la STA: il percorso combinatorio D -> Q (a latch gia' trasparente,
// cioe' con Qbar assestato) attraversa 2 NAND (n2, n4):
//   t_Lt = 2 * tPD_NAND
