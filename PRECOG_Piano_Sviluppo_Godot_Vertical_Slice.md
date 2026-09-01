# PRECOG — Piano di sviluppo Godot
## Roadmap esecutiva del Vertical Slice / Livello 1

**Versione documento:** 1.0  
**Motore target:** Godot 4.7.2 stable  
**Obiettivo:** portare PRECOG da progetto vuoto a un Vertical Slice del Livello 1 completo, testabile e coerente con il Game Design.  
**Destinatario principale:** un'AI incaricata di implementare il progetto fase per fase.  
**Questo documento NON contiene codice.**

---

# 0. Come deve essere usato questo documento

Questo non è un elenco di feature da sviluppare in parallelo.

È una **sequenza obbligatoria di milestone**.

L'AI incaricata dello sviluppo deve lavorare su **una sola fase alla volta**.

Per ogni fase deve:

1. leggere integralmente gli obiettivi;
2. verificare le dipendenze dalle fasi precedenti;
3. implementare esclusivamente ciò che è richiesto;
4. non anticipare sistemi delle fasi successive salvo dipendenze strettamente necessarie;
5. eseguire tutti i test indicati;
6. correggere qualsiasi test fallito;
7. eseguire nuovamente anche i test di regressione delle fasi precedenti;
8. dichiarare la fase completata solo quando tutti i criteri di uscita sono soddisfatti;
9. creare un punto stabile del progetto prima di procedere.

## Regola assoluta

> **NON SI PROCEDE ALLA FASE SUCCESSIVA SE IL GATE DELLA FASE CORRENTE NON È SUPERATO.**

Aggiungere nuove feature non è una soluzione a un problema della fase corrente.

Se una scena non è leggibile, non si aggiunge l'interfaccia.

Se l'agente sembra stupido, non si aggiunge il Precog.

Se la simulazione non è ripetibile, non si aggiunge il replay.

Se il sistema di conoscenza perde informazioni, non si aggiunge la radio.

---

# 1. Principi invarianti di sviluppo

Queste regole devono essere rispettate dall'inizio alla fine.

## 1.1 Il giocatore non controlla direttamente le persone

Mai introdurre:
- click-to-move;
- waypoint dati dal giocatore;
- controllo WASD degli agenti;
- selezione del bersaglio;
- ordine diretto di sparare;
- ordine diretto di usare un'abilità;
- ordine diretto di aprire una porta;
- microgestione durante la proiezione.

Il giocatore agisce su:
- informazione;
- priorità;
- atteggiamento;
- conoscenza del futuro.

---

## 1.2 Il mondo possiede la verità, i personaggi no

Ogni personaggio deve reagire esclusivamente a ciò che può conoscere.

Un agente non può reagire alla posizione di un criminale semplicemente perché quella posizione esiste nel mondo.

Un criminale non può reagire a un agente che non ha:
- visto;
- sentito;
- ricevuto via comunicazione;
- dedotto da un'informazione disponibile.

Qualsiasi comportamento che sembri onnisciente è un bug di gameplay.

---

## 1.3 La simulazione deve essere leggibile prima di essere complessa

Preferire:
- poche cause chiare;
- comportamenti evidenti;
- eventi distinguibili;
- sequenze comprensibili.

Evitare:
- decine di variabili simultanee;
- casualità incontrollabile;
- comportamenti emergenti impossibili da spiegare;
- caos fisico gratuito.

---

## 1.4 La stessa situazione deve produrre quasi lo stesso futuro

Il Precog è utile solo se il futuro è abbastanza stabile da essere studiato.

Senza interventi del giocatore:
- i percorsi principali devono restare coerenti;
- gli eventi principali devono avvenire nello stesso ordine;
- le tempistiche devono essere abbastanza vicine;
- il risultato generale deve essere ripetibile.

Piccole differenze visive sono accettabili.

Differenze causali importanti senza motivo non lo sono.

---

## 1.5 Tutto deve essere osservabile e diagnosticabile

Durante lo sviluppo deve esistere una modalità di debug che permetta di capire:
- cosa vede ogni personaggio;
- cosa sente;
- cosa conosce;
- qual è il suo obiettivo;
- qual è il suo stato;
- quale decisione sta perseguendo;
- quale informazione ha causato un cambio di comportamento.

La modalità debug può essere brutta.

Il gioco no.

---

# 2. Definizione del risultato finale

Al termine del piano deve esistere un Vertical Slice con:

- una piccola mappa 3D stilizzata;
- 2 agenti;
- 2 criminali;
- 1 civile;
- personaggi autonomi;
- movimento autonomo;
- visione individuale;
- percezione sonora;
- memoria delle informazioni;
- comunicazione radio;
- porte e punti ciechi;
- combattimento leggibile;
- almeno una abilità operativa usata autonomamente;
- presente congelato;
- proiezione del futuro;
- ritorno al presente;
- ripetibilità della simulazione;
- sistema Precog;
- budget Precog;
- informazioni Precog applicabili agli agenti;
- direttive generiche;
- timeline della proiezione;
- modalità di analisi;
- esecuzione finale reale;
- condizioni di successo e fallimento;
- debrief;
- grafica e audio sufficienti a presentare il concept a terzi.

---

# 3. Struttura generale delle fasi

Il progetto è diviso in 22 fasi.

## BLOCCO A — Fondamenta
1. Progetto e disciplina di sviluppo
2. Diorama 3D e leggibilità
3. Movimento autonomo di base
4. Interazione con porte e ambiente

## BLOCCO B — Individui autonomi
5. Stato interno e obiettivi
6. Percezione visiva
7. Conoscenza e memoria
8. Percezione sonora
9. Reazione e rivalutazione

## BLOCCO C — Primo scenario vivo
10. Combattimento minimo
11. Coordinamento tra agenti
12. Radio e propagazione informativa
13. Civile e conseguenze indirette
14. Prototype 0.1 “The Door”

## BLOCCO D — Precognizione
15. Stabilità e ripetibilità
16. Presente, snapshot e reset
17. Proiezione del futuro
18. Interventi Precog
19. Budget Precog e trade-off

## BLOCCO E — Strumenti di comprensione
20. Timeline, analisi e confronto
21. Esecuzione finale e missione completa
22. Polish, playtest e Vertical Slice finale

---

# FASE 1 — Progetto e disciplina di sviluppo

