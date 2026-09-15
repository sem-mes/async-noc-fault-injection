`timescale 1ns/1ps

// "Matched delay" per il canale req/done di una pipeline bundled-data.

module delay_element #(
    parameter DELAY = 1
) (
    input  wire in,
    output wire out
);

    buf #(DELAY) u_delay (out, in);

endmodule
