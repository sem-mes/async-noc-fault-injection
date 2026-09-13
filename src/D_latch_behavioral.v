// D-latch trasparente - implementazione BEHAVIORAL
//
// Funzionamento:
//   EN = 1 -> Q segue D
//   EN = 0 -> Q mantiene il valore precedente

module D_latch_behavioral (
    input  wire D,
    input  wire EN,
    output reg  Q
);

    always @(*) begin
        if (EN)
            Q = D;
    end

endmodule
