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

Si sono effettuate ricerche di Graph Analytics sul database a grafo dell'indice [Crates.io], realizzato per il progetto a tema Neo4J, determinando le crate più importanti all'ecosistema attraverso gli algoritmi di *Degree Centrality*, *Betweenness Centrality*, e *PageRank*, e ricercando community di tag per migliorare la classificazione delle crate nell'indice attraverso gli algoritmi di *Louvain*, *Label Propagation*, e *Leiden*.

## Introduzione

> Per informazioni su cosa è una crate in Rust, come è formata, o come è stato costruito il dataset utilizzato, si veda l'[introduzione della relazione del progetto a tema Neo4J].

All'interno di questa relazione si esplorano due diverse *research questions*, marcate rispettivamente con i simboli 1️⃣ e 2️⃣.

### 1️⃣ Quali sono le crate più importanti dell'ecosistema Rust?

Un'informazione utile da sapere per gli sviluppatori del linguaggio Rust e per i manutentori dell'indice [Crates.io] sono i nomi delle crate più importanti nell'indice.

Alcuni esempi di casi in cui il dato di importanza delle crate potrebbe essere utile sono:
- selezionare anticipatamente le crate su cui effettuare caching più aggressivo
- determinare le crate più a rischio di supply chain attack
- prioritizzare determinate crate da testare in caso di modifiche al compilatore

L'obiettivo di questa ricerca è di determinare quali sono le crates più importanti dell'ecosistema Rust, utilizzando metodi diversi da quello attualmente in uso, ovvero il numero di download negli ultimi 90 giorni, e di valutare l'efficacia dei metodi utilizzati. 

### 2️⃣ Quali potrebbero essere altre *category* utilizzabili per classificare crate?

Affinchè le crate pubblicate possano essere utilizzate, non è sufficiente che esse vengano indicizzate: è necessario anche che gli sviluppatori che ne hanno bisogno riescano a scoprirle.

Si ha quindi un problema di *discoverability*, in cui si vuole rendere più facile possibile per gli sviluppatori trovare le migliori crate con le funzionalità a loro necessarie.

A tale fine, [Crates.io] permette agli autori di ciascuna crate di specificare fino a 5 *keyword* (brevi stringhe arbitrarie alfanumeriche, come `logging` o `serialization`) per essa, attraverso le quali è possibile trovare la crate tramite funzionalità di ricerca del sito, e fino a 5 *category* (chiavi di un [thesaurus ufficiale], come `Aerospace :: Unmanned aerial vehicles`), che inseriscono la crate in raccolte tematiche sfogliabili.

Lo scopo di questa ricerca è quello di identificare cluster tematici di crate attraverso indagini sulle *keyword*, scoprendo potenzialmente nuove *category* per il  thesaurus.

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

La [Graph Data Science Library] non è in grado di operare direttamente sul grafo, ma opera su delle proiezioni effimere di parti di esso immagazzinate all'interno di uno storage denominato [Graph Catalog], al fine di permettere agli algoritmi di operare con maggiore efficienza su un sottoinsieme mirato di elementi del grafo.

Esistono vari modi per creare nuove proiezioni, ma all'interno di questa relazione ci si concentra su due di essi, ovvero le funzioni Cypher:
- [`gds.graph.project.cypher`] (anche detta Cypher projection), che crea una proiezione a partire da due query Cypher, suggerita per il solo utilizzo in fase di sviluppo in quanto relativamente lenta
- [`gds.graph.project`] (anche detta native projection), che crea una proiezione a partire dai label di nodi ed archi, operando direttamente sui dati grezzi del DBMS, ottenendo così un'efficienza significativamente maggiore e offrendo alcune funzionalità aggiuntive

Il Graph Catalog viene svuotato ad ogni nuovo avvio del DBMS Neo4J; si richiede pertanto di fare attenzione a non interrompere il processo del DBMS tra la creazione di una proiezione e l'esecuzione di un algoritmo su di essa.

### Modalità d'uso

La [Graph Data Science Library] è in grado di eseguire gli algoritmi in quattro diverse modalità:

- ***Stream***, che restituisce i risultati dell'algoritmo come risultato della query
- ***Stats***, che restituisce come risultato della query alcune statistiche sul risultato dell'algoritmo senza effettuare altro
- ***Mutate***, che restituisce gli stessi valori di *Stats*, ma scrive anche il risultato dell'esecuzione sul *Graph Catalog*
- ***Write***, che restituisce gli stessi valori di *Stats*, ma scrive anche il risultato dell'esecuzione direttamente sul grafo principale

In questa relazione si utilizza solamente la modalità *Write*, in quanto si vuole ispezionare successivamente i risultati ottenuti tramite ulteriori query.

## Analisi

### 1️⃣ Realizzazione della *Graph Projection* Cypher

Si utilizza un approccio bottom-up per la costruzione della graph projection delle crate e delle loro dipendenze.

#### Determinazione dei nodi partecipanti

Si usa la seguente query per determinare i codici identificativi dei nodi che partecipano all'algoritmo:

```cypher
// Trova tutti gli id dei nodi con il label :Crate
MATCH (a:Crate)
RETURN id(a) AS id
```

| id |
|---:|
|  0 |
|  1 | 
|  2 |

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

| source | target |
|-------:|-------:|
|  98825 |  21067 |
|  98825 |  16957 | 
|  22273 |  21318 |

#### Creazione della *Graph Projection*

Si combinano le due precedenti query in una chiamata a [`gds.graph.project.cypher`]:

```cypher
CALL gds.graph.project.cypher(
	"deps",
	"MATCH (a:Crate) RETURN id(a) AS id",
	"MATCH (a:Crate)-[:HAS_VERSION]->(v:Version) WITH a, v ORDER BY v.name DESC WITH a, collect(v.name)[0] AS vn MATCH (a:Crate)-[:HAS_VERSION]->(v:Version {name: vn})-[:DEPENDS_ON]->(c:Crate) RETURN id(a) AS source, id(c) AS target"
) YIELD
	graphName,
	nodeCount,
	relationshipCount,
	projectMillis
```

| graphName | nodeCount | relationshipCount | projectMillis |
|-----------|----------:|------------------:|--------------:|
| "deps" | 105287 | 537154 | 8272 |

### 1️⃣ Degree Centrality

Come prima possibile misura di importanza, si sceglie di usare la *Degree Centrality* di ciascuna crate, ovvero il numero di crate dipendenti che essa possiede.

Si realizza ciò utilizzando la funzione [`gds.degree`], in modalità *Write*, in modo da riuscire a recuperare successivamente i risultati.

Prima di eseguire l'algoritmo, [si stimano] le risorse computazionali richieste:

```cypher
CALL gds.degree.write.estimate(
	"deps",
	{
		// Di default l'algoritmo conteggia gli archi uscenti di ciascun nodo; con questo parametro, il comportamento si inverte
		orientation: "REVERSE",
		writeProperty: "degreeCentrality"
	}
) YIELD
	nodeCount, 
	relationshipCount, 
	bytesMin, 
	bytesMax, 
	requiredMemory
```