## Obiettivo

Creare una base Godot stabile, semplice da estendere e soprattutto difficile da rompere durante lo sviluppo iterativo.

Questa fase NON deve produrre gameplay.

Deve produrre un progetto ordinato.

## Implementare

### Struttura del progetto

Organizzare chiaramente aree dedicate a:
- livelli;
- personaggi;
- componenti comuni;
- dati di gioco;
- interfaccia;
- audio;
- materiali;
- modelli;
- animazioni;
- debug;
- test;
- risorse temporanee.

### Convenzioni

Definire:
- convenzione nomi scene;
- convenzione nomi personaggi;
- convenzione nodi principali;
- distinzione tra elementi riutilizzabili e specifici del Livello 1;
- regole per asset temporanei;
- regole per sostituzione degli asset.

### Stati del progetto

Predisporre il concetto di:
- build di sviluppo;
- debug acceso/spento;
- scena test isolata;
- scena Livello 1;
- punto di ingresso del gioco.

### Controllo versione

Il progetto deve essere protetto da versionamento fin dall'inizio.

Ogni fase completata deve avere un punto stabile chiaramente identificabile.

## Non implementare

- agenti;
- criminali;
- AI;
- combattimento;
- Precog;
- UI di gioco;
- effetti;
- sistemi avanzati.

## Test

### Test 1 — Avvio pulito
Aprire il progetto e avviare il gioco.

**Passa se:** non appaiono errori e la scena iniziale si carica correttamente.

### Test 2 — Cambio scena
Aprire la scena test e la scena di livello.

**Passa se:** entrambe funzionano indipendentemente.

### Test 3 — Debug
Attivare e disattivare la modalità debug.

**Passa se:** lo stato è chiaramente distinguibile e non influenza il gameplay.

### Test 4 — Progetto da zero
Chiudere completamente Godot e riaprire il progetto.

**Passa se:** nessuna dipendenza manuale è richiesta.

## Gate

Procedere solo se:
- il progetto si apre senza errori;
- la struttura è comprensibile;
- esiste una scena test;
- esiste una scena del livello;
- il versionamento è operativo.

---

# FASE 2 — Diorama 3D e leggibilità

## Obiettivo

Creare un piccolo spazio 3D che sia già piacevole da guardare e soprattutto immediatamente leggibile.

Non deve sembrare un test tecnico infinito.

## Implementare

Costruire una mappa provvisoria composta da:
- ingresso;
- corridoio;
- stanza A;
- area centrale;
- stanza B;
- uscita secondaria;
- almeno due porte;
- almeno un punto cieco;
- almeno due possibili percorsi;
- coperture semplici.

### Camera

Implementare una camera da osservazione che permetta:
- rotazione;
- spostamento;
- zoom;
- visione completa del diorama;
- ritorno a una posizione standard.

### Identità visiva minima

Usare materiali e illuminazione semplici ma coerenti.

Distinguere chiaramente:
- pareti;
- pavimento;
- porte;
- aree accessibili;
- ostacoli.

## Non implementare

- gameplay;
- nemici;
- combattimento;
- Precog;
- animazioni complesse.

## Test

### Test 1 — Comprensione della mappa
Mostrare la scena per 10 secondi a un tester.

Chiedere:
- dov'è l'ingresso?
- quali stanze sono accessibili?
- dove sono le porte?
- quali sono i punti ciechi?

**Passa se:** le risposte sono corrette senza spiegazioni.

### Test 2 — Camera
Esplorare tutta la mappa.

**Passa se:** nessuna zona importante è impossibile da osservare.

### Test 3 — Occlusione
Osservare una persona fittizia dietro una parete o una porta.

**Passa se:** la geometria comunica chiaramente che la persona sarebbe nascosta.

### Test 4 — Scala
Inserire un manichino standard.

**Passa se:** porte, corridoi e stanze appaiono proporzionati al personaggio.

## Gate

Procedere solo se:
- la mappa è leggibile;
- la camera non è frustrante;
- il diorama è presentabile;
- le porte e i punti ciechi sono evidenti.

---

# FASE 3 — Movimento autonomo di base

## Obiettivo

Far muovere un personaggio da solo all'interno della mappa senza alcun controllo diretto del giocatore.

Questa è la prima dimostrazione della filosofia del progetto.

## Implementare

Creare un personaggio agente provvisorio capace di:
- avere una destinazione interna determinata dal proprio obiettivo;
- raggiungerla;
- evitare ostacoli statici;
- percorrere corridoi;
- attraversare aperture;
- fermarsi in prossimità dell'obiettivo;
- aggiornare il percorso se bloccato.

### Movimento visivo

Il personaggio deve:
- orientarsi nella direzione del moto;
- fermarsi in modo leggibile;
- non scivolare;
- non compenetrare muri;
- non oscillare continuamente vicino alla destinazione.

### Nessun input

Il giocatore può solo osservare.

## Non implementare

- vista;
- suono;
- nemici;
- combattimento;
- decisioni tattiche.

## Test

### Test 1 — Percorso semplice
Posizionare l'agente all'ingresso e assegnare una destinazione nella stanza A.

**Passa se:** la raggiunge senza intervento.

### Test 2 — Percorso alternativo
Bloccare un passaggio lasciandone un altro disponibile.

**Passa se:** trova un percorso valido.

### Test 3 — Nessun percorso
Rendere la destinazione irraggiungibile.

**Passa se:** non entra in loop e segnala chiaramente l'impossibilità.

### Test 4 — Ripetizione
Ripetere lo stesso movimento 10 volte.

**Passa se:** il comportamento resta stabile.

### Test 5 — Camera
Osservare il personaggio da più angolazioni.

**Passa se:** il movimento appare naturale e comprensibile.

## Gate

Procedere solo se l'agente può attraversare affidabilmente l'intera mappa senza controllo del giocatore.

---

# FASE 4 — Porte e interazioni ambientali

## Obiettivo

Rendere le porte vere parti della simulazione.

La porta è centrale in PRECOG perché separa conoscenza e verità.

## Implementare

Le porte devono possedere almeno:
- stato aperto;
- stato chiuso;
- passabilità coerente;
- blocco della vista quando chiuse;
- apertura autonoma da parte dei personaggi;
- tempo necessario per aprirsi;
- animazione leggibile.

