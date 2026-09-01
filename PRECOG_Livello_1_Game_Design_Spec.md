# PRECOG — Specifica di Game Design
## Livello 1 / Vertical Slice di prova

**Versione:** 0.1  
**Scopo:** specifica funzionale e di esperienza del primo livello giocabile  
**Documento:** Game Design, non specifica tecnica  
**Esclusioni esplicite:** nessun codice, nessun algoritmo di AI, nessuna architettura software

---

# 1. Scopo del prototipo

Il Livello 1 deve dimostrare una singola idea con assoluta chiarezza:

> **Il giocatore non controlla direttamente gli agenti. Osserva un futuro probabile, torna al presente, modifica ciò che gli agenti sanno o come devono affrontare la situazione, e osserva un nuovo futuro.**

Il prototipo non deve dimostrare la quantità di contenuti che potrebbe avere il gioco completo.

Non deve dimostrare:
- una campagna;
- decine di abilità;
- un sistema RPG;
- una grande varietà di nemici;
- proceduralità;
- una simulazione urbana;
- una struttura strategica;
- una storia complessa;
- una AI sofisticata in termini tecnici.

Deve dimostrare che il **loop precognitivo è divertente da solo**.

La domanda a cui il Livello 1 deve rispondere è:

> “È interessante vedere una situazione evolvere autonomamente, capire perché va male, intervenire solo attraverso informazioni e direttive indirette, e osservare la stessa situazione cambiare?”

Se la risposta è sì, il progetto ha una base.

Se la risposta è no, aggiungere contenuti non risolverà il problema.

---

# 2. Visione del gioco

Il gioco deve trasmettere la sensazione di essere una presenza esterna all'azione, capace di vedere ciò che ancora non è successo ma incapace di prendere il controllo delle persone coinvolte.

Il giocatore:
- non è il comandante che muove pedine;
- non è il soldato che spara;
- non è un dio che controlla tutto;
- non è un regista che costruisce una sequenza perfetta.

È un **precog operativo**.

Vede frammenti di futuro.

Può usare quelle informazioni per modificare il presente.

Ma il mondo resta autonomo.

Gli agenti interpretano le informazioni ricevute e agiscono secondo la situazione.

I criminali reagiscono a ciò che percepiscono.

Gli eventi possono produrre conseguenze non previste.

Il risultato ideale è che il giocatore pensi continuamente:

> “Adesso capisco perché è successo.”

seguito da:

> “Se gli dicessi solo questa cosa, forse cambierebbe tutto.”

e infine:

> “Interessante: ho salvato lui, ma così ho creato un problema diverso.”

---

# 3. Pilastri fondamentali

Il Livello 1 deve proteggere questi pilastri. Se una scelta di design li indebolisce, va scartata.

## 3.1 Nessun controllo diretto

Il giocatore non può:
- cliccare un agente e ordinargli una destinazione precisa;
- tracciare un percorso;
- scegliere il bersaglio di ogni colpo;
- ordinare esattamente quando aprire una porta;
- dire dove guardare;
- comandare ogni movimento;
- mettere in pausa il futuro per impartire nuovi ordini.

Ogni interazione deve essere indiretta.

Il giocatore modifica:
- conoscenza;
- priorità;
- atteggiamento;
- livello di cautela;
- attenzione verso una zona;
- importanza di un obiettivo.

L'esecuzione concreta appartiene agli agenti.

---

## 3.2 Il futuro deve essere visivo

Il futuro non deve essere principalmente:
- testo;
- icone;
- frecce;
- turni;
- caselle;
- log.

Il futuro deve essere soprattutto **qualcosa che si guarda accadere**.

Il giocatore deve vedere:
- un agente avanzare;
- fermarsi;
- guardare;
- aprire una porta;
- sorprendersi;
- reagire;
- sparare;
- abbassarsi;
- aggirare;
- aspettare;
- soccorrere;
- venire colpito;
- perdere un bersaglio;
- salvare o non salvare una persona.

La lettura dell'evento deve avvenire prima con gli occhi e poi, se necessario, attraverso strumenti di approfondimento.

---

## 3.3 Ogni personaggio vive nella propria informazione

Il mondo possiede una verità oggettiva.

I personaggi no.

Ogni personaggio può agire solo sulla base di ciò che:
- vede;
- ha visto;
- sente;
- ha sentito;
- gli è stato comunicato;
- gli è stato indicato dal precog.

Un agente non sa che un criminale è dietro una porta solo perché il gioco lo sa.

Un criminale non conosce automaticamente la posizione degli agenti.

Un criminale non sa automaticamente che un compagno è morto.

Un agente non conosce automaticamente ciò che ha visto un altro agente.

La separazione delle informazioni deve essere percepibile dal giocatore.

---

## 3.4 Il precog modifica informazione, non realtà

Il precog non:
- teletrasporta;
- congela nemici;
- aumenta magicamente la precisione;
- impone eventi;
- controlla il comportamento minuto per minuto.

Il precog porta nel presente informazioni provenienti dal futuro.

Questo deve essere il centro del sistema.

---

## 3.5 Ogni intervento deve avere un costo

Il giocatore non deve poter correggere ogni problema.

La scarsità è fondamentale.

Se può dire tutto a tutti, il precog diventa semplicemente una modalità onnisciente.

Il giocatore deve scegliere:
- chi avvertire;
- di cosa;
- con quale precisione;
- con quale priorità.

La risorsa precog rappresenta quindi la capacità limitata di trasformare una visione in informazione operativa.

---

## 3.6 Le conseguenze devono essere comprensibili

Il comportamento può essere autonomo, ma non deve sembrare arbitrario.

Il giocatore deve poter capire:
- cosa sapeva un agente;
- cosa non sapeva;
- cosa aveva percepito;
- quale direttiva aveva ricevuto;
- quale obiettivo stava perseguendo;
- quale evento ha fatto cambiare il suo comportamento.

Il gioco non deve spiegare tutto continuamente.

Deve però permettere di indagare quando qualcosa sorprende il giocatore.

---

# 4. Feeling desiderato

Il gioco deve produrre una combinazione di:

### Tensione
Il futuro che si guarda deve sembrare reale e irreversibile, anche se tecnicamente è una previsione.

### Curiosità
Il giocatore deve voler vedere:
> “Cosa succede se cambio solo questo?”

### Impotenza controllata
Il giocatore ha un potere enorme, ma limitato.

Vede più degli altri, ma non può comandarli.

### Soddisfazione causale
Il piacere principale non è “ho sparato bene”.

È:
> “Ho capito la catena degli eventi e l'ho deviata.”

### Ansia da conseguenza
Un intervento corretto localmente può creare un nuovo problema altrove.

### Identificazione con gli agenti
Gli agenti non devono sembrare pedine.

Il giocatore deve iniziare a riconoscerne il comportamento e fidarsi o preoccuparsi di loro.

### Chiarezza
La complessità deve nascere dalle interazioni, non da un'interfaccia complicata.

---

# 5. Cosa NON deve diventare

Il prototipo deve evitare con decisione di trasformarsi in:

## RTS
Niente selezione continua delle unità e ordini di movimento.

## XCOM in tempo reale
Niente gestione di coperture, percentuali di tiro e azioni individuali.

## Puzzle a soluzione unica
Non deve esserci necessariamente una combinazione perfetta predeterminata.

## Cinematica interattiva
Il giocatore deve avere vera influenza, non scegliere tra tre filmati.

## Simulatore di comando SWAT tradizionale
Il focus non è pianificare ogni ingresso.

## Tower defense
Gli agenti non sono unità da posizionare.

## Gestionale di statistiche
I numeri devono restare subordinati agli eventi visibili.

---

# 6. Struttura generale del Livello 1

Il Livello 1 deve essere piccolo.

La dimensione ideale è sufficiente a creare più linee di vista e più percorsi, ma abbastanza contenuta da permettere al giocatore di comprendere la situazione dopo poche proiezioni.

## Ambientazione proposta

Un piccolo edificio su un solo piano, ad esempio:
- magazzino;
- officina;
- piccolo ufficio industriale;
- stazione di servizio abbandonata;
- deposito.

Per il prototipo è preferibile un ambiente leggibile e funzionale.

### Struttura minima
- ingresso principale;
- corridoio o spazio centrale;
- 3–5 stanze;
- almeno due possibili percorsi;
- una porta che crea un punto cieco;
- una zona con copertura;
- una zona aperta;
- almeno un accesso secondario.

L'ambiente deve essere abbastanza piccolo da consentire al giocatore di impararne rapidamente la geografia.

---

# 7. Cast minimo del Livello 1

## Agenti
**2 agenti operativi.**

Devono essere sufficientemente differenti da produrre comportamenti leggibili.

Esempio:

### Agente A — più prudente
Tende a:
- fermarsi prima di entrare in zone sospette;
- aspettare il compagno;
- reagire con cautela alle informazioni di pericolo.

### Agente B — più deciso
Tende a:
- mantenere il ritmo;
- sfruttare opportunità;
- intervenire rapidamente.

Non serve un sistema RPG.

La differenza deve essere osservabile nel comportamento.

