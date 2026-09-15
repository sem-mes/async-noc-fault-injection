`timescale 1ns/1ps
// Funzionamento:
//   EN = 1 -> Q segue D 
//   EN = 0 -> Q mantiene il valore precedente

module D_latch_structural #(
    parameter tPD_NOT  = 1, // ritardo dell'inverter 
    parameter tPD_NAND = 1  // ritardo di ciascuna NAND 
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

// STA: t_Lt = 2 * tPD_NAND