Il personaggio deve:
- riconoscere che una porta blocca il proprio percorso;
- raggiungerla;
- interagire;
- attraversarla;
- continuare il proprio obiettivo.

## Non implementare

- breaching;
- chiavi;
- porte bloccate;
- distruzione;
- Precog sulle porte.

## Test

### Test 1 — Porta aperta
L'agente attraversa senza fermate inutili.

### Test 2 — Porta chiusa
L'agente apre, aspetta correttamente e attraversa.

### Test 3 — Visibilità
Un manichino posto dietro la porta chiusa non deve essere visivamente esposto al personaggio.

### Test 4 — Porta durante il passaggio
La porta non deve chiudersi attraversando il personaggio.

### Test 5 — Due personaggi
Due personaggi devono poter attraversare senza bloccarsi permanentemente.

## Gate

Le porte devono essere affidabili abbastanza da poter costruire intorno a esse il primo incontro ostile.

---

# FASE 5 — Stato interno e obiettivi dei personaggi

## Obiettivo

Trasformare il manichino mobile in un individuo con uno scopo.

Non serve ancora “intelligenza tattica”.

Serve poter rispondere chiaramente:

> “Cosa sta cercando di fare questo personaggio?”

## Implementare

Ogni personaggio deve avere concettualmente:
- identità;
- fazione;
- stato fisico;
- obiettivo principale;
- eventuale priorità;
- stato operativo;
- azione corrente.

### Stati minimi

Per l'agente:
- inattivo;
- in movimento;
- in attesa;
- interazione;
- allerta;
- combattimento;
- incapacitato.

Per il criminale:
- inattivo;
- spostamento;
- sospettoso;
- allertato;
- combattimento;
- fuga;
- incapacitato.

### Debug leggibile

Selezionando il personaggio in debug deve essere possibile vedere:
- nome;
- fazione;
- obiettivo;
- stato;
- azione corrente.

## Non implementare

- personalità;
- morale;
- statistiche RPG;
- complessi sistemi di priorità.

## Test

### Test 1 — Obiettivo esplicabile
Osservare l'agente durante il movimento.

**Passa se:** il pannello debug descrive correttamente ciò che sta facendo.

### Test 2 — Cambio stato
Far raggiungere una destinazione.

**Passa se:** movimento → arrivo → attesa sono coerenti.

### Test 3 — Incapacitazione
Forzare lo stato incapacitato.

**Passa se:** interrompe qualsiasi comportamento incompatibile.

### Test 4 — Nessun comportamento fantasma
Cambiare obiettivo.

**Passa se:** le vecchie intenzioni non continuano ad agire.

## Gate

Ogni personaggio deve avere uno stato chiaro, osservabile e coerente.

---

# FASE 6 — Percezione visiva individuale

## Obiettivo

Far sì che un personaggio reagisca soltanto a ciò che realmente può vedere.

Questa è una delle milestone fondamentali dell'intero progetto.

## Implementare

La percezione visiva deve considerare:
- orientamento;
- distanza;
- campo visivo;
- muri;
- porte;
- ostacoli significativi.

Il sistema deve distinguere:
- visibile;
- non visibile;
- appena perso di vista.

### Debug

In modalità debug deve essere possibile visualizzare:
- area di visione;
- bersaglio osservato;
- ostacolo che interrompe la vista.

## Non implementare

- memoria avanzata;
- radio;
- udito;
- previsione;
- tracking onnisciente.

## Test

### Test 1 — Fronte
Un criminale davanti all'agente deve essere rilevato.

### Test 2 — Dietro
Lo stesso criminale dietro l'agente non deve essere rilevato.

### Test 3 — Muro
Un criminale dietro una parete non deve essere rilevato.

### Test 4 — Porta chiusa
Non deve essere rilevato.

### Test 5 — Porta aperta
Deve poter essere rilevato se la linea visiva è libera.

### Test 6 — Angolo
Il personaggio non deve reagire prima che il bersaglio emerga realmente dall'angolo.

### Test 7 — Due osservatori
Agente A vede il criminale, agente B no.

**Passa se:** solo A risulta consapevole.

## Gate

Procedere solo se non esistono evidenti “wallhack” cognitivi.

---

# FASE 7 — Conoscenza e memoria individuale

## Obiettivo

Separare definitivamente la verità del mondo dalla conoscenza dei personaggi.

Un personaggio deve poter ricordare qualcosa che non vede più senza possedere una conoscenza perfetta e aggiornata.

## Implementare

Ogni personaggio deve poter possedere informazioni del tipo:
- individuo visto;
- ultima posizione vista;
- momento dell'ultimo avvistamento;
- fonte dell'informazione;
- grado qualitativo di attualità.

Distinguere chiaramente:
- “lo vedo adesso”;
- “l'ho visto lì”;
- “non so più dove sia”.

### Informazione obsoleta

Con il passare del tempo, un'informazione deve essere trattata come meno attuale.

Non deve sparire necessariamente subito.

## Non implementare

- probabilità numeriche;
- inferenza sofisticata;
- memoria psicologica;
- radio.

## Test

### Test 1 — Perdita visiva
Agente vede criminale, criminale passa dietro un muro.

**Passa se:** l'agente ricorda l'ultima posizione ma non conosce la nuova.

### Test 2 — Spostamento nascosto
Il criminale cambia stanza senza essere visto.

**Passa se:** l'agente NON aggiorna magicamente la posizione.

### Test 3 — Due agenti
A vede il criminale, B no.

**Passa se:** B continua a non conoscerlo.

### Test 4 — Debug
Confrontare il mondo reale e la conoscenza dell'agente.

**Passa se:** la differenza è evidente.

## Gate

Il progetto deve poter dimostrare visivamente il concetto:

> “Il criminale è qui, ma l'agente pensa ancora che sia lì.”

---

# FASE 8 — Percezione sonora

## Obiettivo

Aggiungere una seconda fonte di conoscenza che sia intenzionalmente meno precisa della vista.

## Implementare

Eventi sonori rilevanti:
- sparo;
- porta;
- corsa molto vicina;
- urlo;
- evento importante definito dal livello.

Un personaggio che sente deve ricevere:
- tipo approssimativo del suono;
- direzione approssimativa;
- momento;
- livello qualitativo di importanza.

Non deve ricevere la posizione perfetta della sorgente.