---

## Criminali
**2 criminali.**

Esempio:

### Criminale 1
- armato;
- vicino all'obiettivo;
- comportamento relativamente stabile.

### Criminale 2
- mobile;
- può spostarsi;
- può reagire a rumori o comunicazioni.

---

## Civile / obiettivo
**1 persona da proteggere**, oppure un obiettivo equivalente.

La presenza di un civile è fortemente consigliata perché impedisce al problema di ridursi a “uccidi i due nemici”.

Il civile rende possibili conseguenze come:
- fuga;
- ostaggio;
- esposizione al fuoco;
- panico;
- morte indiretta causata da un cambiamento del piano.

---

# 8. Stato iniziale del Livello 1

Il presente parte da una situazione definita.

Esempio:

- due agenti stanno per entrare nell'edificio;
- conoscono l'obiettivo generale;
- sanno che esistono sospetti armati;
- non conoscono le posizioni precise;
- i criminali non sanno ancora dove siano gli agenti;
- un civile è all'interno;
- il giocatore possiede una quantità limitata di punti precog.

Il Livello 1 non deve iniziare con un briefing enorme.

Il giocatore deve capire velocemente:

> “Dentro c'è una situazione pericolosa. I miei agenti entreranno. Vediamo cosa succede.”

---

# 9. Il ciclo fondamentale di gioco

Il loop deve essere sempre riconoscibile.

## Fase 1 — Presente

Il tempo reale è fermo.

Il giocatore può:
- osservare la scena;
- consultare le informazioni disponibili;
- vedere quali direttive precog sono attive;
- modificare le informazioni trasferite agli agenti;
- scegliere l'orizzonte della proiezione se previsto;
- avviare una proiezione.

Non può vedere liberamente la verità nascosta del mondo se non attraverso il futuro già osservato.

---

## Fase 2 — Proiezione

Il giocatore avvia:

> **VEDI IL FUTURO**

La simulazione parte.

Gli agenti e i criminali agiscono autonomamente.

Il giocatore:
- guarda;
- sposta la telecamera;
- segue un personaggio;
- mette in pausa;
- rallenta;
- torna indietro nella registrazione della proiezione;
- consulta informazioni sul perché un personaggio ha reagito.

Non può cambiare nulla durante la proiezione.

---

## Fase 3 — Evento critico

Accade qualcosa che il giocatore vuole modificare.

Esempi:
- un agente viene colpito;
- il civile muore;
- un criminale fugge;
- gli agenti si separano;
- qualcuno entra in una stanza senza sapere del pericolo;
- una sparatoria provoca una reazione a catena;
- un criminale viene allertato troppo presto.

---

## Fase 4 — Ritorno al presente

La proiezione termina o il giocatore decide di interromperla.

Il gioco torna esattamente allo stato iniziale del presente.

Niente di ciò che è accaduto nella proiezione è realmente avvenuto.

Resta solo la conoscenza del giocatore.

---

## Fase 5 — Intervento precog

Il giocatore spende risorse per trasferire nel presente alcune informazioni.

Esempi:
- “Pericolo in questa stanza.”
- “Possibile ostile armato qui.”
- “Presta attenzione a questo accesso.”
- “Approccio prudente.”
- “Obiettivo prioritario: proteggi il civile.”
- “Possibile movimento ostile da questa direzione.”

---

## Fase 6 — Nuova proiezione

Il futuro viene rieseguito con le nuove informazioni.

Il giocatore osserva come la catena causale cambia.

Questo è il cuore del gioco.

---

# 10. Durata della proiezione

Per il Livello 1 l'orizzonte deve essere breve.

Obiettivo consigliato:

**30–60 secondi.**

Un primo valore ideale è circa **45 secondi**.

Deve essere:
- abbastanza lungo da produrre una catena di eventi;
- abbastanza corto da poter essere rivisto più volte senza noia.

Il giocatore deve poter interrompere la proiezione in qualsiasi momento.

Non è necessario osservare ogni volta tutti i 45 secondi.

---

# 11. Regola fondamentale: il futuro viene rieseguito

Ogni nuova proiezione parte dallo stesso presente.

Questo deve essere chiarissimo.

Il giocatore non “riavvolge il tempo”.

Sta osservando una nuova previsione a partire dal medesimo momento.

Per il Livello 1 è importante che la simulazione sia sufficientemente coerente da permettere apprendimento causale.

In condizioni identiche, il futuro dovrebbe apparire sostanzialmente uguale.

Piccole variazioni visive sono accettabili.

Non deve invece accadere che:
- senza nessun intervento un personaggio scelga casualmente un percorso completamente diverso;
- lo stesso colpo trasformi continuamente la scena in risultati opposti;
- il giocatore non possa distinguere l'effetto del proprio intervento dal rumore casuale.

La prevedibilità è necessaria affinché il sistema precog sia comprensibile.

---

# 12. La risorsa Precog

Il giocatore possiede una risorsa limitata.

Nome provvisorio:

**Punti Precog**

Per il Livello 1 si suggerisce un budget semplice, ad esempio:

**8–10 punti.**

Il valore esatto va bilanciato.

La regola importante è:

> non deve essere possibile comunicare tutte le informazioni utili contemporaneamente.

---

# 13. Tipologie di intervento Precog

Il prototipo deve avere poche categorie molto chiare.

Meglio 5 interventi leggibili che 20 vaghi.

## 13.1 Segnalazione di pericolo

Esempio:

> **PERICOLO — STANZA**

Comunica all'agente che quella zona è rischiosa.

Non comunica:
- numero di nemici;
- posizione precisa;
- tipo di arma;
- momento esatto.

Costo basso.

Serve a testare il concetto di informazione generica.

---

## 13.2 Presenza ostile

Esempio:

> **OSTILE PRESENTE**

Comunica che in una zona si trova o si troverà una minaccia concreta.

È più precisa e più costosa.

Non deve trasformarsi in wallhack permanente.

È un'informazione operativa ricevuta dall'agente.

---

## 13.3 Posizione precisa

Esempio:

> **OSTILE — DIETRO QUESTA PORTA**

Informazione molto potente.

Costo alto.

Serve a mostrare chiaramente il rapporto:
maggiore precisione = maggiore costo.

---

## 13.4 Direttiva comportamentale

Esempi:
- prudente;
- furtivo;
- aggressivo;
- priorità alla protezione.

Non è un ordine specifico.

È una modifica temporanea del modo in cui l'agente interpreta la situazione.

---

## 13.5 Priorità di obiettivo

Esempi:

> “Proteggi il civile.”

> “Impedisci la fuga del sospetto.”

> “Resta coordinato con il compagno.”

Serve a modificare ciò che l'agente considera più importante quando gli obiettivi entrano in conflitto.

---

# 14. Cosa NON può comunicare il Precog nel Livello 1

Per preservare il concept, sono vietati ordini del tipo:

- vai in questo punto;
- percorri questo corridoio;
- apri questa porta alle 00:12;
- spara a questo personaggio;
- attendi esattamente 5 secondi;
- lancia una granata qui;
- guarda a sinistra;
- mettiti dietro questa copertura;
- entra dalla finestra;
- spostati di tre metri.

Se una direttiva definisce esattamente l'azione fisica, è troppo vicina al controllo diretto.

---

# 15. A chi si applicano le informazioni

Nel Livello 1 il giocatore deve poter indirizzare un'informazione:

- a un singolo agente;
- eventualmente a entrambi, pagando un costo maggiore.

Questo crea decisioni interessanti.

Esempio:

Il giocatore sa che un criminale è dietro una porta.

Può:
- informare solo l'agente A;
- informare solo l'agente B;
- informare entrambi spendendo di più.

Gli agenti non devono automaticamente condividere ogni informazione precog tra loro, salvo comunicazione visibile o regole esplicite.

---

# 16. Percezione e conoscenza — regole di game design

Questa sezione descrive il comportamento desiderato, non la sua implementazione tecnica.

Ogni personaggio può conoscere informazioni provenienti da fonti differenti.

## 16.1 Vista

Un personaggio conosce ciò che vede.

La vista deve essere plausibile.

Elementi che bloccano la visione:
- muri;
- porte chiuse;
- angoli;
- ostacoli significativi.

Un personaggio non deve reagire a un nemico invisibile senza una ragione informativa.

---

## 16.2 Suono

I personaggi possono reagire a:
- spari;
- passi ravvicinati;
- porte;
- urla;
- vetri;
- altri rumori importanti.

Il suono deve fornire informazione approssimativa.

Esempio:

> “Rumore a nord.”

non:

> “Nemico esattamente a coordinate X/Y.”

---

## 16.3 Memoria

Un personaggio può ricordare:
- dove ha visto qualcuno;
- dove ha sentito qualcosa;
- dove si trovava un compagno;
- cosa gli è stato comunicato.

L'informazione può diventare vecchia.

Il gioco deve trasmettere che:

> “era lì”

non significa:

> “è ancora lì”.

---

## 16.4 Comunicazione

Un personaggio può ricevere informazioni da:
- un compagno vicino;
- una radio;
- un evento evidente;
- il precog.

