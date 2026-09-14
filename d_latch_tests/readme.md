**Fase di Hold (EN = 0) - Comportamento Identico**

- Memorizzazione Permanente: Al momento del release, entrambi i modelli intrappolano il guasto, mantenendo l'uscita stabilmente sul valore forzato.
- Dinamica Strutturale: L'anello di retroazione delle porte logiche NAND incrociate reagisce al cambio di tensione forzato, ribalta il proprio stato interno e stabilizza fisicamente l'errore come se fosse stato campionato.
- Dinamica Comportamentale: La variabile di programmazione reg conserva passivamente l'ultimo valore forzato. Poiché la condizione di abilitazione è falsa, il blocco non tenta di aggiornare l'uscita.

**Fase di Trasparenza (EN = 1) - Comportamento Diverso**

- Modello Strutturale: Rimosso il force, il Latch guarisce istantaneamente. Le porte logiche valutano continuamente i livelli elettrici in tempo reale; non appena il filo viene liberato, il valore corretto presente sull'ingresso D si propaga nuovamente all'uscita, schiacciando l'errore.
- Modello Comportamentale (Guasto Fantasma): Il Latch rimane incorrettamente incantato sul valore errato. Il costrutto always @(*) è event-driven: si riattiva solo in presenza di variazioni effettive (transizioni) sui fili di ingresso. Il comando release nel testbench non costituisce un evento. Senza una nuova variazione di D o EN, il blocco non viene rieseguito e l'uscita non si aggiorna, sovrastimando di fatto la letalità del guasto.


<img width="987" height="262" alt="image" src="https://github.com/user-attachments/assets/0c6cc418-cd79-4cd3-927d-f05dedc349ab" />
