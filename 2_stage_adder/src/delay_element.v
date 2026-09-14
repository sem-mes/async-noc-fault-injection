`timescale 1ns/1ps
// delay_element.v
// "Matched delay" per il canale req/done di una pipeline bundled-data.
// In silicio si realizza tipicamente con una catena di invertitori/buffer
// dimensionata per uguagliare il ritardo peggiore della logica combinatoria
// dello stadio; qui il ritardo complessivo e' modellato direttamente su un
// singolo buf, cosi' il valore DELAY puo' essere calcolato via STA e passato
// come parametro.

module delay_element #(
    parameter DELAY = 1
) (
    input  wire in,
    output wire out
);

    buf #(DELAY) u_delay (out, in);

endmodule