Le informazioni non devono essere magicamente condivise.

---

# 17. Radio

La radio deve essere presente nel Livello 1 in forma semplice.

Serve a rendere evidente che le informazioni possono propagarsi.

Esempio:

Un criminale vede un agente.

Se riesce a comunicare:

> “Agente all'ingresso!”

Gli altri criminali vengono allertati.

Ma conoscono:
- l'ultima posizione comunicata;
- non la posizione attuale continua.

La radio deve generare situazioni come:

1. criminale A vede agente;
2. avvisa criminale B;
3. criminale B cambia comportamento;
4. il giocatore nella nuova proiezione impedisce che A veda l'agente;
5. B non riceve più l'allarme;
6. il futuro cambia anche senza interagire direttamente con B.

Questo è esattamente il tipo di causalità che il gioco deve valorizzare.

---

# 18. Stato di allerta

Personaggi ostili devono poter essere almeno in tre stati percepibili:

## Ignaro
Non sa che gli agenti sono presenti.

## Sospettoso
Ha percepito qualcosa ma non ha conferme.

## Allertato
Sa che esiste una minaccia concreta.

Questi stati devono produrre comportamenti visivamente differenti.

Non serve che il giocatore veda sempre un'etichetta.

Deve poterlo intuire da:
- postura;
- movimento;
- attenzione;
- ritmo.

---

# 19. Comportamento degli agenti

Gli agenti devono sembrare professionisti autonomi.

Devono essere capaci di:
- muoversi verso l'obiettivo;
- attraversare porte;
- usare lo spazio;
- reagire a un nemico;
- reagire a un colpo;
- utilizzare coperture in modo credibile;
- seguire una priorità;
- aspettare brevemente un compagno;
- inseguire o rinunciare a seconda del contesto;
- soccorrere/proteggere il civile se appropriato.

Il giocatore non deve sentirsi costretto a correggere stupidità di base.

Il precog deve servire a dare informazioni che gli agenti non potrebbero possedere.

Non deve servire a compensare comportamenti evidentemente assurdi.

---

# 20. Personalità operativa minima

Gli agenti devono essere distinguibili.

Per il Livello 1 non serve un pannello di statistiche.

È sufficiente che abbiano una caratterizzazione chiara.

Esempio:

## Agente A
“Metodo e sicurezza.”

## Agente B
“Velocità e iniziativa.”

Questa differenza deve emergere nelle stesse condizioni.

Se entrambi ricevono:

> “Possibile ostile nella stanza.”

A potrebbe:
- fermarsi;
- controllare;
- aspettare il compagno.

B potrebbe:
- sfruttare immediatamente una posizione favorevole;
- entrare più rapidamente se ritiene di avere vantaggio.

La differenza non deve rendere uno dei due “stupido”.

---

# 21. Nemici

I criminali devono sembrare persone che cercano di sopravvivere e perseguire uno scopo.

Devono poter:
- pattugliare o aspettare;
- reagire a rumore;
- notare agenti;
- comunicare;
- cercare copertura;
- sparare;
- spostarsi;
- fuggire;
- minacciare il civile se previsto dalla situazione;
- cercare un compagno che non risponde, se coerente.

Non devono sapere tutto.

---

# 22. Il civile

Il civile serve come generatore di conseguenze.

Può:
- restare nascosto;
- reagire a una sparatoria;
- muoversi se spaventato;
- diventare esposto;
- essere salvato;
- essere ferito o ucciso.

Per il primo prototipo il comportamento deve restare leggibile.

Il civile non deve produrre caos completamente casuale.

---

# 23. Combattimento

Il combattimento deve essere breve, leggibile e pericoloso.

Non deve diventare il focus principale.

Il giocatore deve capire:

> “L'agente è morto perché è entrato senza sapere che c'era un uomo armato.”

Non:

> “È morto perché una formula di precisione ha generato 17 invece di 18.”

Il dettaglio numerico non deve dominare la percezione.

Le sparatorie devono avere conseguenze forti:
- ferita;
- incapacità;
- morte;
- fuga;
- allerta.

---

# 24. Furtività

La furtività deve emergere dal comportamento, non da un minigioco separato.

Una direttiva “furtivo” può portare un agente a:
- muoversi più lentamente;
- evitare esposizione;
- ridurre rumore;
- preferire approcci meno evidenti;
- aspettare un momento migliore.

Il giocatore non controlla direttamente ogni gesto.

---

# 25. Porte

Le porte sono un elemento chiave del Livello 1.

Devono creare:
- occultamento;
- rischio;
- sorprese;
- decisioni;
- cambiamenti tra una previsione e l'altra.

Almeno una situazione importante del livello deve ruotare intorno a una porta.

Esempio fondamentale:

### Futuro iniziale
Agente entra senza sapere del nemico → viene colpito.

### Dopo intervento Precog
Agente sa del pericolo → cambia approccio → sopravvive.

Questa sequenza deve essere una delle dimostrazioni principali del prototipo.

---

# 26. Linea di vista

La lettura della visibilità deve essere intuitiva.

Il giocatore deve poter capire:
- chi può vedere chi;
- perché un personaggio non ha reagito;
- quali oggetti o angoli bloccano la vista.

Non serve mostrare sempre coni di visione.

Può esistere una modalità di analisi opzionale.

---

# 27. Modalità di analisi

Durante una proiezione il giocatore deve poter selezionare un personaggio e vedere un riepilogo semplice.

Esempio:

**AGENTE A**

- Obiettivo: raggiungere il civile
- Stato: prudente
- Nemici visibili: nessuno
- Ultimo rumore: sparo a est
- Informazione precog: possibile ostile nella stanza 3
- Decisione corrente: controllare l'accesso prima di entrare

Questa vista serve a rispondere alla domanda:

> “Perché sta facendo questo?”

Non deve diventare un debugger.

---

# 28. Timeline della proiezione

La proiezione deve avere una timeline.

Funzioni richieste:
- play;
- pausa;
- velocità ridotta;
- velocità normale;
- eventualmente velocità aumentata;
- trascinamento indietro;
- ritorno a un momento già osservato.

Il giocatore deve poter riesaminare un evento.

Esempio:

> “Chi ha visto per primo l'agente?”

Torna indietro di cinque secondi e osserva.

---

# 29. Eventi evidenziati sulla timeline

Il Livello 1 può mostrare marcatori per eventi importanti:

- primo contatto;
- colpo esploso;
- agente ferito;
- criminale allertato;
- civile in pericolo;
- morte;
- fuga;
- obiettivo completato.

Servono a navigare la proiezione.

Non devono sostituire l'osservazione visiva.

---

# 30. Telecamera

La telecamera deve favorire la comprensione.

Per il prototipo:

## Camera libera 3D
Il giocatore può:
- orbitare;
- spostarsi;
- zoomare.

## Segui personaggio
Un pulsante consente di seguire:
- agente A;
- agente B;
- criminale A;
- criminale B;
- civile.

La telecamera non deve diventare un ostacolo.

---

# 31. Rappresentazione del presente e del futuro

Deve essere impossibile confondere i due stati.

## Presente
Sensazione:
- stabile;
- nitida;
- sospesa;
- silenziosa o quasi.

## Futuro
Sensazione:
- proiezione;
- possibile;
- leggermente irreale.

La differenza può essere ottenuta con:
- trattamento visivo;
- audio;
- interfaccia;
- particelle leggere;
- distorsione minima;
- indicatore temporale.

Non deve compromettere la leggibilità.

---

# 32. UI del presente

Elementi essenziali:

- indicazione **PRESENTE**;
- punti Precog disponibili;
- elenco sintetico degli agenti;
- interventi già applicati;
- pulsante principale **VEDI IL FUTURO**;
- eventuale selezione durata proiezione;
- obiettivo della missione.

L'interfaccia deve essere minimalista.

---

# 33. UI durante il futuro

Elementi essenziali:

- indicazione **PROIEZIONE**;
- tempo trascorso, ad esempio `+17.4 s`;
- timeline;
- controlli playback;
- pulsante ritorno al presente;
- selezione personaggi;
- accesso alla modalità analisi.

Durante la proiezione non devono apparire controlli che sembrino permettere di modificare gli ordini.

---

# 34. Modalità di applicazione del Precog

Il modo in cui il giocatore applica un'informazione deve essere estremamente semplice.

Esempio:

1. torna al presente;
2. seleziona agente;
3. sceglie “Segnalazione Precog”;
4. seleziona una categoria;
5. indica la zona/persona rilevante;
6. vede il costo;
7. conferma.

Non devono servire menu profondi.

---

# 35. Informazioni ottenute dal futuro

Il giocatore, in quanto precog, può ricordare ciò che ha visto.

Il gioco non deve necessariamente impedirgli di spostare la telecamera ovunque durante la proiezione.

Nel Livello 1 è accettabile che il giocatore possa osservare liberamente tutta la proiezione.

La limitazione fondamentale non è:

> “non puoi vedere”.

È:

> “non puoi comunicare tutto.”

In futuro potranno esistere limiti di visione precog più complessi.

Non sono necessari per il prototipo.

---

