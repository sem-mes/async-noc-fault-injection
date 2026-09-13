// D-latch trasparente - implementazione STRUTTURALE con porte NAND + inverter
//
// Funzionamento:
//   EN = 1 -> Q segue D
//   EN = 0 -> Q mantiene il valore precedente

module D_latch_structural (
    input  wire D,
    input  wire EN,
    output wire Q,
    output wire Qbar
);

    wire Dn; // D negato
    wire S;  // set (attivo basso)
    wire R;  // reset (attivo basso)

    not  n1 (Dn, D);
    nand n2 (S, D,  EN);
    nand n3 (R, Dn, EN);

    // Latch SR
    nand n4 (Q,    S, Qbar);
    nand n5 (Qbar, R, Q);

endmodule