## Non implementare

- acustica simulata complessa;
- materiali sonori;
- riverberi tattici;
- propagazione fisica perfetta.

## Test

### Test 1 — Sparo vicino
Il personaggio deve sentirlo.

### Test 2 — Sparo lontano
Se fuori dalla portata prevista, non deve sentirlo.

### Test 3 — Posizione non perfetta
Dopo il suono il personaggio non deve conoscere magicamente il tiratore.

### Test 4 — Due persone
Una abbastanza vicina e una troppo lontana.

**Passa se:** solo la prima riceve l'informazione.

### Test 5 — Reazione
Un suono importante deve poter cambiare lo stato da ignaro a sospettoso.

## Gate

La differenza tra “ho visto” e “ho sentito” deve essere chiarissima nel debug e nel comportamento.

---

# FASE 9 — Reazione e rivalutazione

## Obiettivo

Far sì che il personaggio possa cambiare ciò che sta facendo quando acquisisce nuova informazione.

Questa è la nascita dell'autonomia percepita.

## Implementare

L'agente deve poter:
- perseguire l'obiettivo;
- acquisire una nuova informazione;
- interrompere o modificare l'azione corrente;
- scegliere un comportamento appropriato;
- tornare all'obiettivo quando la situazione lo consente.

Esempi minimi:
- vede un criminale → interrompe il semplice movimento;
- sente uno sparo → rallenta e orienta l'attenzione;
- perde di vista il criminale → reagisce all'ultima posizione nota invece di seguirlo magicamente.

## Non implementare

- comportamento tattico completo;
- personalità avanzata;
- Precog.

## Test

### Test 1 — Interruzione
Agente in movimento vede criminale.

**Passa se:** non continua serenamente verso la destinazione.

### Test 2 — Suono
Agente sente sparo.

**Passa se:** la nuova informazione modifica il comportamento.

### Test 3 — Falso onnisciente
Il criminale si sposta nascosto.

**Passa se:** l'agente agisce sull'informazione vecchia.

### Test 4 — Ripresa obiettivo
Risolta la minaccia, l'agente deve poter tornare alla missione.

## Gate

Osservando la scena, il tester deve iniziare a descrivere l'agente come qualcosa che “reagisce”, non come un oggetto che segue una traccia.

---

# FASE 10 — Combattimento minimo

## Obiettivo

Creare una sparatoria breve e leggibile, sufficiente a produrre conseguenze importanti.

Il combattimento NON deve diventare il sistema principale del progetto.

## Implementare

Minimo necessario:
- individuazione del bersaglio;
- orientamento;
- breve tempo di reazione;
- mira visiva;
- sparo;
- effetto del colpo;
- ferita/incapacitazione;
- morte se necessaria;
- interruzione delle azioni incompatibili.

### Regola

Il risultato deve essere sufficientemente stabile da poter essere studiato dal Precog in seguito.

## Non implementare

- armi numerose;
- munizioni complesse;
- inventario;
- balistica avanzata;
- danni localizzati complessi;
- statistiche RPG.

## Test

### Test 1 — Primo contatto
Due personaggi si vedono.

**Passa se:** la reazione è visivamente comprensibile.

### Test 2 — Muro
Nessuno spara attraverso una parete senza linea di tiro.

### Test 3 — Incapacitazione
Un personaggio incapacitato smette di combattere e muoversi.

### Test 4 — Ripetibilità
Ripetere 10 volte la stessa situazione.

**Passa se:** il risultato generale non oscilla caoticamente.

### Test 5 — Causa visibile
Chiedere al tester:
“Perché è morto?”

**Passa se:** può rispondere osservando la scena.

## Gate

Il combattimento deve essere abbastanza credibile da sostenere “The Door”, ma abbastanza semplice da non dominare lo sviluppo.

---

# FASE 11 — Coordinamento tra agenti

## Obiettivo

Far percepire i due agenti come individui distinti che possono cooperare senza essere controllati dal giocatore.

## Implementare

Aggiungere Agente B.

I due agenti devono:
- conoscere inizialmente la presenza del compagno;
- mantenere una coordinazione minima;
- evitare di sovrapporsi continuamente;
- poter aspettare brevemente;
- poter reagire alla situazione dell'altro quando la percepiscono;
- non condividere telepaticamente tutto ciò che uno vede.

### Differenziazione minima

Agente A:
- più prudente.

Agente B:
- più deciso.

La differenza deve essere comportamentale, non una tabella di statistiche.

## Test

### Test 1 — Movimento insieme
Entrambi entrano nell'edificio senza bloccarsi.

### Test 2 — Conoscenza separata
A vede un criminale, B no.

**Passa se:** B non reagisce fino a quando non acquisisce informazione.

### Test 3 — Reazione al compagno
B vede A cadere.

**Passa se:** reagisce.

### Test 4 — Personalità
Ripetere una situazione prudenziale equivalente.

**Passa se:** A e B non risultano cloni perfetti.

## Gate

I due agenti devono apparire come una squadra composta da due individui, non come una singola mente distribuita.

---

# FASE 12 — Radio e propagazione informativa

## Obiettivo

Dimostrare che l'informazione può cambiare il comportamento di un personaggio che non ha assistito direttamente all'evento.

## Implementare

Aggiungere Criminale B.

La radio deve permettere:
- a Criminale A di comunicare un avvistamento;
- a Criminale B di ricevere l'informazione;
- di memorizzarne fonte, posizione approssimativa e tempo;
- di cambiare stato e comportamento.

L'informazione radio NON deve diventare tracking continuo.

## Test

### Test 1 — Nessun contatto
B non vede gli agenti e non riceve radio.

**Passa se:** resta ignaro.

### Test 2 — Radio
A vede un agente e comunica.

**Passa se:** B diventa informato senza “vedere” magicamente.

### Test 3 — Informazione vecchia
L'agente lascia la posizione comunicata.

**Passa se:** B conosce l'ultima posizione, non quella nuova.

### Test 4 — Prevenzione della radio
Impedire ad A di vedere l'agente.

**Passa se:** B non viene allertato.

### Test 5 — Catena causale
Un tester deve poter spiegare:
“B è cambiato perché A lo ha avvisato.”

## Gate

Questa sequenza deve funzionare in modo affidabile:

> VISTA A → RADIO → CONOSCENZA B → COMPORTAMENTO B

---

# FASE 13 — Civile e conseguenze indirette

## Obiettivo

Introdurre un terzo tipo di individuo che renda la missione più ricca di “uccidere i nemici”.

## Implementare

Il civile deve:
- avere uno stato iniziale;
- percepire eventi rilevanti;
- reagire a pericolo evidente;
- poter spostarsi in modo semplice;
- poter diventare esposto;
- poter essere protetto;
- poter essere ferito/incapacitato.

Il civile deve produrre conseguenze leggibili, non caos casuale.

## Test

### Test 1 — Calma
Senza eventi, il civile si comporta in modo stabile.

### Test 2 — Sparo
Un combattimento vicino provoca una reazione coerente.

### Test 3 — Timing
Modificando il momento della sparatoria, il civile può trovarsi in una posizione differente.

### Test 4 — Causalità
Il tester deve poter dire:
“Il civile si è mosso perché ha sentito gli spari.”

### Test 5 — Nessun caos
Ripetere la stessa sequenza.

**Passa se:** il civile non produce esiti completamente casuali.

## Gate

Il civile deve creare almeno una conseguenza indiretta significativa legata al timing.

---

# FASE 14 — Prototype 0.1 “THE DOOR”

## Obiettivo

Dimostrare che la simulazione autonoma è già interessante PRIMA di implementare il Precog.

Questa è la prima grande milestone del progetto.

## Scenario

- corridoio;
- porta;
- Agente A;
- Agente B;
- Criminale A dietro la porta.

### Sequenza base desiderata

1. gli agenti entrano;
2. A procede;
3. A non conosce Criminale A;
4. raggiunge la porta;
5. apre;
6. avviene contatto;
7. Criminale A ha un vantaggio informativo/temporale;
8. A viene colpito o la situazione degenera;
9. B reagisce.

La scena deve apparire naturale.

## Non implementare ancora

- rewind;
- Precog;
- punti;
- timeline completa;
- UI finale.

## Test principali

### Test A — Guardabilità
Mostrare la scena senza spiegazioni.

Chiedere:
“Cosa è successo?”

**Passa se:** il tester comprende la sequenza.

### Test B — Conoscenza
Chiedere:
“Perché A non si è preparato?”

Risposta attesa:
“Non sapeva che il criminale fosse dietro la porta.”

### Test C — Autonomia
Chiedere:
“Ti sembra che gli agenti stiano agendo da soli?”

La risposta deve essere sì.

### Test D — Ripetibilità
Eseguire 10 volte.

La sequenza fondamentale deve restare sostanzialmente invariata.

### Test E — Assenza di stupidità
Nessuna azione deve apparire manifestamente assurda solo per forzare il fallimento.

## Gate CRITICO

NON procedere alla parte Precog se “The Door” non è già interessante e comprensibile da osservare.

Questa fase è un vero punto di decisione del progetto.

---

# FASE 15 — Stabilità e ripetibilità della simulazione

## Obiettivo

Preparare la simulazione a essere osservata più volte come “futuro”.

## Implementare

Definire e controllare tutte le fonti di variazione che possono cambiare:
- percorsi;
- timing;
- decisioni;
- risultato del combattimento;
- reazioni;
- ordine degli eventi.

Non serve assoluta identità frame-per-frame.

Serve stabilità causale.

## Test

### Test 1 — 20 run identiche
Avviare lo scenario senza modifiche 20 volte.

Registrare:
- momento apertura porta;
- primo contatto;
- primo sparo;
- esito agente;
- eventuale radio;
- stato finale.

**Passa se:** le variazioni sono piccole e non cambiano la lettura causale.

### Test 2 — Nessun effetto farfalla gratuito
Piccole variazioni visive non devono produrre esiti enormemente diversi senza una causa.

### Test 3 — Movimento
I percorsi principali devono rimanere coerenti.

### Test 4 — Combattimento
La stessa imboscata deve avere un risultato sufficientemente prevedibile.

## Gate

Il futuro deve essere abbastanza ripetibile da rendere significativo dire:

> “Ho cambiato X, quindi il futuro è cambiato.”

---

# FASE 16 — Presente, stato iniziale e reset

## Obiettivo

Creare il concetto di PRESENTE come punto immutabile da cui tutte le proiezioni partono.

## Implementare

Il gioco deve poter:
- iniziare in stato PRESENTE;
- congelare l'azione;
- memorizzare l'intero stato necessario della scena;
- avviare la simulazione;
- tornare esattamente al presente;
- ripristinare personaggi, conoscenze, porte, obiettivi, stati, posizioni e condizioni.

### Regola

Dopo il reset non devono restare “residui” della proiezione precedente.

## Test

### Test 1 — Posizioni
Far muovere tutti per 30 secondi e tornare.

**Passa se:** tutti sono esattamente nello stato iniziale previsto.

### Test 2 — Conoscenza
Far vedere un nemico a un agente e tornare.

**Passa se:** l'agente non conserva quell'informazione salvo se esplicitamente trasferita dal Precog in futuro.

### Test 3 — Porte
Aprire porte e tornare.

### Test 4 — Ferite
Ferire un personaggio e tornare.

### Test 5 — Radio
Far circolare informazioni e tornare.

### Test 6 — 20 cicli
Ripetere avvio/reset 20 volte.

**Passa se:** il progetto non deriva progressivamente dallo stato iniziale.

## Gate

Il PRESENTE deve essere un'ancora perfettamente affidabile.

---

# FASE 17 — Proiezione del futuro

## Obiettivo

Trasformare la simulazione in una vera modalità di gioco chiamata PROIEZIONE.

## Implementare

Il giocatore deve poter:
- essere nel PRESENTE;
- premere “Vedi il futuro”;
- osservare la simulazione per un orizzonte definito;
- interromperla;
- arrivare al termine;
- tornare al PRESENTE.

### Orizzonte iniziale

Usare circa 30–45 secondi.

### Stati chiaramente distinti

- PRESENTE;
- PROIEZIONE.

Il giocatore non deve poter impartire ordini durante la proiezione.

## Test

### Test 1 — Entrata
Il passaggio PRESENTE → PROIEZIONE è inequivocabile.

### Test 2 — Uscita
Il ritorno è inequivocabile.