# 36. Il paradosso utile: conoscere non significa poter intervenire

Il giocatore potrebbe vedere:
- tutti i criminali;
- tutte le loro azioni future;
- l'intera sequenza.

Ma possiede solo pochi punti.

Quindi deve trasformare una grande quantità di conoscenza in poche informazioni operative.

Questo è il vero puzzle.

---

# 37. Esempio completo di una prima partita

## Presente

Due agenti stanno entrando.

Il giocatore non assegna nulla.

Premere:

> **VEDI IL FUTURO**

---

## Proiezione 1

### +00
Agente A entra dall'ingresso.

Agente B lo segue.

### +08
A attraversa il corridoio.

### +12
Un criminale è nella stanza laterale.

A non lo sa.

### +14
A apre la porta.

### +14.5
Il criminale vede A.

### +15
Spara.

### +16
A cade.

### +17
B sente il colpo.

### +19
B raggiunge il corridoio.

### +20
Il criminale avvisa il compagno via radio.

### +26
Il secondo criminale si sposta.

### +33
Il civile tenta di fuggire.

### +37
Il civile entra nella linea di tiro.

### +39
Civile ferito.

### +45
Missione compromessa.

---

# 38. Prima decisione Precog

Il giocatore torna al presente.

Ha capito:

> il primo problema è l'imboscata dietro la porta.

Può spendere:

**2 punti — Presenza ostile nella stanza**

applicata ad Agente A.

---

# 39. Proiezione 2

### +12
A arriva vicino alla porta.

Ora sa che esiste un pericolo.

Rallenta.

B lo raggiunge.

### +16
A e B affrontano meglio l'ingresso.

### +19
Il criminale viene neutralizzato.

Problema risolto.

Ma:

### +21
Gli spari sono avvenuti più tardi rispetto alla previsione precedente.

### +28
Il secondo criminale, che in precedenza si era spostato dopo una comunicazione radio, resta nella sua posizione.

### +34
Il civile tenta comunque di uscire.

### +38
Si trova ora vicino al secondo criminale.

### +41
Diventa ostaggio.

Nuovo problema.

Il giocatore comprende:

> salvare A ha modificato la sequenza e creato un futuro differente.

Questo è esattamente il feeling desiderato.

---

# 40. Seconda decisione Precog

Il giocatore potrebbe scegliere:

- avvertire l'agente B del secondo criminale;
- dare priorità al civile;
- chiedere un approccio più furtivo per evitare gli spari;
- segnalare la zona del civile;
- non cambiare nulla sul primo criminale e provare una strategia differente.

Non deve esistere una soluzione obbligatoria.

---

# 41. Obiettivo del Livello 1

Obiettivo principale:

> **Salvare il civile e impedire che i criminali rappresentino ancora una minaccia.**

Condizioni accettabili di successo:
- civile vivo;
- almeno un agente operativo;
- criminali arrestati, neutralizzati o incapaci di proseguire l'azione;
- nessun criminale fuggito.

Per il prototipo si può definire un successo più restrittivo, ad esempio:
- entrambi gli agenti vivi;
- civile vivo;
- entrambi i criminali neutralizzati.

---

# 42. Fallimento

Possibili condizioni:

- civile morto;
- entrambi gli agenti incapacitati;
- criminale principale fuggito;
- tempo massimo della missione superato.

Durante una proiezione il fallimento non è “reale”.

È solo un risultato previsto.

Il fallimento reale avviene solamente quando il giocatore decide di:

> **CONFERMARE IL FUTURO / ESEGUIRE**

---

# 43. Esecuzione reale finale

Il Livello 1 deve distinguere tra:

## Proiezione
Non consuma il mondo reale.

## Esecuzione
Quando il giocatore è soddisfatto, conferma il piano informativo.

Premere:

> **ESEGUI**

A quel punto:
- il tempo reale parte;
- la scena viene vissuta definitivamente;
- non è più possibile tornare al presente;
- il giocatore osserva il risultato.

Questa fase dà peso alle decisioni.

---

# 44. Perché serve l'esecuzione finale

Senza esecuzione finale il giocatore potrebbe continuare a iterare finché trova un futuro perfetto.

Con una conferma esplicita nasce il momento:

> “Mi fido abbastanza di questa previsione?”

Per il primo livello le proiezioni possono essere illimitate.

Il costo riguarda le informazioni applicate, non il numero di tentativi.

In versioni future si potrà limitare anche il numero o la profondità delle visioni.

---

# 45. Conferma prima dell'esecuzione

Prima di eseguire realmente il futuro, il gioco deve riepilogare:

- punti Precog spesi;
- informazioni trasferite;
- direttive attive;
- ultimo esito previsto.

Il giocatore preme:

> **ACCETTA QUESTO FUTURO**

o equivalente.

---

# 46. Opzione importante: il futuro non deve essere garantito al 100%

Concettualmente il gioco deve parlare di previsione, non di certezza.

Tuttavia nel Livello 1 la variabilità deve essere molto contenuta.

Per il vertical slice:

- la proiezione deve essere altamente affidabile;
- l'esecuzione finale deve essere molto simile all'ultima previsione;
- eventuali differenze devono essere piccole e comprensibili.

Non introduciamo ancora:
- precog che mentono;
- visioni contraddittorie;
- probabilità fortemente divergenti;
- futuri multipli simultanei.

Sono ottime idee per il gioco completo, ma danneggerebbero la valutazione del loop base.

---

# 47. Progressione interna al livello

Il Livello 1 deve insegnare il sistema gradualmente.

## Momento 1
Il giocatore guarda senza modificare nulla.

Impara:
> le persone agiscono da sole.

## Momento 2
Vede un fallimento evidente.

Impara:
> il problema deriva da informazione mancante.

## Momento 3
Applica il primo segnale Precog.

Impara:
> posso modificare ciò che l'agente sa.

## Momento 4
Il primo problema viene risolto.

Impara:
> il futuro cambia davvero.

## Momento 5
Compare una conseguenza secondaria.

Impara:
> cambiare il futuro produce nuove catene causali.

## Momento 6
Deve scegliere come spendere le risorse residue.

Impara:
> non posso correggere tutto.

## Momento 7
Esegue.

Impara:
> prima prevedo, poi mi assumo il rischio.

---

# 48. Tutorial

Il tutorial deve essere incorporato nella missione.

Evitare muri di testo.

Messaggi brevi.

Esempio iniziale:

> **Non controlli direttamente gli agenti.**
> Osserva ciò che accadrà.

Pulsante evidenziato:

> **VEDI IL FUTURO**

Dopo il primo fallimento:

> **Le tue visioni possono essere trasformate in informazioni.**
> Torna al presente.

Poi:

> **Segnala ad Agente A la presenza di una minaccia nella stanza.**

Dopo la seconda proiezione:

> **Il futuro è cambiato. Osserva le nuove conseguenze.**

Dopodiché il tutorial deve lasciare libertà.

---

# 49. Leggibilità visiva degli agenti

Anche con grafica semplice devono essere distinguibili.

Necessario:
- silhouette diversa dai criminali;
- equipaggiamento riconoscibile;
- indicatori minimi;
- nome sopra l'unità solo quando utile;
- selezione chiara.

Non è necessario fotorealismo.

---

# 50. Animazioni essenziali

Per il feeling del prototipo servono animazioni leggibili.

Minimo:

### Movimento
- cammino;
- corsa breve;
- arresto.

### Attenzione
- guardare;
- controllare angolo;
- postura prudente.

### Porte
- apertura;
- ingresso.

### Combattimento
- mira;
- sparo;
- reazione al colpo;
- caduta/incapacitazione.

### Interazioni
- comunicazione radio;
- protezione civile;
- arresto/neutralizzazione semplificata.

La qualità delle animazioni conta molto per far percepire autonomia.

---

# 51. Audio

L'audio è parte della simulazione.

Servono:
- passi;
- porte;
- spari;
- radio;
- urla brevi;
- segnali di allerta;
- feedback Precog;
- transizione presente/futuro.

Il suono deve essere utile anche al giocatore per comprendere gli eventi.

---

# 52. Dialoghi contestuali

Brevi battute possono rendere l'informazione visibile.

Esempi:

Agente:
> “Movimento nella stanza.”

Criminale:
> “Polizia, ingresso ovest!”

Agente:
> “Aspetta. Possibile ostile.”

Criminale:
> “Marco? Rispondi.”

Queste frasi comunicano al giocatore che un personaggio ha acquisito una conoscenza.

---

# 53. Conoscenza mostrata visivamente

Quando un personaggio acquisisce un'informazione importante si può usare un feedback discreto.

Esempio:
- icona radio;
- breve testo;
- segnale sopra il personaggio;
- marker temporaneo.

Il feedback deve essere sufficiente a capire:

> “adesso lui lo sa.”

---

# 54. Informazione obsoleta

Una delle idee centrali è che le informazioni invecchiano.

Esempio:

Un criminale viene segnalato in una stanza.

L'agente sa:

> “Ostile visto in stanza 3.”

Non:

> “Ostile è eternamente nella stanza 3.”