| nodeCount | relationshipCount | bytesMin | bytesMax | requiredMemory |
|----------:|------------------:|---------:|---------:|---------------:|
| 105287    | 537154            | 56       | 56       | "56 Bytes"     |

Dato che la memoria richiesta stimata per l'esecuzione dell'algoritmo è insignificante, lo si esegue immediatamente:

```cypher
CALL gds.degree.write(
	"deps",
	{
		// Di default l'algoritmo conteggia gli archi uscenti di ciascun nodo; con questo parametro, il comportamento si inverte
		orientation: "REVERSE",
		writeProperty: "degreeCentrality"
	}
) YIELD
	centralityDistribution,
	preProcessingMillis,
	computeMillis,
	postProcessingMillis,
	writeMillis,
	nodePropertiesWritten,
	configuration
```

| centralityDistribution                                                                                                                                                             | preProcessingMillis | computeMillis | postProcessingMillis | writeMillis | nodePropertiesWritten | configuration                                                                                                                                                                                                                |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|---------------|----------------------|-------------|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| {p99: 41.00023651123047, min: 0.0, max: 24612.124992370605, mean: 5.101820968701407, p90: 3.0000076293945312, p50: 0.0, p999: 609.0038986206055, p95: 6.000022888183594, p75: 1.0} | 2                   | 194           | 341                  | 3038        | 105287                | {jobId: "ed7a37d0-296d-4ee3-9914-6a461ea819c5", orientation: "REVERSE", writeConcurrency: 4, writeProperty: "degreeCentrality", logProgress: true, nodeLabels: \["\*"\], sudo: false, relationshipTypes: \["\*"\], concurrency: 4} |

Dal valore `centralityDistribution` restituito è possibile osservare alcune statistiche sull'elaborazione effettuata:
- il minimo (`min`) di dipendenti per crate è di `0`
- la media (`mean`) di dipendenti per crate è di `5`
- la mediana (cinquantesima percentile, `p50`) di dipendenti per crate è `0`
- il terzo quartile (settantacinquesima percentile, `p75`) di dipendenti per crate è `1`
- la novantesima percentile (`p90`) di dipendenti per crate è di `3`
- la novantacinquesima percentile (`p95`) di dipendenti per crate è di `6`
- la novantanovesima percentile (`p99`) di dipendenti per crate è di `41`
- la 99.9ima percentile (`p999`) di dipendenti per crate è di `609`
- il massimo (`max`) di dipendenti per crate è di `24612`

Per verificare che l'algoritmo abbia funzionato correttamente, si recuperano le venticinque crate con valori più alti di `degreeCentrality`:

```cypher
MATCH (c:Crate)
RETURN c.name, c.description, c.degreeCentrality
ORDER BY c.degreeCentrality DESC 
LIMIT 25
```

