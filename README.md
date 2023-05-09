\[ Stefano Pigozzi | Grafo "creato da zero" | Tema Graph Analytics | Big Data Analytics | A.A. 2022/2023 | Unimore \]

# Analisi su grafo Neo4J relativo alle dipendenze delle crates del linguaggio Rust

> ### Graph analytics
>
> Obiettivo dell’attività è analizzare il data graph di una Sandbox di Neo4j (esclusa quella vista a lezione) attraverso la definizione di almeno due research question che possano essere risolte attraverso le tecniche di graph analytics viste a lezione.
>
> L’attività consisterà nello studio delle research question attraverso la progettazione, l’implementazione e l’esecuzione di almeno 4 tecniche distinte e una loro interpretazione nel contesto della Sandbox scelta.
>
> Alcune precisazioni riguardo l’attività richiesta:
>
> * Le Sandbox di Neo4J che possono essere usate a questo scopo sono quelle che hanno installato la Graph Data Science (GDS) Library.
> * L’attività di progettazione consisterà
> 	1. nella definizione delle proiezioni che saranno memorizzate in named graph, Almeno una proiezione dovrà essere una Cypher Projection;
> 	2. nella scelta degli algoritmi. In questa fase, si farà uso delle funzioni di memory estimation.
>
> * Le tecniche potranno essere implementate sia usando gli algoritmi di GDS messi a disposizione da Neo4J sia attraverso l’esecuzione di query Cypher. Le tecniche implementate non dovranno essere già presenti nella Sandbox.
>
> Il risultato dell’attività sarà un documento contenente
>
> * una breve descrizione della Sandbox scelta, dello schema del grafo analizzato e delle principali caratteristiche;
> * una descrizione delle research question e della soluzione proposta inclusa la progettazione delle tecniche proposte che dovrà essere adeguatamente giustificata;
> * il codice delle query eseguite sulla Sandbox, i risultati ottenuti e l’interpretazione dei risultati ottenuti che rappresenteranno le risposte alle research question.
>
> Le attività verranno valutate sulla base dei seguenti criteri:
>
> * storytelling: la Sandbox è ben descritta? le research question proposte sono adeguate alle caratteristiche del grafo analizzato?
> * progettazione della graph analytics e analisi dei risultati:
> * Le proiezioni e gli algoritmi individuati sono adeguati in termini di correttezza e completezza a rispondere alle research question?
> * L’interpretazione dei risultati risponde alle research quesion?
> * complessità dell’implementazione
>
> #### Corrispondenza
>
> > \[...\] Ho installato la Graph Data Science library sul grafo che ho realizzato per la precedente attività, ed adesso sarei interessato a svolgere l'attività di Graph Analytics su di esso.
> >
> > È un'opzione prevista dalla consegna, oppure non è consentita?
>
> > Si è consentita ma la dimensione del grafo deve essere sufficiente per fare Graph Analytics. 

## Sinossi

Si sono effettuate ricerche di Graph Analytics sul database a grafo dell'indice [Crates.io], realizzato per il progetto a tema Neo4J, determinando le crate più importanti all'ecosistema attraverso gli algoritmi di *Degree Centrality*, *Betweenness Centrality*, e *PageRank*, e ricercando cluster di tag per migliorare la classificazione delle crate nell'indice attraverso gli algoritmi di *Louvain*, *Label Propagation*, e *Leiden*.

## Introduzione

> Per informazioni su cosa è una crate in Rust, come è formata, o come è stato costruito il dataset utilizzato, si veda l'[introduzione della relazione del progetto a tema Neo4J].

All'interno di questa relazione si esplorano due diverse *research questions*, marcate rispettivamente con i simboli 1️⃣ e 2️⃣.

### 1️⃣ Quali sono le crates più importanti dell'ecosistema Rust?

Un'informazione utile da sapere per gli sviluppatori del linguaggio Rust e per i manutentori dell'indice [Crates.io] sono i nomi delle crate più importanti nell'indice.

Alcuni esempi di casi in cui il dato di importanza delle crate potrebbe essere utile sono:
- selezionare anticipatamente le crate su cui effettuare caching più aggressivo
- determinare le crate più a rischio di supply chain attack
- prioritizzare determinate crate nell'esecuzione di esperimenti con [crater]