Se il criminale si sposta, l'informazione resta utile ma non perfetta.

Per il Livello 1 questa dinamica deve comparire almeno una volta.

---

# 55. Catene causali da dimostrare

Il livello deve contenere almeno tre catene.

## Catena A — Informazione locale
Nemico nascosto → agente ignaro → imboscata.

## Catena B — Comunicazione
Criminale vede agente → radio → secondo criminale cambia comportamento.

## Catena C — Conseguenza indiretta
Cambio di tempistica → civile si trova in una posizione differente → nuovo rischio.

Se queste tre catene funzionano, il prototipo dimostra il potenziale del sistema.

---

# 56. Design della mappa per supportare le catene

La mappa deve essere costruita intorno agli eventi.

Non deve essere prima progettata come ambiente realistico e poi riempita.

Ogni stanza deve avere una funzione.

Esempio:

### Ingresso
Punto di partenza.

### Corridoio
Permette primo movimento e linea di vista.

### Stanza A
Contiene il primo criminale nascosto.

### Area centrale
Consente comunicazione e propagazione del conflitto.

### Stanza B
Contiene il civile.

### Uscita secondaria
Permette fuga o deviazione.

---

# 57. Evitare eccessiva grandezza

Per il primo livello:

- niente più piani;
- niente grandi esterni;
- niente 10 agenti;
- niente 20 stanze;
- niente veicoli;
- niente zone enormi.

La complessità deve venire dalle interazioni.

---

# 58. Durata desiderata

Prima partita completa:

**10–20 minuti.**

Un giocatore che conosce il livello:

**5–10 minuti.**

Una singola proiezione:

**30–60 secondi.**

Il livello deve invitare naturalmente a fare diverse proiezioni.

---

# 59. Numero ideale di proiezioni

Il primo giocatore dovrebbe arrivare a una soluzione soddisfacente dopo circa:

**3–6 proiezioni.**

Se ne bastano sempre 1–2:
il problema è troppo semplice.

Se ne servono 15:
la causalità è troppo difficile da leggere o il giocatore ha troppo poco potere.

---

# 60. Economia dei Punti Precog — prima proposta

Esempio da testare:

**Budget: 9 punti**

### Informazioni
- pericolo generico: 1
- presenza ostile: 2
- natura della minaccia: +1
- posizione molto precisa: +1
- indicazione temporale: +1

### Direttive
- prudente: 1
- furtivo: 1
- aggressivo: 1
- priorità obiettivo: 2

### Condivisione
- applicare la stessa informazione a entrambi: costo aggiuntivo.

Questi numeri NON sono definitivi.

Sono un punto di partenza per il test.

---

# 61. Regola di costo

Il costo deve seguire un principio intuitivo:

> **più informazione trasferisci dal futuro al presente, più costa.**

Non devono esistere prezzi arbitrari difficili da memorizzare.

---

# 62. Direttive persistenti

Una direttiva applicata nel presente resta valida per la proiezione.

Esempio:

> “Approccio prudente.”

Non deve richiedere microgestione durante l'azione.

Il giocatore può rimuoverla o cambiarla prima della proiezione successiva.

---

# 63. Informazioni geografiche

Per il Livello 1 il giocatore può applicare informazioni a:
- stanza;
- porta;
- zona;
- personaggio conosciuto.

Meglio evitare precisione centimetriche.

La selezione deve restare semantica.

---

# 64. Informazioni temporali

L'informazione temporale può essere una forma costosa di Precog.

Esempio:

> “Minaccia prevista in questa zona entro 10 secondi.”

Per il primo prototipo può essere opzionale.

Se introduce troppa complessità, può essere rimandata.

Il sistema base deve funzionare senza di essa.

---

# 65. Intervento aggressivo / prudente

Queste direttive non devono significare:

### Aggressivo
“corri e spara.”

Deve significare:
- maggiore disponibilità a prendere iniziativa;
- minore attesa;
- maggiore pressione sull'obiettivo.

### Prudente
Non deve significare:
“resta fermo.”

Deve significare:
- maggiore verifica;
- maggiore uso di copertura;
- maggiore attesa di informazioni o supporto.

---

# 66. Furtività

“Furtivo” significa:
- minimizzare esposizione;
- ridurre rumore;
- evitare contatti inutili;
- preferire approcci discreti.

Non deve essere sempre migliore.

Può essere più lento.

La lentezza può produrre conseguenze:
- civile si muove;
- criminale fugge;
- un'altra situazione evolve.

---

# 67. Nessuna direttiva è universalmente corretta

Questo è fondamentale.

Aggressivo non deve essere:
- sempre sbagliato.

Prudente non deve essere:
- sempre migliore.

Furtivo non deve essere:
- la soluzione perfetta.

Ogni atteggiamento deve modificare trade-off.

---

# 68. Il valore del tempo

La simulazione deve essere sensibile alle tempistiche.

Un cambiamento di pochi secondi può modificare:
- incontro tra personaggi;
- linea di vista;
- comunicazione radio;
- posizione del civile;
- opportunità di fuga.

Questa è una delle principali fonti di emergenza.

---

# 69. Il futuro deve poter peggiorare

Un intervento Precog non deve garantire un miglioramento.

Esempio:

> avvertire un agente del pericolo lo rende prudente.

Risultato:
- sopravvive;
- arriva più tardi;
- il criminale fugge.

Il giocatore deve imparare che sta modificando un sistema, non scegliendo bonus.

---

# 70. Il futuro deve poter migliorare in modi inattesi

Anche il contrario è importante.

Esempio:
- un agente rallenta;
- il criminale si sposta;
- perde la linea di vista;
- la radio non viene usata;
- il secondo criminale resta ignaro.

Il giocatore deve poter scoprire soluzioni emergenti.

---

# 71. Spiegazione degli eventi

Quando il giocatore seleziona un evento importante sulla timeline deve poter vedere una catena sintetica.

Esempio:

**Perché Criminale B è stato allertato?**

- +18.2 Criminale A ha visto Agente A
- +18.8 Criminale A ha usato la radio
- +19.1 Criminale B ha ricevuto “agente all'ingresso”
- +19.4 Criminale B è passato in stato di allerta

Questa funzione deve essere concettualmente semplice.

Non serve mostrare sistemi interni.

Serve mostrare causa → effetto.

---

# 72. La domanda “perché?”

Il prototipo deve essere testato continuamente con questa domanda:

> Se il giocatore chiede “perché ha fatto così?”, il gioco può rispondere in modo comprensibile?

Se no, il comportamento è troppo opaco.

---

# 73. La domanda “cosa posso cambiare?”

Dopo ogni fallimento il giocatore deve riuscire a identificare almeno una possibile leva.

Se osserva una scena e pensa:

> “Non avevo nessun modo di influenzare questa cosa.”

il design ha fallito.

Non significa che ogni problema debba essere evitabile.

Significa che le principali conseguenze del Livello 1 devono essere collegate alle leve Precog.

---

# 74. Il ruolo dell'incertezza

Nel Livello 1 l'incertezza deve derivare soprattutto da:
- conoscenza incompleta;
- catene causali;
- comportamento autonomo;
- informazioni che diventano obsolete.

NON da casualità pesante.

---

# 75. Condizione di “futuro leggibile”

Una proiezione è valida se un osservatore può raccontare in parole semplici cosa è successo.

Esempio:

> “L'agente è entrato senza sapere del nemico. Il nemico ha sparato. Il secondo agente ha reagito, ma il primo criminale ha avvisato il compagno, che ha preso il civile.”

Se per capire la scena servono grafici e log complessi, non è abbastanza leggibile.

---

# 76. Presentazione cinematica minima

Il gioco può usare:
- slow motion automatico per eventi critici;
- piccolo focus della telecamera;
- audio enfatizzato;
- marker temporaneo.

Ma deve evitare di interrompere continuamente il flusso.

La simulazione deve restare una scena continua.

---

# 77. Momenti critici automatici

Possibili eventi che possono generare un leggero rallentamento opzionale:
- primo contatto;
- agente colpito;
- civile scoperto;
- morte;
- criminale in fuga.

L'utente deve poter disattivare o ignorare il rallentamento.

---

# 78. Fine della proiezione

La proiezione termina quando:
- raggiunge l'orizzonte massimo;
- la missione è chiaramente risolta;
- la missione è chiaramente compromessa;
- il giocatore la interrompe.

Al termine si torna al presente.

---

# 79. Riepilogo dopo proiezione

Mostrare solo pochi elementi:

- agenti vivi/feriti;
- civile;
- criminali;
- evento principale;
- punti Precog attualmente allocati.

Esempio:

**ESITO PREVISTO**
- Agente A: morto
- Agente B: vivo
- Civile: ferito
- Criminale A: vivo
- Criminale B: fuggito

Pulsante:

> **TORNA AL PRESENTE**

---

# 80. Confronto con proiezione precedente

Funzione molto utile per il prototipo:

Mostrare cosa è cambiato.

Esempio:

### Proiezione precedente
Agente A morto a +15s

### Proiezione attuale
Agente A vivo

### Nuova conseguenza
Civile preso in ostaggio a +41s