| c.name         | c.description                                                                                                                                   | c.degreeCentrality |
|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------:|
| [serde](https://crates.io/crates/serde)        | "A generic serialization/deserialization framework"                                                                                             | 24612.0            |
| [serde_json](https://crates.io/crates/serde_json)   | "A JSON serialization file format"                                                                                                              | 16365.0            |
| [log](https://crates.io/crates/log)          | "A lightweight logging facade for Rust"                                                                                                         | 12134.0            |
| [tokio](https://crates.io/crates/tokio)        | "An event-driven, non-blocking I/O platform for writing asynchronous I/Obacked applications."                                                   | 11298.0            |
| [clap](https://crates.io/crates/clap)         | "A simple to use, efficient, and full-featured Command Line Argument Parser"                                                                    | 10066.0            |
| [rand](https://crates.io/crates/rand)         | "Random number generators and other randomness functionality."                                                                                  | 9993.0             |
| [thiserror](https://crates.io/crates/thiserror)    | "derive(Error)"                                                                                                                                 | 8615.0             |
| [anyhow](https://crates.io/crates/anyhow)       | "Flexible concrete Error type built on std::error::Error"                                                                                       | 8130.0             |
| [futures](https://crates.io/crates/futures)      | "An implementation of futures and streams featuring zero allocations,composability, and iterator-like interfaces."                              | 7398.0             |
| [lazy_static](https://crates.io/crates/lazy_static)  | "A macro for declaring lazily evaluated statics in Rust."                                                                                       | 7118.0             |
| [chrono](https://crates.io/crates/chrono)       | "Date and time library for Rust"                                                                                                                | 6708.0             |
| [regex](https://crates.io/crates/regex)        | "An implementation of regular expressions for Rust. This implementation usesfinite automata and guarantees linear time matching on all inputs." | 6320.0             |
| [syn](https://crates.io/crates/syn)          | "Parser for Rust source code"                                                                                                                   | 5495.0             |
| [quote](https://crates.io/crates/quote)        | "Quasi-quoting macro quote!(...)"                                                                                                               | 5466.0             |
| [serde_derive](https://crates.io/crates/serde_derive) | "Macros 1.1 implementation of #[derive(Serialize, Deserialize)]"                                                                                | 5364.0             |
| [libc](https://crates.io/crates/libc)         | "Raw FFI bindings to platform libraries like libc."                                                                                             | 5287.0             |
| [reqwest](https://crates.io/crates/reqwest)      | "higher level HTTP client library"                                                                                                              | 5261.0             |
| [env_logger](https://crates.io/crates/env_logger)   | "A logging implementation for `log` which is configured via an environmentvariable."                                                            | 4912.0             |
| [proc-macro2](https://crates.io/crates/proc-macro2)  | "A substitute implementation of the compiler's `proc_macro` API to decouple token-based libraries from the procedural macro use case."          | 4471.0             |
| [bytes](https://crates.io/crates/bytes)        | "Types and traits for working with bytes"                                                                                                       | 4011.0             |
| [url](https://crates.io/crates/url)          | "URL library for Rust, based on the WHATWG URL Standard"                                                                                        | 3748.0             |
| [itertools](https://crates.io/crates/itertools)    | "Extra iterator adaptors, iterator methods, free functions, and macros."                                                                        | 3652.0             |
| [async-trait](https://crates.io/crates/async-trait)  | "Type erasure for async trait methods"                                                                                                          | 3514.0             |
| [criterion](https://crates.io/crates/criterion)    | "Statistics-driven micro-benchmarking library"                                                                                                  | 3303.0             |
| [structopt](https://crates.io/crates/structopt)    | "Parse command line argument by defining a struct."                                                                                             | 3045.0             |

Per preparare il grafo ad un confronto tra i metodi di ordinamento che sarà effettuato nelle conclusioni, si imposta su ogni nodo `:Crate` la proprietà `degreeCentralityPosition`, contenente la posizione nella "classifica" di crate ordinate per *Degree Centrality*:

```cypher
MATCH (c:Crate) 
WITH c
ORDER BY c.degreeCentrality DESC
// Raccogli le crate in un singolo valore lista
WITH collect(c) AS crates
// Crea tanti valori numerici per ogni crate all'interno della lista
UNWIND range(0, size(crates) - 1) AS position
// Per ciascun valore numerico, imposta la proprietà della crate in quella posizione della lista al valore attuale
SET (crates[position]).degreeCentralityPosition = position
```

### 1️⃣ PageRank

Per ottenere una misura di importanza più elaborata, si è scelto di utilizzare *PageRank*, algoritmo iterativo che dà maggiore rilevanza alle crate con pochi dipendenze e molti dipendenti, utilizzando la funzione [`gds.pageRank`].

Ancora, prima di eseguire l'algoritmo [si stimano] le risorse richieste:

```cypher
CALL gds.pageRank.write.estimate(
	"deps",
	{
		writeProperty: "pageRank"
	}
) YIELD
	nodeCount, 
	relationshipCount, 
	bytesMin, 
	bytesMax, 
	requiredMemory
```

| nodeCount | relationshipCount | bytesMin | bytesMax | requiredMemory |
|----------:|------------------:|---------:|---------:|---------------:|
| 105287 | 537154 | 2540880 | 2540880 | "2481 KiB" |

Si osserva come la quantità di memoria richiesta sia significativamente maggiore di quella richiesta dall'algoritmo di *Degree Centrality*, ma sempre una quantità accettabile con le risorse a disposizione dei computer moderni; dunque, si procede con l'esecuzione dell'algoritmo:

```cypher
CALL gds.pageRank.write(
	"deps",
	{
		writeProperty: "pageRank"
	}
) YIELD
	nodePropertiesWritten,
	ranIterations,
	didConverge,
	preProcessingMillis,
	computeMillis,
	postProcessingMillis,
	writeMillis,
	centralityDistribution,
	configuration
```

| nodePropertiesWritten | ranIterations | didConverge | preProcessingMillis | computeMillis | postProcessingMillis | writeMillis | centralityDistribution                                                                                                                                                                                                                  | configuration                                                                                           |                 |                             |                  |                   |                     |             |                     |                            |                   |
|-----------------------|---------------|-------------|---------------------|---------------|----------------------|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|-----------------|-----------------------------|------------------|-------------------|---------------------|-------------|---------------------|----------------------------|-------------------|
| 105287                | 20            | false       | 0                   | 388           | 205                  | 1028        | {p99: 1.7772817611694336, min: 0.14999961853027344, max: 2633.8749990463257, mean: 0.5682340436878162, p90: 0.2225809097290039, p50: 0.14999961853027344, p999: 56.281737327575684, p95: 0.31362438201904297, p75: 0.16451454162597656} | {maxIterations: 20, writeConcurrency: 4, concurrency: 4, jobId: "1ada9849-5163-42a1-99d3-11b974e1f6d1"" | sourceNodes: [] | writeProperty: ""pageRank"" | scaler: ""NONE"" | logProgress: true | nodeLabels: \[""\*""\] | sudo: false | dampingFactor: 0.85 | relationshipTypes: \[""\*""\] | tolerance: 1e-7}" |

Si osservano nel parametro `centralityDistribution` le stesse percentili già restituite dalla precedente query:
- il punteggio PageRank minimo è `0.14`
- il punteggio PageRank medio è `0.57`
- il punteggio PageRank massimo è `2633.87`
- la mediana è `0.14`
- etc.

Per verificare che l'algoritmo abbia funzionato correttamente, si recuperano le venticinque crate con valori più alti di `pageRank`:

```cypher
MATCH (c:Crate)
RETURN c.name, c.description, c.pageRank
ORDER BY c.pageRank DESC 
LIMIT 25
```
| c.name                     | c.description                                                                                                                                                                        | c.pageRank         |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|
| [serde_derive](https://crates.io/crates/serde_derive)              | "Macros 1.1 implementation of #[derive(Serialize, Deserialize)]"                                                                                                                     | 2633.874125046061  |
| [serde](https://crates.io/crates/serde)                     | "A generic serialization/deserialization framework"                                                                                                                                  | 2600.440123009117  |
| [quote](https://crates.io/crates/quote)                     | "Quasi-quoting macro quote!(...)"                                                                                                                                                    | 1753.3856963760738 |
| [proc-macro2](https://crates.io/crates/proc-macro2)              | "A substitute implementation of the compiler's `proc_macro` API to decouple token-based libraries from the procedural macro use case."                                               | 1547.7022936971498 |
| [trybuild](https://crates.io/crates/trybuild)                  | "Test harness for ui tests of compiler diagnostics"                                                                                                                                  | 1452.1162055975724 |
| [rand](https://crates.io/crates/rand)                      | "Random number generators and other randomness functionality."                                                                                                                       | 1108.4777776060996 |
| [syn](https://crates.io/crates/syn)                       | "Parser for Rust source code"                                                                                                                                                        | 1047.3719317086059 |
| [rustc-std-workspace-core](https://crates.io/crates/rustc-std-workspace-core)  | "Explicitly empty crate for rust-lang/rust integration"                                                                                                                              | 997.5769831539204  |
| [serde_json](https://crates.io/crates/serde_json)                | "A JSON serialization file format"                                                                                                                                                   | 885.3755595284099  |
| [criterion](https://crates.io/crates/criterion)                 | "Statistics-driven micro-benchmarking library"                                                                                                                                       | 845.3984645777579  |
| [libc](https://crates.io/crates/libc)                      | "Raw FFI bindings to platform libraries like libc."                                                                                                                                  | 808.9144700265439  |
| [rustversion](https://crates.io/crates/rustversion)               | "Conditional compilation according to rustc compiler version"                                                                                                                        | 785.8724508729044  |
| [lazy_static](https://crates.io/crates/lazy_static)               | "A macro for declaring lazily evaluated statics in Rust."                                                                                                                            | 708.9297457284239  |
| [unicode-xid](https://crates.io/crates/unicode-xid)              | "Determine whether characters have the XID_Startor XID_Continue properties according toUnicode Standard Annex #31."                                                                  | 674.7055991635623  |
| [log](https://crates.io/crates/log)                       | "A lightweight logging facade for Rust"                                                                                                                                              | 606.2087374708564  |
| [doc-comment](https://crates.io/crates/doc-comment)               | "Macro to generate doc comments"                                                                                                                                                     | 584.0581095948327  |
| [winapi](https://crates.io/crates/winapi)                    | "Raw FFI bindings for all of Windows API."                                                                                                                                           | 583.2378424756424  |
| [regex](https://crates.io/crates/regex)                     | "An implementation of regular expressions for Rust. This implementation usesfinite automata and guarantees linear time matching on all inputs."                                      | 371.30425142334036 |
| [quickcheck](https://crates.io/crates/quickcheck)               | "Automatic property based testing with shrinking."                                                                                                                                   | 363.2685687604089  |
| [termcolor](https://crates.io/crates/termcolor)                 | "A simple cross platform library for writing colored text to a terminal."                                                                                                            | 325.9086283505512  |
| [spin](https://crates.io/crates/spin)                      | "Spin-based synchronization primitives"                                                                                                                                              | 318.4314085948815  |
| [cfg-if](https://crates.io/crates/cfg-if)                    | "A macro to ergonomically define an item depending on a large number of #[cfg]parameters. Structured like an if-else chain, the first matching branch is theitem that gets emitted." | 316.12379240263994 |
| [winapi-util](https://crates.io/crates/winapi-util)               | "A dumping ground for high level safe wrappers over winapi."                                                                                                                         | 315.8947682994466  |
| [clap](https://crates.io/crates/clap)                      | "A simple to use, efficient, and full-featured Command Line Argument Parser"                                                                                                         | 288.0085754382288  |
| [tokio](https://crates.io/crates/tokio)                     | "An event-driven, non-blocking I/O platform for writing asynchronous I/Obacked applications."                                                                                        | 282.1129077269715  |

Come effettuato in precedenza per la *Degree Centrality*, si imposta su ogni nodo `:Crate` la proprietà `pageRankPosition`:

```cypher
MATCH (c:Crate) 
WITH c
ORDER BY c.pageRank DESC
WITH collect(c) AS crates
UNWIND range(0, size(crates) - 1) AS position
SET (crates[position]).pageRankPosition = position
```

### 2️⃣ Realizzazione della *Graph Projection* nativa

[Non essendo possibile creare grafi non diretti] con la funzione [`gds.graph.project.cypher`], si ricorre alla più efficiente ma complessa [`gds.graph.project`], che invece supporta la funzionalità specificando `orientation: "UNDIRECTED"`.

#### Creazione di collegamenti aggiuntivi nel grafo

[`gds.graph.project`] necessita che gli archi da proiettare siano già presenti all'interno del grafo principale; pertanto, si crea una nuova relazione `:IS_RELATED_TO` tra i nodi `:Keyword` presenti all'interno di ogni stessa crate:

```cypher
MATCH (a:Keyword)<-[:IS_TAGGED_WITH]-(c:Crate)-[:IS_TAGGED_WITH]->(b:Keyword)
CREATE (a)-[:IS_RELATED_TO]->(b)
```

#### Creazione della *Graph Projection*

Si effettua poi la chiamata a [`gds.graph.project`]:

```cypher
CALL gds.graph.project(
	// Crea una proiezione chiamata "kwds"
	"kwds",
	// Contenente i nodi con il label :Keyword
	"Keyword",
	// E gli archi con il label :IS_RELATED_TO, considerandoli come non-diretti
	{IS_RELATED_TO: {orientation: "UNDIRECTED"}}
) YIELD
	graphName,
	nodeCount,
	relationshipCount,
	projectMillis
```

| graphName | nodeCount | relationshipCount | projectMillis |
|-----------|----------:|------------------:|--------------:|
| "kwds" | 24042 | 1075328 | 197 |

### 2️⃣ Label Propagation

Per la classificazione delle keyword, si sceglie di usare inizialmente l'algoritmo di *Label Propagation* attraverso la funzione [`gds.labelPropagation`], in grado di identificare i singoli gruppi di nodi connessi densamente.

#### Funzionamento dell'algoritmo 

L'algoritmo iterativo di *Label Propagation*:

1. inizializza tutti i nodi con un *label* univoco
2. per ogni iterazione:
	1. ogni nodo cambia il proprio *label* a quello posseduto dalla maggioranza dei propri vicini
	2. in caso di pareggio tra due o più *label*, ne viene selezionato deterministicamente uno arbitrario
	3. se nessun nodo ha cambiato *label* in questa iterazione, termina l'algoritmo
	4. se è stato raggiunto il numero massimo consentito di iterazioni, termina l'algoritmo

#### Esecuzione della query

Come effettuato per ogni analisi, [si stimano] le risorse necessarie all'esecuzione dell'algoritmo:

```cypher
CALL gds.labelPropagation.write.estimate(
	"kwds",
	{
		maxIterations: 1000,
		writeProperty: "communityLabelPropagation" 
	}
) YIELD
	nodeCount, 
	relationshipCount, 
	bytesMin, 
	bytesMax, 
	requiredMemory
```

| nodeCount | relationshipCount | bytesMin | bytesMax | requiredMemory |
|-----------|-------------------|----------|----------|----------------|
| 24042 | 1075328 | 194392 | 2291032 | "[189 KiB ... 2237 KiB]" |

Si osserva che la quantità di memoria richiesta per l'esecuzione di questo algoritmo è variabile, ma comunque ben contenuta all'interno delle capacità di elaborazione di qualsiasi computer moderno.

Si procede con l'esecuzione, questa volta in modalità *Write*, in modo da poter effettuare in seguito query sul grafo per poter filtrare le keyword in base al label a loro assegnato, salvato nella proprietà `communityLabelPropagation`:

```cypher
CALL gds.labelPropagation.write(
	"kwds",
	{
		maxIterations: 1000,
		writeProperty: "communityLabelPropagation" 
	}
) YIELD
	preProcessingMillis,
	computeMillis,
	writeMillis,
	postProcessingMillis,
	nodePropertiesWritten,
	communityCount,
	ranIterations,
	didConverge,
	communityDistribution
```

| preProcessingMillis | computeMillis | writeMillis | postProcessingMillis | nodePropertiesWritten | communityCount | ranIterations | didConverge | communityDistribution                                                                              |
|---------------------|---------------|-------------|----------------------|-----------------------|----------------|---------------|-------------|----------------------------------------------------------------------------------------------------|
| 1                   | 760           | 437         | 48                   | 24042                 | 2335           | 15            | true        | {p99: 15, min: 1, max: 17596, mean: 10.296359743040686, p90: 5, p50: 2, p999: 204, p95: 6, p75: 3} |

Si osserva che l'algoritmo è riuscito a convergere a una soluzione.

#### Campionamento delle community

Si individuano gli identificatori dei label rimasti al termine dell'algoritmo:

```cypher
MATCH (k:Keyword)
RETURN collect(DISTINCT k.communityLabelPropagation)
```

```
[129222, 107005, 129156, 105304, 105306, 105308, 105324, 114977, 105426, 128851, 105318, 105320, 105322, 105323, 105327, 120684, 105332, 105334, 126341, 105368, 129138, 118398, 109137, 105355, 105356, 124270, 105604, 105365, 114271, 105373, 126354, 113751, 105424, 109885, 105448, 111400, 105451, 105457, 105749, 105576, 105470, 105472, 105511, 105485, 106226, 105501, 105504, 114487, 105509, 105513, 109628, 105527, 105525, 105534, 110378, 105537, 105541, 116341, 118387, 128674, 105552, 105553, 105559, 105572, 112844, 122130, 105600, 111384, 105607, 105609, 109518, 105675, 108964, 116475, 105883, 114270, 113524, 112223, 105652, 120156, 105940, 105659, 119274, 105664, 105783, 105671, 105677, 105679, 113515, 105686, 119232, 105699, 112831, 105835, 105867, 105745, 105754, 117345, 105763, 105853, 105768, 105770, 105773, 105777, 105792, 105798, 118282, 118449, 105802, 105805, 113140, 117045, 115822, 105820, 128736, 122383, 105830, 105839, 126956, 114811, 105846, 105857, 118830, 105989, 119738, 120607, 106049, 105885, 105892, 105983, 105996, 108047, 105910, 111844, 105913, 105916, 105919, 105921, 113265, 110097, 105944, 105953, 105956, 105960, 105962, 111858, 106574, 105971, 105976, 106164, 106005, 106009, 106011, 108487, 106018, 106162, 106038, 106028, 106132, 106032, 106151, 106143, 106044, 106056, 106191, 121385, 112153, 115790, 106079, 114003, 106101, 111372, 108095, 111111, 106223, 106535, 106701, 106121, 106129, 106130, 106145, 106155, 106208, 114594, 112437, 107874, 116998, 106195, 107502, 106201, 106212, 106213, 106216, 106218, 129061, 111023, 106232, 106235, 109977, 106246, 108654, 106262, 106267, 106276, 106271, 119497, 106288, 106583, 113328, 119823, 106314, 106315, 106596, 106326, 106482, 112396, 116625, 116405, 106341, 117254, 106346, 115131, 106350, 106635, 113349, 108271, 108001, 106377, 106382, 106385, 106388, 116190, 106667, 106393, 106552, 113087, 127965, 106553, 106424, 106442, 106431, 106432, 108202, 106466, 106460, 114620, 106470, 106633, 111166, 123807, 106497, 113604, 110939, 115840, 118735, 106510, 113627, 106516, 106527, 106520, 120189, 107189, 109061, 113230, 106564, 106825, 106578, 111423, 106595, 106599, 106608, 106673, 116760, 106617, 106625, 114580, 106639, 106927, 106648, 106649, 124291, 106665, 106672, 126561, 106687, 106814, 106688, 125017, 106843, 106708, 118834, 106746, 106720, 111170, 106727, 106767, 106739, 112901, 106742, 108121, 119305, 128824, 121482, 106777, 121663, 106792, 107534, 106806, 112496, 106976, 106993, 106824, 106830, 106944, 123867, 108072, 106872, 106838, 106851, 107223, 128486, 106859, 106862, 106863, 107057, 106884, 106890, 106894, 106895, 122399, 119794, 106915, 106917, 106931, 106932, 106936, 106942, 106945, 107092, 106967, 106968, 106987, 106974, 106992, 107598, 108539, 107008, 107131, 107013, 110952, 107021, 107022, 107027, 107031, 107033, 107156, 107853, 108953, 107068, 107073, 107074, 107075, 107081, 109528, 120025, 107111, 108583, 110250, 107115, 109543, 107163, 107188, 118416, 107329, 107966, 107204, 112071, 108126, 120289, 107976, 107230, 107246, 107235, 109164, 108368, 107291, 107281, 114867, 127281, 107671, 120350, 109436, 107351, 113414, 107304, 107306, 107308, 107314, 122721, 107320, 109364, 114767, 113506, 107364, 107379, 117294, 107389, 107392, 124187, 107402, 107406, 112493, 107408, 107417, 113076, 107434, 107440, 107581, 107448, 116485, 115100, 107460, 107637, 107498, 118926, 107643, 107512, 107515, 107742, 107633, 107620, 107549, 107552, 107647, 107557, 128348, 108981, 107572, 107594, 107596, 109372, 107609, 107619, 107765, 107626, 123070, 107631, 110484, 107641, 107644, 107654, 107691, 107658, 107923, 119806, 107900, 107679, 111500, 110088, 107690, 113194, 126067, 107701, 107710, 107711, 110015, 107726, 109718, 108220, 108937, 109328, 116791, 107758, 124785, 107764, 107767, 108176, 116538, 118184, 107836, 107806, 107810, 107930, 108868, 108002, 108469, 107850, 112020, 107885, 107894, 121088, 107910, 107947, 116481, 107944, 124095, 107962, 107960, 109152, 119162, ...]
```

Si campiona un label per verificarne i contenuti:

```cypher
MATCH (k:Keyword { communityLabelPropagation: 129222 }) 
RETURN k.name
```

```text
["urbandictionary", "json2pdf", "flickrapi", "robotstxt", "bookmarking", "gameboy-advance", ...]
```

Si osserva che in questa query sono contenute molte keyword relative a Internet e servizi disponibili su esso, che potrebbero individuare quindi una categoria "Internet".

Si campiona un altro label:

```cypher
MATCH (k:Keyword { communityLabelPropagation: 107005 }) 
RETURN k.name
```

```text
["temporary-files", "caches", "backups", "time-machine"]
```

Si osserva come questo label sia stato assegnato a un singolo nodo, e che quindi non fornisce informazioni particolarmente significative.

Si campiona un terzo e ultimo label:

```cypher
MATCH (k:Keyword { communityLabelPropagation: 129156 }) 
RETURN k.name
```

```text
["max32660", "cortex-a", "jtag", "bitbang", "msp432", "capacitive", "stm32l5xx", "stm32f072", ...]
```

Si osserva una community molto ben definita di label relativi all'elettronica e alla programmazione embedded, che potrebbero individuare una categoria "Electronics and embedded programming".

### 2️⃣ Louvain

Si effettua un approccio diverso alla community detection, ovvero quello di usare l'*algoritmo Louvain* ([`gds.louvain`]) per identificare i raggruppamenti che massimizzano la modularity del grafo.

Si inizia stimando le risorse necessarie all'esecuzione dell'algoritmo:

```cypher
CALL gds.louvain.write.estimate(
	"kwds",
	{
		writeProperty: "communityLouvain"
	}
) YIELD
	nodeCount, 
	relationshipCount, 
	bytesMin, 
	bytesMax, 
	requiredMemory
```

| nodeCount | relationshipCount | bytesMin | bytesMax | requiredMemory |
|----------:|------------------:|---------:|---------:|---------------:|
| 24042 | 1075328 | 1546985 | 26744496 | "[1510 KiB ... 25 MiB]" |

La quantità di memoria massima utilizzabile continua a essere all'interno le risorse disponibili a qualsiasi calcolatore moderno, pertanto si procede all'esecuzione in modalità *Write*:

```cypher
CALL gds.louvain.write(
	"kwds",
	{
		writeProperty: "communityLouvain" 
	}
) YIELD
	preProcessingMillis,
	computeMillis,
	writeMillis,
	postProcessingMillis,
	nodePropertiesWritten,
	communityCount,
	ranLevels,
	modularity,
	modularities,
	communityDistribution
```

| preProcessingMillis | computeMillis | writeMillis | postProcessingMillis | nodePropertiesWritten | communityCount | ranLevels | modularity         | modularities                                                | communityDistribution                                                                              |
|---------------------|---------------|-------------|----------------------|-----------------------|----------------|-----------|--------------------|-------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| 0                   | 6234          | 271         | 26                   | 24042                 | 1322           | 3         | 0.5470496088005096 | [0.434767324919813, 0.5403286363404538, 0.5470496088005096] | {p99: 688, min: 1, max: 2280, mean: 18.18608169440242, p90: 3, p50: 1, p999: 1994, p95: 4, p75: 1} |

Si osserva come l'*algoritmo Louvain* abbia individuato poco più della metà delle community individuate dalla *Label Propagation*.

#### Campionamento delle community

Si effettuano alcuni campionamenti per verificare il contenuto delle community identificate.

Si identificano le community formate:

```cypher
MATCH (k:Keyword)
RETURN collect(DISTINCT k.communityLouvain)
```

```text
[2314, 9029, 23958, 23353, 22855, 17002, 23935, 24019, 23869, 23923, 17, 19, 21, 23853, 7113, 23830, 17993, 23061, 31, 33, 35, 36, 1825, 40, 13102, 45, 47, 23601, 23851, 13111, 68, 69, 78, 137, 161, 164, 170, 12058, 183, 185, 198, 939, 214, 217, 222, 226, 240, 238, 247, 250, 266, 272, 285, 22190, 320, 388, 596, 23966, 365, 372, 377, 9782, 384, 390, 399, 412, 458, 476, 481, 483, 486, 490, 505, 514, 515, 518, 7853, 533, 17096, 552, 559, 23922, 598, 623, 626, 632, 634, 657, 666, 669, 675, 6571, 684, 689, 724, 731, 875, 741, 745, 757, 769, 792, 814, 834, 842, 843, 7150, 908, 914, 925, 926, 929, 931, 945, 948, 959, 3367, 975, 980, 984, 1001, 1027, 1028, 1039, 1054, 1059, 1348, 8062, 1090, 1098, 1101, 1106, 1265, 1266, 1155, 1144, 1145, 1173, 1183, 1210, 12165, 1223, 1229, 1233, 14902, 1277, 1291, 1308, 1312, 1321, 1330, 1338, 1352, 1361, 19004, 1378, 1400, 1401, 1421, 1433, 5883, 1440, 1471, 1505, 1519, 1706, 1537, 1543, 1585, 1551, 1572, 1575, 1576, 1597, 1603, 1607, 1608, 17112, 1628, 1630, 1644, 1645, 1649, 1658, 1680, 1681, 1687, 1705, 3252, 1721, 1726, 5665, 1734, 1735, 1740, 1744, 1746, 1781, 1786, 1787, 1788, 1794, 4963, 1828, 1901, 1917, 6784, 1948, 1994, 2384, 2017, 2019, 2021, 2027, 2033, 4077, 2077, 12007, 2102, 2105, 2115, 2119, 2121, 2130, 7789, 2147, 2153, 2161, 2173, 2350, 2225, 2228, 2262, 2265, 2360, 2270, 3694, 2285, 2307, 2309, 2322, 2339, 17783, 2344, 5197, 2357, 2367, 2636, 2392, 2403, 2409, 2414, 2423, 2439, 11504, 2477, 2480, 2519, 2523, 2643, 2563, 2598, 2607, 2623, 2660, 2657, 2673, 2736, 2743, 2768, 2904, 2793, 3899, 2801, 2824, 10288, 2873, 2916, 2935, 2939, 2941, 2951, 2952, 2977, 3059, 3014, 3015, 3019, 3023, 3024, 3029, 3066, 3064, 3070, 3106, 3107, 3109, 3133, 3284, 3158, 3171, 3176, 3186, 3195, 3201, 3203, 3227, 3265, 3272, 19583, 3307, 3308, 3341, 3347, 3364, 3365, 3374, 3396, 3410, 19941, 3418, 3431, 3444, 7510, 3573, 3450, 3480, 3489, 3537, 3538, 3542, 3558, 3560, 3563, 3590, 3607, 3628, 3639, 3664, 3687, 3690, 3702, 3710, 3731, 3736, 3766, 3770, 3790, 3802, 22181, 3846, 3851, 3855, 3868, 3879, 4186, 3906, 3922, 4187, 4836, 6585, 3940, 4020, 6534, 3964, 3979, 3989, 4006, 4017, 4033, 4055, 4125, 4133, 4159, 4171, 4164, 6587, 12973, 4184, 4195, 4216, 4220, 4230, 5098, 4239, 4257, 4259, 4265, 4269, 4272, 4276, 4288, 4291, 4297, 4304, 4326, 4322, 4324, 13037, 4335, 4344, 4340, 4349, 4364, 4368, 4374, 4377, 4379, 4399, 4405, 4422, 4424, 4433, 4450, 4452, 4463, 4464, 4466, 4480, 23964, 4971, 4499, 4500, 4502, 4519, 4531, 4569, 4579, 10688, 4602, 4622, 4627, 7531, 5047, 4653, 4685, 4699, 4701, 4710, 4748, 4747, 4774, 4795, 5304, 4946, 4849, 4873, 4869, 4889, 4904, 4915, 4917, 4920, 4930, 4940, 4952, 6376, 4976, 4977, 4982, 5021, 5028, 5040, 5068, 5092, 5101, 5112, 5113, 5117, 10746, 5137, 5160, 5200, 5181, 5195, 5196, 5300, 5269, 5278, 5282, 5288, 5290, 5294, 5561, 5338, 5339, 5368, 5656, 5483, 5428, 5448, 5468, 5482, 5496, 5517, 5520, 6798, 6596, 17476, 5564, ...]
```

Si campiona la prima community restituita dalla query precedente:

```cypher
MATCH (k:Keyword { communityLouvain: 2314 }) 
RETURN k.name
```

```text
["gameboy-advance", "intel-8080", "sm83", "textureatlas", "rocketleaguestats", "minesweeper", "rpg-maker", "ducktyping", ...]
```

Si osserva che questo campione contiene numerose keyword relative a videogiochi, e in particolare a architetture di calcolo, strutture dati, e algoritmi di grafica 2D e 3D utilizzati in essi: si identificano pertanto tre categorie, "Videogames :: Emulation", "Videogames :: Data structures" e "Videogames :: Graphics".

Si campiona la seconda community restituita:

```cypher
MATCH (k:Keyword { communityLouvain: 9029 }) 
RETURN k.name
```

```text
["unittest", "snapshot-testing", "wycheproof", "stress", "nouns", "parameterisation", ...]
```

Si osserva che questo campione è quasi interamente relativo allo sviluppo ed esecuzione di test su codice Rust: si identifica pertanto una categoria "Testing".

### 2️⃣ Leiden

Si prova a ridurre il rumore presente nelle community individuate dall'*algoritmo Louvain* attraverso l'utilizzo dell'*algoritmo Leiden* ([`gds.beta.leiden`]), che periodicamente separa le community individuate in community più piccole ma meglio connesse.

Si stimano ancora una volta le risorse necessarie:

```cypher
CALL gds.beta.leiden.write.estimate(
	"kwds",
	{
		writeProperty: "communityLeiden"
	}
) YIELD
	nodeCount, 
	relationshipCount, 
	bytesMin, 
	bytesMax, 
	requiredMemory
```

| nodeCount | relationshipCount | bytesMin | bytesMax | requiredMemory |
|----------:|------------------:|---------:|---------:|---------------:|
| 24042 | 1075328 | 6913840 | 29249392 | "[6751 KiB ... 27 MiB]" |

Benchè rientrino nettamente nella capacità di memoria di un computer moderno, si osserva come l'*algoritmo Leiden* richieda un po' più di memoria rispetto all'*algoritmo Louvain*.

Si procede all'esecuzione, ancora una volta in modalità *Write*:

```cypher
CALL gds.beta.leiden.write(
	"kwds",
	{
		writeProperty: "communityLeiden" 
	}
) YIELD
	preProcessingMillis,
	computeMillis,
	writeMillis,
	postProcessingMillis,
	nodePropertiesWritten,
	communityCount,
	ranLevels,
	modularity,
	modularities,
	communityDistribution
```

| preProcessingMillis | computeMillis | writeMillis | postProcessingMillis | nodePropertiesWritten | communityCount | ranLevels | modularity         | modularities                                                                                          | communityDistribution                                                                               |
|---------------------|---------------|-------------|----------------------|-----------------------|----------------|-----------|--------------------|-------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| 0                   | 419           | 158         | 11                   | 24042                 | 1317           | 5         | 0.5473613732553853 | [0.44177738280624534, 0.48671179504746837, 0.5396602348474452, 0.546111627553381, 0.5473613732553853] | {p99: 695, min: 1, max: 2271, mean: 18.255125284738043, p90: 3, p50: 1, p999: 1925, p95: 4, p75: 1} |

Si osserva come il numero di community individuate dall'*algoritmo Leiden* siano molto simili al numero di community individuate dall'*algoritmo Louvain*.

#### Campionamento delle community

Come nei due casi precedenti, si effettua il campionamento delle community individuate, questa volta attraverso il parametro `communityLeiden`:

```cypher
MATCH (k:Keyword)
RETURN collect(DISTINCT k.communityLeiden)
```

```text
[270, 355, 613, 293, 139, 91, 98, 800, 120, 308, 53, 54, 55, 913, 93, 121, 115, 56, 57, 58, 59, 137, 60, 61, 87, 62, 173, 97, 1126, 63, 64, 65, 403, 318, 66, 67, 68, 69, 262, 70, 71, 72, 73, 74, 75, 76, 77, 891, 78, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 1077, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 880, 247, 248, 636, 249, 805, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 683, 469, 684, 685, 686, 687, 688, 689, 690, 691, 692, 693, 694, 695, 696, 697, 461, 698, 699, 700, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711, 712, 713, 714, 715, 716, 717, 652, 718, 719, 720, 721, 722, 723, 724, 725, 726, 727, 728, 729, 730, 731, 732, 197, 733, 734, 735, 736, 737, 738, 739, 740, 741, 400, 742, 1079, 743, 744, 979, 567, 980, 146, 1282, 1283, 1284, 1285, 1286, 1287, 1288, 1289, 1290, 1291, 1292, 1293, 1294, 1295, 806, 1296, 1297, 1298, 1299, 1300, 1301, 1302, 1303, 1304, 1305, 1306, 1307, 1308, 459, 1309, 1310, 1311, 1312, 1313, 1314, 1315, 1316, 1317, 1318, 1184, 1319, 449, 450, 484, 745, 746, 747, 748, 749, 750, 751, 752, 753, 754, 378, 755, 756, 757, 758, 759, 760, 632, 1014, 0, 1, 2, 1091, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 345, 15, 16, 17, 18, 19, 20, 21, 215, 22, 23, 24, 781, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 1333, 45, 46, 47, 48, 49, 50, 51, 52, 79, 80, 81, 82, 83, 84, 850, 851, 852, 853, 854, 855, 856, 857, 858, 859, 860, 861, 862, 863, 864, 865, 866, 867, 868, 1092, 869, 870, 871, 872, 873, 874, 875, 876, 1211, 424, 1212, 1213, 1214, 570, 1215, 1216, 1217, 1218, 1219, 1220, 1221, 1222, 1223, 1224, 1225, 1226, 1227, 444, 1228, 1229, 1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 511, 1239, 1240, 1241, 1242, 1243, 1244, 1245, 1246, 1247, 1023, 618, 1248, 1249, 467, 1250, 1251, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 470, 797, 939, 940, 941, 942, 943, 1042, 944, 945, 946, 947, 948, 949, 950, 951, 952, 953, 954, 955, 956, 957, 1120, 958, 959, 960, 961, 962, 963, 964, 965, 966, 967, 968, 969, 376, 970, 766, 971, 972, 973, 974, 975, 1034, 976, 977, 978, 213, 1165, 1166, 1167, 580, 1168, 1169, 1170, 286, 1171, 1172, 1173, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 987, 1022, 189, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 451, 820, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1043, 1044, 1045, 1046, 1047, 1048, 988, 1049, 1050, 1051, 986, 981, 899, 982, 983, 984, 985, 989, 990, 991, 992, 993, 994, 995, 996, 997, 998, 999, 1000, 1001, 314, 471, 1204, 1002, 166, 1003, 1004, 1005, 1006, ...]
```

Si campiona la prima community restituita:

```cypher
MATCH (k:Keyword { communityLeiden: 270 }) 
RETURN k.name
```

```text
["curve", "rad", "vertex-attribute", "quakeworld", "pizza", "ffxv", "voronoi_diagram" ...]
```

Si osserva che questa community è molto simile in termini di contenuti alla prima community individuata dall'*algoritmo Louvain*; essendo così tanto simili, non si è in grado di determinare qualitativamente se il rumore è inferiore o superiore.

Si campiona quindi la seconda community:

```cypher
MATCH (k:Keyword { communityLeiden: 355 }) 
RETURN k.name
```

```text
["temporary-files", "recycle", "libfuse", "swarm", "createprocessexw", "time-tracker", "yaahc", ...]
```

Si osserva che questo campione contiene varie keyword relative a filesystem e chiamate di sistema; si individua pertanto la categoria "Foreign function interface :: Operating system calls".

Non si notano variazioni qualitative nel rumore presente all'interno della categoria rispetto all'*algoritmo Louvain*.

## Conclusioni

### 1️⃣ Quali sono le crate più importanti dell'ecosistema Rust?

Si sono presentate nella fase precedente le crate che ciascuna metrica determina come più importanti.

In questa conclusione, si intende mettere a confronto le metriche realizzate.

#### Numero di downloads

Si aggiunge ai nodi `:Crate` la proprietà `downloadsPosition`, rappresentante la posizione data ordinandole per [il numero di download negli ultimi 90 giorni]:

```cypher
MATCH (c:Crate) 
WITH c
ORDER BY c.downloads DESC
WITH collect(c) AS crates
UNWIND range(0, size(crates) - 1) AS position
SET (crates[position]).downloadsPosition = position
```

#### Top 10

Si mettono a confronto le prime dieci crate nella classifica generata da ciascuna metrica con le loro posizioni nelle classifiche delle altre due:

```cypher
MATCH (c:Crate) 
RETURN c.name, c.downloadsPosition, c.degreeCentralityPosition, c.pageRankPosition 
ORDER BY c.downloadsPosition 
LIMIT 10
```

| c.name        | c.downloadsPosition | c.degreeCentralityPosition | c.pageRankPosition |
|---------------|--------------------:|---------------------------:|-------------------:|
| "syn"         | 0                   | 12                         | 6                  |
| "rand"        | 1                   | 5                          | 5                  |
| "libc"        | 2                   | 15                         | 10                 |
| "rand_core"   | 3                   | 101                        | 34                 |
| "quote"       | 4                   | 13                         | 2                  |
| "cfg-if"      | 5                   | 60                         | 21                 |
| "proc-macro2" | 6                   | 18                         | 3                  |
| "serde"       | 7                   | 0                          | 1                  |
| "autocfg"     | 8                   | 728                        | 42                 |
| "itoa"        | 9                   | 375                        | 69                 |

```cypher
MATCH (c:Crate) 
RETURN c.name, c.downloadsPosition, c.degreeCentralityPosition, c.pageRankPosition 
ORDER BY c.degreeCentralityPosition 
LIMIT 10
```

| c.name        | c.downloadsPosition | c.degreeCentralityPosition | c.pageRankPosition |
|---------------|--------------------:|---------------------------:|-------------------:|
| "serde"       | 7                   | 0                          | 1                  |
| "serde_json"  | 18                  | 1                          | 8                  |
| "log"         | 13                  | 2                          | 14                 |
| "tokio"       | 56                  | 3                          | 24                 |
| "clap"        | 35                  | 4                          | 23                 |
| "rand"        | 1                   | 5                          | 5                  |
| "thiserror"   | 64                  | 6                          | 41                 |
| "anyhow"      | 75                  | 7                          | 28                 |
| "futures"     | 62                  | 8                          | 35                 |
| "lazy_static" | 15                  | 9                          | 12                 |

```cypher
MATCH (c:Crate) 
RETURN c.name, c.downloadsPosition, c.degreeCentralityPosition, c.pageRankPosition 
ORDER BY c.pageRankPosition 
LIMIT 10
```

| c.name                     | c.downloadsPosition | c.degreeCentralityPosition | c.pageRankPosition |
|----------------------------|--------------------:|---------------------------:|-------------------:|
| "serde_derive"             | 16                  | 14                         | 0                  |
| "serde"                    | 7                   | 0                          | 1                  |
| "quote"                    | 4                   | 13                         | 2                  |
| "proc-macro2"              | 6                   | 18                         | 3                  |
| "trybuild"                 | 826                 | 96                         | 4                  |
| "rand"                     | 1                   | 5                          | 5                  |
| "syn"                      | 0                   | 12                         | 6                  |
| "rustc-std-workspace-core" | 2738                | 1231                       | 7                  |
| "serde_json"               | 18                  | 1                          | 8                  |
| "criterion"                | 353                 | 23                         | 9                  |

Empiricamente, si direbbe che sia la *Degree Centrality*, sia *PageRank* hanno portato a buoni risultati, in quanto buona parte delle posizioni restituite sono vicine alle posizioni dell'ordinamento per numero di downloads.

#### Coefficiente di correlazione per ranghi di Spearman

Si intende approfondire l'analisi calcolando il coefficiente di correlazione per ranghi di Spearman tra le metriche sperimentate e quella "ufficiale":

```cypher
MATCH (a:Crate)
WITH a, (a.downloadsPosition - a.degreeCentralityPosition) as df
WITH sum(df * df) as s, count(a) as c
WITH toFloat(s) as s, toFloat(c) as c
RETURN s*6 / (c*((c*c) - 1))
```

```
0.5307312103396986
```

```cypher
MATCH (a:Crate)
WITH a, (a.pageRankPosition - a.downloadsPosition) as df
WITH sum(df * df) as s, count(a) as c
WITH toFloat(s) as s, toFloat(c) as c
RETURN s*6 / (c*((c*c) - 1))
```

```
0.5354846552781645
```

Si nota che entrambe le misure forniscono un coefficiente di correlazione che indica correlazione moderatamente positiva con la posizione nella classifica per downloads.

### 2️⃣ Quali potrebbero essere altre *category* utilizzabili per classificare crate?

Gli algoritmi di *Label Propagation*, *Louvain* e *Leiden* sembrano essere ottimi metodi per raccogliere le crate in cluster analizzabili manualmente per determinare possibili *category* di crate.

#### Confronto con il thesaurus ufficiale

Molte delle *category* individuate esistono già nel [thesaurus ufficiale] in forme uguali o simili:

- la community "Internet" individuata è simile ai termini del thesaurus "API bindings" e "Web programming"
- la community "Electronics and embedded programming" trova corrispondenza nella category già esistente "Embedded development"
- la community "Videogames :: Emulation" corrisponde a quella realmente esistente "Emulators"
- la community "Videogames :: Data structures" è assimilabile a quella più generica "Data structures"
- la community "Videogames :: Graphics" è anch'essa assimilabile alla più generica "Graphics"
- la community "Testing" corrisponde a "Development tools :: Testing"
- infine, la community "Foreign function interface :: Operating system calls" corrisponde alle già esistenti "Development tools :: FFI" e "External FFI bindings"

Campionando più community di quelle dimostrate in questa relazione, si potrebbero riuscire a individuare *category* nuove non ancora esistenti.

#### Louvain o Leiden?

Non si è riusciti ad apprezzare differenze qualitative relative al rumore presente nelle community individuate da *Louvain* e *Leiden*.

Effettuare un'indagine più approfondita potrebbe rivelare maggiori informazioni, ma ciò va oltre lo scopo di questa relazione.


<!-- Collegamenti -->

[Crates.io]: https://crates.io/
[introduzione della relazione del progetto a tema Neo4J]: https://github.com/Steffo99/unimore-bda-4#introduzione
[thesaurus ufficiale]: https://github.com/rust-lang/crates.io/blob/master/src/boot/categories.toml
[crater]: https://github.com/rust-lang/crater
[Graph Data Science Library]: https://neo4j.com/docs/graph-data-science/current/
[Graph Catalog]: https://neo4j.com/docs/graph-data-science/current/management-ops/graph-catalog-ops/
[`gds.graph.project.cypher`]: https://neo4j.com/docs/graph-data-science/current/management-ops/projections/graph-project-cypher/
[`gds.graph.project`]: https://neo4j.com/docs/graph-data-science/current/management-ops/projections/graph-project/
[`gds.degree`]: https://neo4j.com/docs/graph-data-science/current/algorithms/degree-centrality/
[si stimano]: https://neo4j.com/docs/graph-data-science/current/common-usage/memory-estimation/
[`gds.pageRank`]: https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/
[Non essendo possibile creare grafi non diretti]: https://neo4j.com/docs/graph-data-science/current/management-ops/projections/graph-project-cypher/#_relationship_orientation
[`gds.labelPropagation`]: https://neo4j.com/docs/graph-data-science/current/algorithms/label-propagation/
[`gds.louvain`]: https://neo4j.com/docs/graph-data-science/current/algorithms/louvain/
[`gds.beta.leiden`]: https://neo4j.com/docs/graph-data-science/current/algorithms/leiden/
[il numero di download negli ultimi 90 giorni]: https://crates.io/search?sort=downloads