Lo scopo di questa ricerca è quello di determinare, attraverso indagini sulla rete di dipendenze, un valore di importanza per ciascuna crate, e una classifica delle 25 crate più importanti dell'indice.

### 2️⃣ Quali potrebbero essere altre *categories* utilizzabili per classificare crate?

Affinchè le crate pubblicate possano essere utilizzate, non è sufficiente che esse vengano indicizzate: è necessario anche che gli sviluppatori che potrebbero farne uso vengano al corrente della loro esistenza.

Nasce così il problema della *discoverability*, ovvero di rendere più facile possibile per gli sviluppatori le migliori crate con le funzionalità a loro necessarie.

A tale fine, [Crates.io] permette agli autori di ciascuna crate di specificare fino a 5 *keyword* (brevi stringhe arbitrarie alfanumeriche, come `logging` o `serialization`) per essa, attraverso le quali è possibile trovare la crate tramite funzionalità di ricerca del sito, e fino a 5 *category* (chiavi predefinite in un apposito [thesaurus], come `Aerospace :: Unmanned aerial vehicles`), che inseriscono la crate in raccolte tematiche sfogliabili.

Lo scopo di questa ricerca è quello di determinare, attraverso indagini sulle *keyword*, nuove possibili *category* da eventualmente introdurre nell'indice, ed eventualmente sperimentare un metodo innovativo per effettuare classificazione automatica delle crate.

## Struttura del progetto

Il progetto è organizzato nelle seguenti directory:

- `README.md`: questo stesso file
- `scripts/`: le query presenti in questa relazione come file separati, per una più facile esecuzione

## Prerequisiti

Si è scelto di utilizzare un clone del DBMS Neo4J gestito da Neo4J Desktop del progetto precedente.

### Neo4J Desktop (1.5.7)

Per effettuare il clone del DBMS, è stato sufficiente aprire il menu <kbd>···</kbd> del DBMS originale e cliccare l'opzione <kbd>Clone</kbd> presente al suo interno.

### Graph Data Science Library (2.3.3)

Per installare la [Graph Data Science Library], si è cliccato sul nome del database clonato, si ha selezionato la scheda <kbd>Plugins</kbd>, aperto la sezione <kbd>Graph Data Science Library</kbd>, e infine premuto su <kbd>Install</kbd>.

## Concetti

### Graph Catalog

La [Graph Data Science Library] non è in grado di operare direttamente sul grafo, ma opera su delle proiezioni di parti di esso immagazzinate effimeramente all'interno di uno storage denominato [Graph Catalog], al fine di permettere agli algoritmi di operare con maggiore efficienza su un sottoinsieme mirato di elementi del grafo.

Esistono vari modi per creare nuove proiezioni, ma all'interno di questa relazione ci si concentra su due di essi, ovvero le funzioni Cypher:
- [`gds.graph.project.cypher`] (anche detta Cypher projection), che crea una proiezione a partire da due query Cypher, suggerita per il solo utilizzo in fase di sviluppo in quanto relativamente lenta
- [`gds.graph.project`] (anche detta native projection), che crea una proiezione a partire dai label di nodi ed archi, operando direttamente sui dati grezzi del DBMS, ottenendo così un'efficienza significativamente maggiore e offrendo alcune funzionalità aggiuntive

Il Graph Catalog viene svuotato ad ogni nuovo avvio del DBMS Neo4J; si richiede pertanto di fare attenzione a non interrompere il processo del DBMS tra la creazione di una proiezione e l'esecuzione di un algoritmo su di essa.

## Analisi

### 1️⃣ Realizzazione della *Graph Projection*

Si utilizza un approccio bottom-up per la costruzione della graph projection delle crate e delle loro dipendenze.

#### Determinazione dei nodi partecipanti

Si usa la seguente query triviale per determinare i codici identificativi dei nodi che partecipano all'algoritmo:

```cypher
MATCH (a:Crate)
RETURN id(a) AS id
```

```text
╒═══╕
│id │
╞═══╡
│0  │
├───┤
│1  │
├───┤
│2  │
├───┤
```

#### Determinazione degli archi partecipanti