### Test 3 — Nessun input tattico
Durante la proiezione non esiste controllo diretto delle unità.

### Test 4 — Orizzonte
La simulazione termina correttamente al tempo previsto.

### Test 5 — Interruzione
Il giocatore può tornare prima.

### Test 6 — Ripetizione
Due proiezioni consecutive senza modifiche risultano sostanzialmente uguali.

## Gate

Il tester deve capire spontaneamente:

> “Quello che sto vedendo non sta ancora succedendo davvero.”

---

# FASE 18 — Interventi Precog

## Obiettivo

Creare finalmente la meccanica centrale:

> osservare un fallimento → tornare → trasferire un'informazione → osservare un futuro diverso.

## Prima implementazione

Implementare SOLO:

### “OSTILE PREVISTO IN QUESTA STANZA”

Il giocatore:
1. torna al presente;
2. seleziona Agente A;
3. seleziona una stanza;
4. applica l'informazione;
5. avvia nuova proiezione.

L'agente deve ricevere quella conoscenza senza conoscere dettagli non comunicati.

## Risultato desiderato in “The Door”

Prima:
- A arriva ignaro;
- apre;
- viene sorpreso.

Dopo:
- A sa che esiste un possibile ostile;
- modifica autonomamente il proprio approccio;
- affronta la porta diversamente.

Il giocatore NON specifica come.

## Test

### Test 1 — Effetto visibile
Confrontare le due proiezioni.

**Passa se:** la differenza è immediatamente percepibile.

### Test 2 — Nessun controllo diretto
L'informazione non contiene istruzioni fisiche.

### Test 3 — Nessuna onniscienza aggiuntiva
L'agente non deve conoscere:
- coordinate precise;
- orientamento criminale;
- stato non comunicato.

### Test 4 — Conseguenza
Il risultato deve cambiare perché cambia il comportamento dell'agente.

### Test 5 — Rimozione
Rimuovere l'informazione e rieseguire.

**Passa se:** torna il comportamento originale.

## Gate CRITICO

Mostrare a un tester:

### Futuro A
Agente muore.

### Intervento
“Ostile nella stanza.”

### Futuro B
Agente si comporta diversamente.

Chiedere:
“È interessante?”

Se questa trasformazione non crea soddisfazione/curiosità, NON espandere il sistema Precog.

---

# FASE 19 — Budget Precog e trade-off

## Obiettivo

Evitare che il giocatore risolva tutto semplicemente informando tutti di tutto.

## Implementare

Introdurre una risorsa limitata.

Valore iniziale consigliato:
- 9 punti.

Aggiungere gradualmente interventi:

### Informazioni
- pericolo generico;
- presenza ostile;
- informazione più precisa.

### Direttive
- prudente;
- deciso;
- furtivo.

### Priorità
- proteggi civile;
- impedisci fuga.

Ogni intervento deve:
- avere costo chiaro;
- avere effetto qualitativo;
- comportare trade-off.

## Non implementare

- 20 abilità;
- percentuali complesse;
- skill tree;
- upgrade.

## Test

### Test 1 — Budget insufficiente
Il giocatore non deve poter applicare tutto contemporaneamente.

### Test 2 — Prudente
Deve produrre benefici e costi, ad esempio sicurezza vs tempo.

### Test 3 — Deciso
Deve produrre vantaggi e rischi.

### Test 4 — Furtivo
Deve ridurre esposizione/rumore ma rallentare o modificare il percorso.

### Test 5 — Priorità civile
Può far rinunciare a un inseguimento.

### Test 6 — Nessuna scelta dominante
Provare diverse combinazioni.

**Passa se:** non esiste una direttiva evidentemente superiore in ogni circostanza.

## Gate

Il giocatore deve trovarsi almeno una volta a pensare:

> “Non posso dirgli tutto. Cosa è veramente importante che sappia?”

---

# FASE 20 — Timeline, analisi e confronto

## Obiettivo

Rendere comprensibile la causalità senza trasformare il gioco in un debugger.

## Implementare

### Timeline

Durante una proiezione:
- play;
- pausa;
- velocità normale;
- rallentamento;
- ritorno a un momento già osservato;
- marcatori per eventi critici.

Eventi:
- primo contatto;
- radio;
- primo sparo;
- ferita;
- morte;
- civile in pericolo;
- fuga.

### Modalità analisi

Selezionando un personaggio mostrare:
- obiettivo;
- stato;
- ciò che vede;
- ultime informazioni rilevanti;
- informazioni Precog ricevute;
- decisione corrente;
- motivo sintetico.

### Confronto proiezioni

Mostrare in forma semplice:
- cosa è migliorato;
- cosa è peggiorato;
- quali nuovi eventi critici sono comparsi.

## Test

### Test 1 — “Perché?”
Fermare un agente prima di una decisione.

Chiedere:
“Perché sta facendo questo?”

L'interfaccia deve permettere una risposta.

### Test 2 — Radio
Il giocatore deve poter ricostruire la catena:
A vede → A comunica → B cambia.

### Test 3 — Confronto
Dopo un intervento Precog il giocatore deve poter identificare almeno un evento modificato.

### Test 4 — Nessun overload
Un tester nuovo non deve sentirsi obbligato a leggere continuamente pannelli.

### Test 5 — Timeline utile
Il tester deve riuscire a tornare velocemente al momento di un evento critico.

## Gate

La simulazione deve poter essere capita sia:
- semplicemente guardandola;
- approfondendola quando qualcosa non è chiaro.

---

# FASE 21 — Esecuzione finale e Livello 1 completo

## Obiettivo

Trasformare il prototipo in una missione con inizio, iterazione e conclusione.

## Implementare

### Scenario completo

- 2 agenti;
- 2 criminali;
- 1 civile;
- porta iniziale;
- radio;
- uscita secondaria;
- almeno due catene causali;
- almeno una conseguenza indiretta.

### Obiettivo

Salvare il civile e neutralizzare la minaccia.

### Proiezioni

Il giocatore può iterare.

### Esecuzione

Quando è soddisfatto:
- seleziona “Esegui”;
- la simulazione diventa reale;
- non può tornare al presente;
- osserva l'esito definitivo.

### Successo / fallimento

Definire:
- civile;
- agenti;
- criminali;
- fuga;
- esito missione.

### Debrief