Questo aiuta il giocatore a leggere la causalità.

---

# 81. Ghost del futuro precedente — opzionale

Possibile funzione futura:

durante una nuova proiezione si può visualizzare in modo discreto la posizione che un personaggio aveva nella previsione precedente.

Per il Livello 1 è **opzionale**.

Può essere utile, ma non è essenziale.

Non deve rallentare lo sviluppo del core.

---

# 82. Vittoria perfetta e vittoria accettabile

Il prototipo può distinguere:

## Vittoria
Obiettivo principale completato.

## Vittoria pulita
- tutti gli agenti vivi;
- civile salvo;
- nessuna fuga;
- danni minimi.

Questo incoraggia a iterare senza imporre una soluzione unica.

---

# 83. Punteggio

Non necessario nel Livello 1.

Se presente, deve essere secondario.

Il test deve concentrarsi sul piacere del loop, non sull'ottimizzazione di punti.

---

# 84. Replayability

Non è un requisito fondamentale del primo prototipo.

Il livello deve essere interessante almeno una volta.

È accettabile che, dopo aver trovato una soluzione, il giocatore conosca già gran parte della missione.

La replayability verrà affrontata successivamente.

---

# 85. Cosa deve imparare il tester

Alla fine del Livello 1 il tester deve poter spiegare spontaneamente:

1. non controllo gli agenti;
2. posso vedere il futuro;
3. gli agenti non conoscono ciò che io vedo;
4. posso trasferire loro alcune informazioni;
5. le informazioni costano;
6. gli agenti reagiscono autonomamente;
7. modificando una cosa posso cambiare molte conseguenze;
8. non posso correggere tutto;
9. quando sono soddisfatto confermo il futuro.

Se questi concetti non emergono senza una lunga spiegazione esterna, il prototipo non è ancora riuscito.

---

# 86. Cosa deve provare il tester

Idealmente deve dire almeno una frase simile a:

> “Aspetta, voglio provare a dirgli del secondo tizio.”

oppure:

> “Ah! È successo perché quello aveva usato la radio.”

oppure:

> “Se lo faccio andare più prudente però arriva tardi.”

oppure:

> “Fammi vedere un'altra volta.”

Questi sono segnali di successo del concept.

---

# 87. Segnali di fallimento del prototipo

Problemi gravi:

### “Perché non posso semplicemente muoverlo io?”
Il valore dell'autonomia non è percepito.

### “Non capisco cosa è cambiato.”
La causalità è poco leggibile.

### “Continuo a guardare la stessa animazione.”
Le proiezioni sono troppo lunghe o troppo simili.

### “Basta mettere prudente a tutti.”
Le direttive non hanno trade-off.

### “Non so perché è morto.”
Le informazioni/percezioni sono troppo opache.

### “Ho perso per caso.”
Troppa casualità.

### “Devo aprire troppi menu.”
UX troppo complessa.

### “Sembra XCOM senza poter comandare.”
Il precog non è abbastanza centrale.

---

# 88. Priorità di sviluppo del design

Ordine concettuale:

## Priorità 1
Guardare una simulazione 3D autonoma comprensibile.

## Priorità 2
Personaggi che possiedono informazioni separate.

## Priorità 3
Ritorno al presente e nuova proiezione.

## Priorità 4
Trasferimento di informazione Precog.

## Priorità 5
Costo delle informazioni.

## Priorità 6
Cambiamento causale leggibile.

## Priorità 7
UI di analisi.

## Priorità 8
Polish audiovisivo.

Tutto il resto è secondario.

---

# 89. Scope minimo assoluto

Se serve ridurre drasticamente il prototipo, il minimo è:

- 1 mappa;
- 2 agenti;
- 2 criminali;
- 1 civile;
- 1 obiettivo;
- 45 secondi di simulazione;
- presente;
- proiezione;
- ritorno;
- 3 tipi di intervento Precog;
- punti limitati;
- vista separata per personaggio;
- suono;
- comunicazione radio;
- combattimento;
- esecuzione finale.

Con questo deve già essere possibile giudicare il concept.

---

# 90. Funzioni importanti ma rimandabili

Non necessarie per il Livello 1:

- inventario;
- armi multiple;
- personalizzazione agenti;
- progressione;
- skill tree;
- più precog;
- probabilità visuali;
- visioni discordanti;
- false visioni;
- traumi;
- gestione organizzazione;
- interrogatori;
- mappa strategica;
- campagna;
- dialoghi ramificati;
- metagioco politico;
- reputazione;
- economia;
- multiplayer;
- proceduralità;
- meteo;
- notte/giorno;
- distruzione avanzata;
- decine di civili;
- grandi squadre;
- veicoli;
- verticalità complessa.

---

# 91. Idee esplicitamente FUORI SCOPE per ora

Anche se interessanti:

## Precog multipli
Due visioni differenti dello stesso futuro.

## Affidabilità percentuale
“83% probabilità”.

## Futuri alternativi simultanei
Tre timeline parallele.

## Paradossi narrativi
Il soggetto reagisce alla previsione.

## Nemici precog
Avversari che prevedono il giocatore.

## Alterazione mentale
Uso del Precog che danneggia il protagonista.

## Informazione falsa
Visioni corrotte.

## Memoria del futuro da parte degli agenti
Da valutare solo in seguito.

Il Livello 1 deve restare puro.

---

# 92. Direzione grafica

La grafica può essere minimale.

Obiettivo:
**leggibilità > dettaglio.**

Possibile stile:
- 3D low-poly pulito;
- geometrie semplici;
- palette controllata;
- personaggi riconoscibili;
- luci che aiutano la lettura;
- effetti Precog distintivi.

Il prototipo non deve sembrare un editor tecnico.

Deve già avere un'identità minima.

---

# 93. Interfaccia diegetica vs HUD

Per il Livello 1 conviene privilegiare un HUD chiaro.

Non serve rendere tutto diegetico.

L'obiettivo è testare la meccanica.

In futuro l'interfaccia potrà essere tematizzata come:
- sistema Precrime;
- sala operativa;
- interfaccia neurologica;
- archivio predittivo.

---

# 94. Nome delle due modalità

Devono essere nominati sempre nello stesso modo.

Proposta:

## PRESENTE

## PROIEZIONE

E per la fase finale:

## ESECUZIONE

Tre parole semplici.

---

# 95. Linguaggio del Precog

Le informazioni devono essere formulate come conoscenza, non come comandi.

Meglio:

> **OSTILE PREVISTO — STANZA 3**

che:

> **ENTRA PRONTO A SPARARE**

Meglio:

> **RISCHIO ELEVATO — ACCESSO EST**

che:

> **NON PASSARE DALL'ACCESSO EST**

Questo principio deve guidare tutta la UI.

---

# 96. Lessico degli ordini generici

Possibili categorie finali per il Livello 1:

### Informazioni
- Pericolo
- Ostile
- Ostile armato
- Posizione prevista
- Possibile fuga

### Approccio
- Prudente
- Furtivo
- Deciso

### Priorità
- Proteggi
- Contieni
- Mantieni contatto

Non serve implementarle tutte se il prototipo diventa troppo ampio.

---

# 97. Regola sulle priorità

Le priorità devono entrare in conflitto.

Esempio:

Agente deve:
- proteggere civile;
- fermare criminale in fuga.

Se il giocatore assegna:

> **PRIORITÀ: CIVILE**

l'agente potrebbe rinunciare all'inseguimento.

Questo produce trade-off.

---

# 98. Comunicazione degli agenti

Gli agenti devono poter parlarsi.

Esempio:
- avvisare di un contatto;
- dichiarare movimento;
- chiedere copertura;
- segnalare civile.

Non serve un sistema di comando del giocatore.

Serve a mostrare che la squadra costruisce autonomamente conoscenza condivisa.

---

# 99. Differenza tra Precog e radio

Questa distinzione deve essere chiara.

## Radio
Comunica qualcosa che qualcuno sa nel presente.

## Precog
Comunica qualcosa che il giocatore ha visto nel futuro.

Il Precog è quindi una fonte informativa impossibile.

---

# 100. La regola filosofica del gioco

Il gioco ruota attorno a una contraddizione:

> **Il futuro è utile proprio perché può essere cambiato.**

Una previsione corretta smette di essere corretta quando il giocatore interviene.

Il Livello 1 deve già far vivere questa idea.

---

# 101. Il momento ideale del prototipo

La scena che deve vendere il gioco è:

### Visione 1
Agente apre porta.
Nemico spara.
Agente cade.

### Presente
Il giocatore applica:
> **OSTILE ARMATO — DIETRO LA PORTA**

### Visione 2
Agente arriva.
Rallenta.
Controlla.
Il compagno lo raggiunge.
Affrontano la stanza.
Sopravvive.

### Poi
Un evento successivo cambia.

Questo deve essere il “GIF moment” del gioco.

---

# 102. Requisiti di leggibilità della scena

Ogni evento importante deve essere distinguibile senza HUD complesso.

Il tester deve vedere:
- chi ha sparato;
- chi è stato visto;
- da dove arriva il pericolo;
- chi sta comunicando;
- chi è ferito;
- chi è allertato.