Si costruisce invece una query più avanzata per interconnettere all'interno della proiezione i nodi in base alle dipendenze della loro versione più recente:

```cypher
// Trova tutte le versioni delle crate
MATCH (a:Crate)-[:HAS_VERSION]->(v:Version)
// Metti in ordine le versioni utilizzando l'ordine lessicografico inverso, che corrisponde all'ordine del versionamento semantico (semver) dalla versione più recente alla più vecchia
WITH a, v ORDER BY v.name DESC
// Per ogni crate, crea una lista ordinata contenente tutti i nomi delle relative versioni, ed estraine il primo, ottenendo così il nome della versione più recente
WITH a, collect(v.name)[0] AS vn
// Utilizzando il nome trovato, determina il nodo :Version corrispondente ad essa, e le crate che la contengono
MATCH (a:Crate)-[:HAS_VERSION]->(v:Version {name: vn})-[:DEPENDS_ON]->(c:Crate)
// Restituisci gli id dei nodi sorgente e destinazione
RETURN id(a) AS source, id(c) AS target
```

```text
╒══════╤══════╕
│source│target│
╞══════╪══════╡
│98825 │21067 │
├──────┼──────┤
│98825 │16957 │
├──────┼──────┤
│22273 │21318 │
├──────┼──────┤
```

#### Creazione della graph projection

Si combinano le due precedenti query in una chiamata a [`gds.graph.project.cypher`]:

```cypher
CALL gds.graph.project.cypher(
	"deps",
	"MATCH (a:Crate) RETURN id(a) AS id",
	"MATCH (a:Crate)-[:HAS_VERSION]->(v:Version) WITH a, v ORDER BY v.name DESC WITH a, collect(v.name)[0] AS vn MATCH (a:Crate)-[:HAS_VERSION]->(v:Version {name: vn})-[:DEPENDS_ON]->(c:Crate) RETURN id(a) AS source, id(c) AS target"
) YIELD
	graphName,
	nodeQuery,
	nodeCount,
	relationshipQuery,
	relationshipCount,
	projectMillis
```

```text
╒═════════╤═════════════════════════╤═════════╤═════════════════════════╤═════════════════╤═════════════╕
│graphName│nodeQuery                │nodeCount│relationshipQuery        │relationshipCount│projectMillis│
╞═════════╪═════════════════════════╪═════════╪═════════════════════════╪═════════════════╪═════════════╡
│"deps"   │"MATCH (a:Crate) RETURN i│105287   │"MATCH (a:Crate)-[:HAS_VE│537154           │8272         │
│         │d(a) AS id"              │         │RSION]->(v:Version) WITH │                 │             │
│         │                         │         │a, v ORDER BY v.name DESC│                 │             │
│         │                         │         │ WITH a, collect(v.name)[│                 │             │
│         │                         │         │0] AS vn MATCH (a:Crate)-│                 │             │
│         │                         │         │[:HAS_VERSION]->(v:Versio│                 │             │
│         │                         │         │n {name: vn})-[:DEPENDS_O│                 │             │
│         │                         │         │N]->(c:Crate) RETURN id(a│                 │             │
│         │                         │         │) AS source, id(c) AS tar│                 │             │
│         │                         │         │get"                     │                 │             │
└─────────┴─────────────────────────┴─────────┴─────────────────────────┴─────────────────┴─────────────┘
```


<!-- Collegamenti -->

[Crates.io]: https://crates.io/
[introduzione della relazione del progetto a tema Neo4J]: https://github.com/Steffo99/unimore-bda-4#introduzione
[thesaurus]: https://github.com/rust-lang/crates.io/blob/master/src/boot/categories.toml
[crater]: https://github.com/rust-lang/crater
[Graph Data Science Library]: https://neo4j.com/docs/graph-data-science/current/
[Graph Catalog]: https://neo4j.com/docs/graph-data-science/current/management-ops/graph-catalog-ops/
[`gds.graph.project.cypher`]: https://neo4j.com/docs/graph-data-science/current/management-ops/projections/graph-project-cypher/
[`gds.graph.project`]: https://neo4j.com/docs/graph-data-science/current/management-ops/projections/graph-project/