Mostrare:
- risultato finale;
- stato personaggi;
- numero di proiezioni;
- punti Precog spesi;
- eventi principali.

## Test

### Test 1 — Prima partita
Un tester nuovo deve riuscire a completare il loop.

### Test 2 — Fallimento iniziale
La prima previsione deve presentare un problema evidente.

### Test 3 — Prima correzione
Il tester deve avere un'idea di cosa modificare.

### Test 4 — Conseguenza secondaria
La soluzione del primo problema deve poter produrre un nuovo problema.

### Test 5 — Scarsità
Il budget deve costringere a scegliere.

### Test 6 — Esecuzione
Il passaggio da previsione a realtà deve generare tensione.

### Test 7 — Coerenza
L'esecuzione reale deve essere molto simile all'ultima previsione in assenza di variabili introdotte volontariamente.

## Gate

Il Livello 1 è giocabile dall'inizio alla fine senza strumenti di sviluppo.

---

# FASE 22 — Polish, playtest e Vertical Slice finale

## Obiettivo

Portare il prototipo da “funziona” a “fa capire perché questo gioco può essere speciale”.

Questa fase non deve aggiungere nuovi sistemi importanti.

## Implementare

### Grafica
- modelli coerenti;
- silhouette chiare;
- animazioni leggibili;
- illuminazione;
- materiali;
- porte curate;
- feedback danno;
- effetto presente/proiezione.

### Audio
- passi;
- porte;
- spari;
- radio;
- reazioni;
- transizione Precog;
- ambiente.

### UI
- pulizia;
- gerarchia;
- tooltip minimi;
- feedback punti Precog;
- messaggi chiari.

### Camera
- controlli fluidi;
- follow personaggio;
- focus eventi senza forzare il giocatore.

### Tutorial
Tutorial incorporato nella prima missione:
1. osserva;
2. torna;
3. trasferisci informazione;
4. riesegui;
5. comprendi conseguenza;
6. scegli;
7. esegui.

## Test di playtest esterno

Usare persone che NON conoscono il progetto.

### Domanda 1
“Che cosa controllavi?”

Risposta desiderata:
“Le informazioni / il futuro, non direttamente gli agenti.”

### Domanda 2
“Perché è morto il primo agente?”

Deve ricordare la causa.

### Domanda 3
“Perché il secondo futuro era diverso?”

Deve collegarlo all'intervento Precog.

### Domanda 4
“Ti è venuta voglia di vedere cosa succedeva cambiando un'altra informazione?”

Risposta desiderata: sì.

### Domanda 5
“Ti è sembrato che gli agenti sapessero cose impossibili?”

Risposta desiderata: no.

### Domanda 6
“Ti è sembrato casuale?”

Risposta desiderata: no o solo minimamente.

### Domanda 7
“Avresti preferito poterli controllare direttamente?”

La risposta è molto importante.

Se molti dicono sì, bisogna capire se:
- l'autonomia è poco soddisfacente;
- il potere Precog è troppo debole;
- i personaggi si comportano male.

NON introdurre automaticamente controllo diretto.

---

# 4. Test trasversali obbligatori

Questi test devono essere ripetuti dopo ogni fase importante.

## T1 — Conoscenza separata

Posizionare un criminale visibile soltanto ad A.

Verificare che:
- A lo conosca;
- B no;
- altri criminali no salvo comunicazione.

---

## T2 — Nessun wallhack

Spostare un nemico dietro una parete.

Nessuno deve seguirne perfettamente la posizione senza fonte informativa.

---

## T3 — Informazione obsoleta

Far vedere un criminale in A.

Farlo spostare nascosto in B.

L'osservatore deve ricordare A, non B.

---

## T4 — Radio

Rimuovere un evento di avvistamento.

Tutte le conseguenze informative dipendenti devono scomparire.

---

## T5 — Ripetibilità

Tre run consecutive senza modifiche devono produrre lo stesso schema causale.

---

## T6 — Reset

Dopo una proiezione:
- nessuna porta;
- ferita;
- informazione;
- stato di allerta;
- posizione;
- evento

deve contaminare il presente.

---

## T7 — Precog

Aggiungere una singola informazione.

La differenza deve derivare da quella informazione, non da una variazione casuale.

---

## T8 — Nessun controllo diretto

Verificare che nessuna nuova UI abbia introdotto accidentalmente microgestione.

---

## T9 — Spiegabilità

Se un personaggio prende una decisione importante, il sistema di analisi deve permettere di ricostruire il motivo.

---

## T10 — Guardabilità

Disattivare tutti i pannelli di debug.

La scena deve restare comprensibile.

---

# 5. Criteri di regressione

Ogni nuova fase deve preservare tutte le precedenti.

Esempio:

Aggiungendo la radio non è accettabile rompere:
- visione;
- memoria;
- movimento;
- ripetibilità.

Aggiungendo il Precog non è accettabile:
- dare conoscenza globale;
- aggirare la separazione informativa;
- rendere inutili vista e radio.

Aggiungendo UI non è accettabile:
- oscurare la scena;
- trasformare il gioco in un gestionale.

---

# 6. Regole per l'AI che implementa il progetto

## 6.1 Prima di ogni fase

L'AI deve dichiarare:
- fase corrente;
- dipendenze;
- feature da implementare;
- feature che resteranno fuori;
- test che dovranno passare.

## 6.2 Durante la fase

L'AI deve:
- fare modifiche incrementali;
- mantenere il progetto avviabile;
- non accumulare dieci sistemi non testati insieme;
- utilizzare la modalità debug per verificare gli stati interni.

## 6.3 Dopo la fase

L'AI deve produrre un report con:

### Implementato
Lista concreta.

### Non implementato
Lista esplicita.

### Test eseguiti
Per ogni test:
- PASS;
- FAIL;
- osservazioni.

### Regressione
Quali test precedenti sono stati rieseguiti.

### Problemi conosciuti
Solo problemi reali ancora presenti.

### Gate
- GO;
oppure
- NO-GO.

Se NO-GO:
la fase successiva non deve iniziare.

---

# 7. Ordine delle priorità in caso di problemi

Quando esistono problemi simultanei, correggere in questo ordine:

1. crash / errori bloccanti;
2. reset del presente;
3. conoscenza errata;
4. ripetibilità;
5. comportamento illogico;
6. movimento;
7. leggibilità visiva;
8. UX;
9. polish.