---

# 103. Feedback quando il Precog ha avuto effetto

Quando una direttiva precog modifica chiaramente una decisione, il gioco può segnalarlo discretamente.

Esempio:

> **PRECISIONE PRECOG UTILIZZATA**
> Agente A ha evitato ingresso immediato.

Non deve apparire per ogni microdecisione.

Solo per rendere evidente il legame tra intervento e risultato.

---

# 104. Nessun “+20%”

Per il Livello 1 evitare bonus astratti come:

- +20% mira;
- +15% copertura;
- +10% furtività.

Le direttive devono modificare comportamenti percepibili.

---

# 105. Nessun menu RPG

Non sono richiesti:
- forza;
- destrezza;
- intelligenza;
- precisione;
- morale numerico;
- inventario dettagliato.

Se servono differenze tra agenti, devono essere espresse in maniera qualitativa.

---

# 106. Stato emotivo

Stress e paura possono esistere in futuro.

Per il Livello 1 sono opzionali.

Se inseriti, devono servire solo a spiegare comportamenti evidenti.

Non devono diventare un secondo sistema da gestire.

---

# 107. Arresto vs uccisione

Il prototipo deve possibilmente permettere che un criminale venga:
- arrestato;
- incapacitato;
- ucciso.

Non è necessario un sistema morale complesso.

Ma “neutralizzare” non deve significare automaticamente “uccidere”.

---

# 108. Abilità operative

Il giocatore aveva proposto di vedere agenti usare autonomamente abilità.

Questa idea è valida.

Per il Livello 1 è consigliata **una sola abilità speciale automatica**.

Esempio:
- flashbang;
- sfondamento;
- copertura del compagno.

Il giocatore non deve comandare quando usarla.

L'agente la usa se:
- la possiede;
- ritiene la situazione appropriata;
- le informazioni ricevute la rendono sensata.

Questo è importante perché mostra:

> il giocatore informa, l'agente decide come agire.

---

# 109. Esempio con abilità

Agente sa solo:

> “Pericolo nella stanza.”

Può controllare lentamente.

Se sa:

> “Ostile armato dietro la porta.”

può scegliere autonomamente di usare una flashbang.

Il giocatore vede quindi un cambiamento qualitativo senza aver ordinato:

> “usa flashbang.”

---

# 110. Limite alle abilità

Per il Livello 1:
- massimo 1–2 abilità per agente;
- niente alberi;
- niente cooldown complessi;
- niente barra abilità controllata dal giocatore.

---

# 111. Gestione della morte

La morte nella proiezione deve avere peso visivo ma non interrompere necessariamente la simulazione.

È importante vedere cosa succede **dopo**.

Esempio:
- un agente muore;
- il compagno reagisce;
- un criminale fugge;
- il civile si sposta.

Il futuro deve continuare abbastanza da mostrare le conseguenze.

---

# 112. Gestione del tempo dopo eventi critici

Dopo una morte il gioco non deve immediatamente mostrare “MISSION FAILED”.

Nella proiezione deve continuare, se possibile.

Il giocatore ha bisogno di vedere la catena completa.

---

# 113. Fine anticipata della proiezione

Se tutti gli agenti sono morti e non resta nessuna evoluzione significativa, la simulazione può terminare.

---

# 114. Uso del colore

Senza imporre una palette definitiva:

- agenti devono essere chiaramente riconoscibili;
- criminali distinti;
- civile distinto;
- informazioni Precog avere linguaggio visivo unico;
- presente e proiezione avere trattamento diverso.

---

# 115. Identità visiva del Precog

Il Precog deve sembrare:
- informazione proveniente da un futuro instabile;
- non magia fantasy;
- non semplice overlay militare.

Possibili sensazioni:
- immagini residue;
- eco temporale;
- distorsione;
- duplicazione;
- interferenza;
- segnali frammentati.

Per il prototipo basta una versione semplice.

---

# 116. Audio del passaggio temporale

Entrare in proiezione deve essere un momento riconoscibile.

Esempio:
- rumore ambientale che si deforma;
- impulso;
- ritorno improvviso del suono;
- voce/tono dell'interfaccia.

Tornare al presente deve essere altrettanto chiaro.

---

# 117. Salvataggio dello stato

Dal punto di vista del game design, il presente è l'ancora.

Ogni proiezione deve ripartire da quel punto.

Il giocatore deve percepire:

> “questo è il momento che posso ancora cambiare.”

---

# 118. Nessun intervento nel mezzo del futuro

Questa è una regola dura.

Durante la proiezione:
- non si aggiungono direttive;
- non si spostano priorità;
- non si comunica agli agenti.

Per intervenire:

> **TORNA AL PRESENTE**

Questo rafforza il concetto di causalità.

---

# 119. Perché non intervenire durante la proiezione

Se il giocatore potesse farlo, il gioco diventerebbe:
- tattico in tempo reale;
- microgestione;
- correzione reattiva.

Il Precog smetterebbe di essere previsione.

---

# 120. Numero di agenti nel futuro

Anche se il gioco completo potrà avere squadre maggiori, due agenti sono ideali per il test.

Permettono:
- coordinamento;
- informazione diversa;
- personalità diversa;
- conseguenze di una morte;
- comunicazione.

Senza introdurre caos.

---

# 121. Numero di nemici

Due criminali consentono già:
- informazione locale;
- comunicazione;
- movimento;
- reazioni indirette.

Tre possono essere testati successivamente.

---

# 122. Possibili finali del livello

Esempi:

## Finale A — perfetto
Tutti vivi, criminali arrestati.

## Finale B — successo costoso
Civile vivo, un agente ferito.

## Finale C — successo parziale
Civile vivo, un criminale fugge.

## Finale D — fallimento
Civile morto.

## Finale E — fallimento
Squadra incapacitata.

Questa varietà aiuta a mostrare che il futuro non è binario.

---

# 123. Debrief

Dopo l'esecuzione reale:

Mostrare:
- risultato;
- perdite;
- criminali;
- civile;
- numero di proiezioni;
- punti precog utilizzati;
- timeline finale.

Non serve scoring complesso.

---

# 124. Possibile frase finale del tutorial

> **Hai visto un futuro.**
> **Hai cambiato ciò che gli agenti sapevano.**
> **Il mondo ha fatto il resto.**

Questa frase riassume il gioco.

---

# 125. Checklist funzionale di Game Design

Il Livello 1 è completo quando consente:

## Mondo
- [ ] piccola mappa 3D leggibile
- [ ] porte
- [ ] ostacoli alla vista
- [ ] due percorsi
- [ ] coperture

## Personaggi
- [ ] 2 agenti
- [ ] 2 criminali
- [ ] 1 civile
- [ ] movimento autonomo
- [ ] combattimento
- [ ] percezione visiva
- [ ] percezione sonora
- [ ] memoria di informazioni
- [ ] comunicazione

## Precog
- [ ] presente statico
- [ ] avvio proiezione
- [ ] orizzonte temporale
- [ ] ritorno al presente
- [ ] riesecuzione
- [ ] punti Precog
- [ ] almeno 3 interventi
- [ ] applicazione per agente
- [ ] modifica percepibile del comportamento

## Analisi
- [ ] timeline
- [ ] pausa
- [ ] replay
- [ ] selezione personaggio
- [ ] informazioni conosciute
- [ ] spiegazione decisione corrente
- [ ] eventi importanti

## Missione
- [ ] obiettivo chiaro
- [ ] successo
- [ ] fallimento
- [ ] esecuzione finale
- [ ] debrief

---

# 126. Checklist di esperienza

Il Livello 1 NON è considerato riuscito finché:

- [ ] il giocatore capisce che non controlla gli agenti;
- [ ] il giocatore capisce che gli agenti hanno conoscenza limitata;
- [ ] il primo futuro contiene almeno un fallimento chiaramente prevenibile;
- [ ] una singola informazione precog cambia visibilmente la scena;
- [ ] il cambiamento produce almeno una conseguenza secondaria;
- [ ] il giocatore deve scegliere come spendere risorse limitate;
- [ ] il giocatore può capire perché un agente ha preso una decisione;
- [ ] una previsione completa richiede meno di un minuto;
- [ ] il giocatore desidera spontaneamente riprovare;
- [ ] l'esecuzione finale produce tensione.

---

# 127. Test specifici da fare

## Test 1 — Nessun intervento
Avviare tre volte la stessa proiezione.

Domanda:
> il futuro è sufficientemente coerente?

---

## Test 2 — Informazione singola
Aggiungere solo:

> “Ostile nella stanza.”

Domanda:
> il cambiamento è evidente?

---

## Test 3 — Informazione diversa per agente
Informare A ma non B.

Domanda:
> si percepisce che i due possiedono conoscenze differenti?

---

## Test 4 — Radio
Far vedere un agente a Criminale A.

Domanda:
> il giocatore capisce che B viene allertato perché ha ricevuto una comunicazione?

---

## Test 5 — Informazione obsoleta
Segnalare un criminale in una stanza, poi farlo spostare.

Domanda:
> l'agente tratta l'informazione come conoscenza passata e non come posizione magica permanente?

