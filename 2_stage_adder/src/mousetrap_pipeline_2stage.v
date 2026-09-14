// mousetrap_pipeline_2stage.v
//
// Pipeline asincrona MOUSETRAP a 2 stadi:
//   STADIO 1: latcha {A0,B0,A1,B1} (8 bit), poi logica = 2 adder_2bit paralleli
//             che producono R0 = A0+B0 e R1 = A1+B1 (3 bit ciascuno, con carry)
//   STADIO 2: latcha {R0,R1} (6 bit), poi logica = 1 adder_3bit che calcola
//             Result = R0 + R1 (4 bit, con carry finale)
//
// Interfaccia a "request/acknowledge" (transition signaling) verso
// l'ambiente sinistro (che fornisce i dati e req_in) e l'ambiente destro
// (che consuma Result e genera ack_out).
//
// =====================================================================
// DIMENSIONAMENTO (STA) DEI MATCHED DELAY
// =====================================================================
// Ogni "request" che entra in uno stadio deve arrivare DOPO che i dati in
// ingresso a quello stadio si sono stabilizzati (assunzione bundled-data).
// I dati in ingresso allo stadio N+1 sono l'uscita della logica combinatoria
// posta tra lo stadio N e lo stadio N+1; percio' il ritardo inserito tra
// done_N e req_(N+1) deve essere >= al ritardo peggiore di quella logica.
//
// Con la struttura del full_adder usata in questo progetto (percorso
// critico verso il riporto finale, ingressi tutti sincroni perche' escono
// dallo stesso rango di latch):
//
//   T_2bit = tPD_XOR + 2*(tPD_AND + tPD_OR)   <- logica tra stadio1 e stadio2
//   T_3bit = tPD_XOR + 3*(tPD_AND + tPD_OR)   <- logica dopo lo stadio2
//
// Si sceglie quindi:
//   DELAY_1 = T_2bit + MARGIN
//   DELAY_2 = T_3bit + MARGIN
//
// (MARGIN e' un margine di sicurezza positivo per evitare condizioni limite
// tra "dato appena stabile" e "request appena arrivata"; con ritardi
// arbitrari va sempre verificato che sia > 0 anche a margine nullo).
//
// I vincoli "one-sided" del controllore (setup: t(req->done) > t_su del
// latch; hold: t_Lt+t_logic dello stadio a monte > differenza tra i ritardi
// delle due XNOR + t_hold) sono soddisfatti per costruzione in questo
// progetto: done_N e' generato dallo STESSO latch/enable dei dati, quindi
// req->done impiega esattamente t_Lt = 2*tPD_NAND, che eccede ampiamente il
// tempo di setup intrinseco dei nostri latch NAND; e la logica tra stadi
// (T_2bit, T_3bit) eccede ampiamente le piccole differenze tra i ritardi
// delle porte XNOR dei due controllori.
// =====================================================================

module mousetrap_pipeline_2stage #(
    // ritardi di libreria, in unita' di tempo arbitrarie (personalizzabili)
    parameter tPD_NOT  = 1,
    parameter tPD_NAND = 1,
    parameter tPD_XNOR = 1,
    parameter tPD_XOR  = 1,
    parameter tPD_AND  = 1,
    parameter tPD_OR   = 1,
    parameter MARGIN   = 1
)(
    input  wire [1:0] A0, B0, A1, B1, // ingressi dall'ambiente sinistro
    input  wire        req_in,         // request dall'ambiente sinistro
    output wire        ack_in,         // ack verso l'ambiente sinistro

    output wire [3:0] Result,          // risultato finale (3 bit somma + riporto)
    output wire        req_out,        // request verso l'ambiente destro
    input  wire        ack_out         // ack dall'ambiente destro
);

    // ---- STA: calcolo dei ritardi minimi richiesti ----
    localparam T_2BIT  = tPD_XOR + 2*(tPD_AND + tPD_OR);
    localparam T_3BIT  = tPD_XOR + 3*(tPD_AND + tPD_OR);
    localparam DELAY_1 = T_2BIT + MARGIN;
    localparam DELAY_2 = T_3BIT + MARGIN;

    // =====================================================================
    // STADIO 1
    // =====================================================================
    wire [7:0] stage1_D = {A0, B0, A1, B1};
    wire [7:0] stage1_Q;
    wire done_1, req_2, ack_1, en_1;

    mousetrap_stage #(
        .WIDTH(8), .tPD_NOT(tPD_NOT), .tPD_NAND(tPD_NAND), .tPD_XNOR(tPD_XNOR)
    ) u_stage1 (
        .D(stage1_D), .req(req_in), .ack(ack_1),
        .Q(stage1_Q), .done(done_1), .en(en_1)
    );

    assign ack_in = done_1; // il done dello stadio 1 e' l'ack per l'ambiente sinistro

    wire [1:0] a0 = stage1_Q[7:6];
    wire [1:0] b0 = stage1_Q[5:4];
    wire [1:0] a1 = stage1_Q[3:2];
    wire [1:0] b1 = stage1_Q[1:0];

    // Logica dello stadio 1: due adder a 2 bit in parallelo
    wire [1:0] S0, S1;
    wire        Cout0, Cout1;

    adder_2bit #(.tPD_XOR(tPD_XOR), .tPD_AND(tPD_AND), .tPD_OR(tPD_OR)) u_add0 (
        .A(a0), .B(b0), .Cin(1'b0), .S(S0), .Cout(Cout0)
    );
    adder_2bit #(.tPD_XOR(tPD_XOR), .tPD_AND(tPD_AND), .tPD_OR(tPD_OR)) u_add1 (
        .A(a1), .B(b1), .Cin(1'b0), .S(S1), .Cout(Cout1)
    );

    wire [2:0] R0 = {Cout0, S0};
    wire [2:0] R1 = {Cout1, S1};

    // Matched delay stadio1 -> stadio2, dimensionato su T_2BIT
    delay_element #(.DELAY(DELAY_1)) u_delay1 (.in(done_1), .out(req_2));

    // =====================================================================
    // STADIO 2
    // =====================================================================
    wire [5:0] stage2_D = {R0, R1};
    wire [5:0] stage2_Q;
    wire done_2, en_2;

    mousetrap_stage #(
        .WIDTH(6), .tPD_NOT(tPD_NOT), .tPD_NAND(tPD_NAND), .tPD_XNOR(tPD_XNOR)
    ) u_stage2 (
        .D(stage2_D), .req(req_2), .ack(ack_out),
        .Q(stage2_Q), .done(done_2), .en(en_2)
    );

    assign ack_1 = done_2; // il done dello stadio 2 e' l'ack per lo stadio 1

    wire [2:0] r0 = stage2_Q[5:3];
    wire [2:0] r1 = stage2_Q[2:0];

    // Logica dello stadio 2: un adder a 3 bit che somma i due risultati
    wire [2:0] Sum3;
    wire        CoutFinal;

    adder_3bit #(.tPD_XOR(tPD_XOR), .tPD_AND(tPD_AND), .tPD_OR(tPD_OR)) u_add_final (
        .A(r0), .B(r1), .Cin(1'b0), .S(Sum3), .Cout(CoutFinal)
    );

    assign Result = {CoutFinal, Sum3};

    // Matched delay stadio2 -> ambiente destro, dimensionato su T_3BIT
    delay_element #(.DELAY(DELAY_2)) u_delay2 (.in(done_2), .out(req_out));

endmodule