Motivo:

Un'animazione brutta può essere corretta dopo.

Un agente onnisciente distrugge il concept.

---

# 8. Cosa NON ottimizzare prematuramente

Durante il Vertical Slice non spendere tempo eccessivo su:
- folle numerose;
- performance per centinaia di NPC;
- multiplayer;
- streaming di mondi;
- procedural generation;
- networking;
- save game complessi;
- mod support;
- localization completa;
- console;
- mobile;
- achievement;
- Steam integration.

Il Vertical Slice serve a validare PRECOG.

---

# 9. “Definition of Done” del Vertical Slice

Il progetto è considerato riuscito solo se soddisfa TUTTE queste condizioni.

## Simulazione
- [ ] gli agenti agiscono senza input diretto;
- [ ] i criminali agiscono senza input diretto;
- [ ] il civile reagisce autonomamente;
- [ ] le unità possiedono conoscenza individuale;
- [ ] vista, suono e radio hanno effetti separati;
- [ ] nessuna unità possiede tracking magico;
- [ ] le informazioni possono diventare obsolete.

## Precog
- [ ] il presente è ripristinabile;
- [ ] il futuro può essere osservato;
- [ ] una nuova proiezione riparte dallo stesso presente;
- [ ] l'informazione Precog modifica il comportamento;
- [ ] il giocatore non impartisce azioni dirette;
- [ ] esiste un budget limitato;
- [ ] esistono trade-off reali.

## Causalità
- [ ] la stessa situazione produce quasi lo stesso futuro;
- [ ] cambiare una informazione può cambiare una catena di eventi;
- [ ] impedire una radio cambia il comportamento di chi l'avrebbe ricevuta;
- [ ] il timing può produrre conseguenze indirette;
- [ ] il giocatore può capire almeno le principali cause.

## UX
- [ ] presente e proiezione sono distinti;
- [ ] la timeline funziona;
- [ ] il giocatore può analizzare una decisione;
- [ ] la camera permette di osservare gli eventi;
- [ ] la UI non consente microgestione.

## Missione
- [ ] esiste un obiettivo;
- [ ] esistono fallimenti;
- [ ] esistono esiti parziali;
- [ ] esiste esecuzione definitiva;
- [ ] esiste debrief.

## Feeling
- [ ] il primo fallimento incuriosisce;
- [ ] la prima modifica Precog produce soddisfazione;
- [ ] il secondo futuro produce nuove domande;
- [ ] gli agenti sembrano individui;
- [ ] il tester vuole fare almeno una proiezione in più.

---

# 10. Sequenza minima consigliata di build dimostrative

## Build A — “The Dollhouse”
Mappa e camera.

Scopo:
verificare leggibilità.

## Build B — “The Walker”
Un agente attraversa autonomamente l'edificio.

Scopo:
verificare movimento.

## Build C — “I Can See You”
Un agente scopre un criminale soltanto quando realmente visibile.

Scopo:
verificare percezione.

## Build D — “I Saw You There”
Il criminale scompare dalla vista ma resta nell'ultima posizione conosciuta.

Scopo:
verificare memoria.

## Build E — “The Gunshot”
Un personaggio reagisce a uno sparo che non ha visto.

Scopo:
verificare suono.

## Build F — “The Door”
L'agente ignaro entra e viene sorpreso.

Scopo:
verificare autonomia e causalità.

## Build G — “The Call”
Un criminale avvisa il secondo via radio.

Scopo:
verificare propagazione informativa.

## Build H — “Reset”
La scena torna perfettamente allo stato iniziale.

Scopo:
verificare fondazione del Precog.

## Build I — “First Vision”
Il giocatore osserva il futuro e torna.

Scopo:
verificare PRESENTE / PROIEZIONE.

## Build J — “I Warned You”
Il giocatore comunica l'ostile dietro la porta.

Scopo:
verificare il cuore di PRECOG.

## Build K — “Butterfly”
Salvando l'agente cambia un evento successivo.

Scopo:
verificare conseguenza emergente.

## Build L — “Choose”
Il budget impedisce di correggere tutto.

Scopo:
verificare game design.

## Build M — “Commit”
Il giocatore accetta una previsione ed esegue realmente la missione.

Scopo:
verificare tensione finale.

## Build N — Vertical Slice
Tutto pulito, comprensibile e presentabile.

---

# 11. Il test più importante di tutto il progetto

Quando esiste la Build J, fare questo test prima di proseguire.

Mostrare a una persona:

## Prima proiezione

L'agente arriva alla porta.

Non conosce il nemico.

Entra.

Viene colpito.

## Presente

Applicare:

> “Ostile previsto nella stanza.”

## Seconda proiezione

L'agente arriva alla stessa porta.

Ora possiede un'informazione diversa.

Rallenta.

Cambia comportamento.

Affronta diversamente la situazione.

Poi chiedere:

> **“Vuoi vedere cosa succede se gli diamo un'informazione diversa?”**

Se la risposta spontanea è sì, PRECOG ha superato la sua validazione più importante.

Se la risposta è no, fermarsi.

Non aggiungere contenuti.

Capire perché il loop non produce curiosità.

---

# 12. Principio finale per l'AI

In qualsiasi momento dello sviluppo, l'AI deve poter rispondere a queste tre domande:

### 1. Cosa sa questo personaggio?
Se la risposta non è chiara, il sistema è troppo opaco.

### 2. Perché sta facendo questa cosa?
Se la risposta non deriva da conoscenza + obiettivo + stato, c'è un problema.

### 3. Quale informazione posso cambiare per modificare il futuro?
Se il giocatore non ha una risposta, il gameplay Precog non sta funzionando.

---

# 13. Regola d'oro del progetto

> **IL GIOCATORE NON MUOVE LE PERSONE. MUOVE L'INFORMAZIONE.**

E la regola d'oro dello sviluppo è:

> **PRIMA RENDERE UNA CAUSA AFFIDABILE E LEGGIBILE. POI AGGIUNGERE LA CAUSA SUCCESSIVA.**

Il Vertical Slice non deve impressionare per quantità.

Deve impressionare perché il giocatore guarda un futuro, capisce qualcosa che i personaggi non sanno, trasferisce una piccola informazione e vede l'intero corso degli eventi cambiare davanti ai suoi occhi.