---

## Test 6 — Direttiva prudente
Applicarla.

Domanda:
> modifica il comportamento senza trasformarlo in immobilità?

---

## Test 7 — Direttiva aggressiva
Applicarla.

Domanda:
> crea vantaggi e rischi reali?

---

## Test 8 — Conseguenza indiretta
Salvare un agente modificando il timing.

Domanda:
> emerge una nuova conseguenza altrove?

---

## Test 9 — Spiegabilità
Chiedere al tester:

> “Perché l'agente ha aspettato?”

Deve poterlo capire dall'interfaccia.

---

## Test 10 — Comprensione senza spiegazione
Far provare il livello a qualcuno con tutorial minimo.

Domanda:
> capisce il loop entro 5 minuti?

---

# 128. Metriche qualitative del playtest

Chiedere:

1. Qual è secondo te il tuo ruolo?
2. Cosa puoi controllare?
3. Perché è morto l'agente nella prima previsione?
4. Cosa hai modificato?
5. Perché il secondo futuro è cambiato?
6. Ti è sembrato che gli agenti sapessero cose che non dovevano sapere?
7. Hai mai pensato che un comportamento fosse casuale o stupido?
8. Ti è venuta voglia di guardare un'altra previsione?
9. Hai trovato interessante il limite dei punti?
10. Preferiresti controllare direttamente gli agenti? Perché?
11. Qual è stato il momento più soddisfacente?
12. Qual è stato il momento più confuso?

---

# 129. Criterio principale di successo del playtest

Il dato più importante non è:

> “Hai vinto?”

È:

> **“Dopo aver visto il primo futuro, hai avuto immediatamente un'idea su cosa provare a cambiare?”**

Se sì, il loop funziona.

---

# 130. Secondo criterio di successo

> **“Dopo aver cambiato qualcosa, eri curioso di vedere come il nuovo futuro sarebbe andato?”**

Se sì, il gioco genera iterazione spontanea.

---

# 131. Terzo criterio di successo

> **“Quando il futuro è cambiato, hai capito almeno in parte perché?”**

Se sì, la simulazione è leggibile.

---

# 132. Quarto criterio di successo

> **“Hai sentito che le persone stavano agendo da sole invece di aspettare i tuoi ordini?”**

Se sì, l'autonomia è percepita.

---

# 133. Possibile struttura della prima missione definitiva

## Scenario
Rapina/ostaggio in piccolo edificio.

## Agenti
- Vega: prudente
- Cole: deciso

## Criminali
- Rook: vicino all'ingresso interno
- Mason: vicino al civile

## Civile
- impiegato bloccato in ufficio

## Futuro iniziale
- Vega entra;
- non vede Rook;
- Rook apre il fuoco;
- Cole reagisce;
- Rook comunica;
- Mason si sposta;
- civile tenta di scappare;
- situazione degenera.

## Leve Precog
- informare Vega;
- informare Cole;
- priorità civile;
- approccio furtivo;
- posizione di Mason;
- possibile fuga.

## Budget
9 punti.

Obiettivo:
costringere il giocatore a scegliere.

---

# 134. Variante per rendere il livello più interessante senza aggiungere sistemi

Una singola porta laterale può produrre due percorsi.

Un agente prudente, avvertito del pericolo, può scegliere l'accesso alternativo.

Questo:
- cambia il tempo;
- cambia la linea di vista;
- può evitare l'allarme;
- può portarlo vicino al civile;
- può lasciare scoperto il compagno.

Una sola scelta autonoma può generare molta profondità.

---

# 135. Il ruolo della geometria

La geometria della mappa deve permettere:
- visione;
- occultamento;
- suono;
- percorsi alternativi;
- incroci temporali.

Non serve complessità architettonica.

---

# 136. Evitare corridoi lineari

Se la mappa ha un solo percorso:
- il precog modifica solo la velocità;
- le possibilità emergenti diminuiscono.

Servono almeno due possibilità sensate in alcuni punti.

---

# 137. Evitare open space eccessivi

Se tutti vedono tutti:
- la conoscenza individuale perde importanza;
- la radio perde importanza;
- le porte perdono importanza.

Il livello deve avere compartimentazione.

---

# 138. Il ruolo della sorpresa

Il primo futuro deve sorprendere il giocatore almeno una volta.

Ma la sorpresa deve essere, retrospettivamente, comprensibile.

> “Non poteva saperlo.”

È una buona sorpresa.

> “Perché è successo a caso?”

È una cattiva sorpresa.

---

# 139. La prima previsione non deve essere perfetta

È consigliato costruire l'inizio in modo che il futuro base fallisca o sia chiaramente mediocre.

Altrimenti il giocatore non ha motivo di usare il Precog.

---

# 140. Non rendere il fallimento troppo artificiale

Gli agenti non devono morire perché sceneggiati come idioti.

Il fallimento deve derivare da:
- mancanza di informazione;
- timing;
- geometria;
- sorpresa;
- conflitto di priorità.

---

# 141. Limite della conoscenza iniziale degli agenti

All'inizio sanno:
- obiettivo;
- planimetria generale, se appropriato;
- che può esserci una minaccia.

Non sanno:
- posizione precisa dei criminali;
- azioni future;
- eventi nascosti.

---

# 142. Limite della conoscenza iniziale dei criminali

Sanno:
- dove sono i propri compagni all'inizio;
- il proprio obiettivo;
- la zona.

Non sanno:
- posizione degli agenti;
- loro percorso futuro;
- che il giocatore li osserva.

---

# 143. Conoscenza dei compagni

Sapere dove un compagno era inizialmente non equivale a tracking permanente.

Se non c'è contatto:
- la posizione diventa vecchia;
- la morte può non essere conosciuta;
- il silenzio radio può generare sospetto.

Questo elemento può essere semplice nel Livello 1, ma deve rispettare il principio.

---

# 144. Unità indipendenti

Ogni personaggio deve apparire come una piccola entità autonoma.

La scena ideale non deve sembrare:

> una AI centrale sta muovendo tutti.

Deve sembrare:

> ognuno sta reagendo a ciò che sa.

Questo è uno dei tratti identitari del progetto.

---

# 145. Decisioni locali, conseguenze globali

Il gioco deve valorizzare il fatto che:

> una decisione locale di un singolo individuo può cambiare l'intera scena.

Esempio:
- criminale decide di usare radio;
- secondo criminale cambia posizione;
- civile reagisce;
- agente incontra qualcuno in un momento diverso.

---

# 146. L'agente non è un avatar

Nessuna camera obbligatoria in prima persona.

Nessun controllo WASD.

Nessuna possessione.

Il giocatore è sempre esterno.

---

# 147. Il criminale non è un bersaglio statico

Deve poter:
- reagire;
- spostarsi;
- comunicare;
- fuggire.

Altrimenti la previsione diventa memorizzazione di posizioni.

---

# 148. Il livello non è un puzzle di coordinate

La soluzione non deve essere:

> “metti segnale qui, qui e qui.”

Deve essere più vicina a:

> “cosa è importante che queste persone sappiano?”

---

# 149. Domanda progettuale per ogni nuova meccanica

Prima di aggiungere qualsiasi feature chiedere:

> **Rende più interessante il rapporto tra futuro, informazione e autonomia?**

Se no:
rimandarla.

---

# 150. Domanda progettuale per ogni ordine

Prima di aggiungere una direttiva chiedere:

> **Sto comunicando conoscenza/intento, o sto controllando direttamente un'azione?**

Se è la seconda:
non inserirla.

---

# 151. Domanda progettuale per ogni evento

> **Il giocatore può capirne la causa?**

Se no:
semplificare.

---

# 152. Domanda progettuale per ogni casualità

> **Questa casualità rende il futuro interessante o rende inutile prevederlo?**

Se rende inutile prevederlo:
rimuoverla.

---

# 153. Obiettivo del vertical slice

Il prototipo è pronto a evolvere quando riesce a produrre consistentemente questa esperienza:

1. guardo;
2. capisco;
3. ipotizzo;
4. comunico;
5. riguardo;
6. vedo una conseguenza;
7. rivaluto;
8. scelgo;
9. eseguo.

Questi nove verbi rappresentano il gioco.

---

# 154. Definizione sintetica finale

> **PRECOG è un gioco di simulazione tattica indiretta in cui il giocatore osserva brevi proiezioni del futuro e usa una risorsa limitata per trasferire informazioni, priorità e atteggiamenti agli agenti nel presente. Gli agenti e gli avversari agiscono autonomamente sulla base di ciò che percepiscono e conoscono. Ogni nuova informazione modifica le loro decisioni e, di conseguenza, la catena degli eventi. Il giocatore non cerca di comandare il futuro: cerca di influenzarlo abbastanza da renderlo accettabile.**

---

# 155. Regola d'oro

Durante tutto lo sviluppo del Livello 1 mantenere questa frase visibile:

> **IL GIOCATORE NON MUOVE LE PERSONE. MUOVE L'INFORMAZIONE.**

Se il prototipo riesce a rendere divertente questa frase, abbiamo il gioco.
