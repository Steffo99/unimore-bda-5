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

### 1️⃣ Quali sono le crates più importanti dell'ecosistema Rust?

Un'informazione utile da sapere per gli sviluppatori del linguaggio Rust e per i manutentori dell'indice [Crates.io] sono i nomi delle crate più importanti nell'indice.

Alcuni esempi di casi in cui il dato di importanza delle crate potrebbe essere utile sono:
- selezionare anticipatamente le crate su cui effettuare caching più aggressivo
- determinare le crate più a rischio di supply chain attack
- prioritizzare determinate crate nell'esecuzione di esperimenti con [crater]

Lo scopo di questa ricerca è quello di determinare, attraverso indagini sulla rete di dipendenze, un valore di importanza per ciascuna crate, e una classifica delle 10 crate più importanti dell'indice.

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

### Modalità d'uso

<!-- TODO -->

## Analisi

### 1️⃣ Realizzazione della *Graph Projection* Cypher

Si utilizza un approccio bottom-up per la costruzione della graph projection delle crate e delle loro dipendenze.

#### Determinazione dei nodi partecipanti

Si usa la seguente query triviale per determinare i codici identificativi dei nodi che partecipano all'algoritmo:

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

Come misura di importanza più basilare, si decide di analizzare la *Degree Centrality*, ovvero il numero di archi entranti che ciascun nodo possiede, utilizzando la funzione [`gds.degree`] in modalità *Stream* per semplicità di operazione.

Prima di eseguire l'algoritmo, [si stimano] le risorse computazionali richieste:

```cypher
CALL gds.degree.stream.estimate(
	"deps",
	{
		// Di default l'algoritmo conteggia gli archi uscenti di ciascun nodo; con questo parametro, il comportamento si inverte
		orientation: "REVERSE"
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

Dato che la memoria richiesta stimata per l'esecuzione dell'algoritmo è pochissima, si procede immediatamente con l'esecuzione, e con il recupero delle 10 crate con più dipendenze entranti:

```cypher
CALL gds.degree.stream(
	"deps",
	{
		// Di default l'algoritmo conteggia gli archi uscenti di ciascun nodo; con questo parametro, il comportamento si inverte
		orientation: "REVERSE"
	}
) YIELD
	nodeId,
	score
MATCH (n)
WHERE ID(n) = nodeId
RETURN n.name AS name, score, n.description AS description
ORDER BY score DESC
LIMIT 10
```

| name          |   score | description                                                                                                        |
|---------------|--------:|--------------------------------------------------------------------------------------------------------------------|
| [`serde`](https://crates.io/crates/serde)       | 24612.0 | "A generic serialization/deserialization framework"                                                                |
| [`serde_json`](https://crates.io/crates/serde_json)  | 16365.0 | "A JSON serialization file format"                                                                                 |
| [`log`](https://crates.io/crates/log)         | 12134.0 | "A lightweight logging facade for Rust"                                                                            |
| [`tokio`](https://crates.io/crates/tokio)       | 11298.0 | "An event-driven, non-blocking I/O platform for writing asynchronous I/Obacked applications."                      |
| [`clap`](https://crates.io/crates/clap)        | 10066.0 | "A simple to use, efficient, and full-featured Command Line Argument Parser"                                       |
| [`rand`](https://crates.io/crates/rand)        |  9993.0 | "Random number generators and other randomness functionality."                                                     |
| [`thiserror`](https://crates.io/crates/thiserror)   |  8615.0 | "derive(Error)"                                                                                                    |
| [`anyhow`](https://crates.io/crates/anyhow)      |  8130.0 | "Flexible concrete Error type built on std::error::Error"                                                          |
| [`futures`](https://crates.io/crates/futures)     |  7398.0 | "An implementation of futures and streams featuring zero allocations,composability, and iterator-like interfaces." |
| [`lazy_static`](https://crates.io/crates/lazy_static) |  7118.0 | "A macro for declaring lazily evaluated statics in Rust."                                                          |

### 1️⃣ PageRank

Per ottenere una misura di importanza più elaborata, si è scelto di utilizzare *PageRank*, algoritmo iterativo che dà maggiore rilevanza alle crate con pochi dipendenze e molti dipendenti, utilizzando la funzione [`gds.pageRank`].

Ancora, prima di eseguire l'algoritmo [si stimano] le risorse richieste:

```cypher
CALL gds.pageRank.stream.estimate(
	"deps"
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

Si osserva come la quantità di memoria richiesta sia significativamente maggiore di quella richiesta dall'algoritmo di *Degree Centrality*, ma sempre una quantità accettabile con le risorse a disposizione dei computer moderni; dunque, si procede con l'esecuzione dell'algoritmo, sempre in modalità *Stream* per semplicità di uso:

```cypher
CALL gds.pageRank.stream(
	"deps",
	{}
) YIELD
	nodeId,
	score
MATCH (n)
WHERE ID(n) = nodeId
RETURN n.name AS name, score, n.description AS description
ORDER BY score DESC
LIMIT 10
```

| name                     |              score | description                                                                                                                          |
|--------------------------|-------------------:|--------------------------------------------------------------------------------------------------------------------------------------|
| [`serde_derive`](https://crates.io/crates/serde_derive)             |  2633.874125046063 | "Macros 1.1 implementation of #[derive(Serialize, Deserialize)]"                                                                       |
| [`serde`](https://crates.io/crates/serde)                    |  2600.440123009119 | "A generic serialization/deserialization framework"                                                                                    |
| [`quote`](https://crates.io/crates/quote)                    |  1753.385696376074 | "Quasi-quoting macro quote!(...)"                                                                                                      |
| [`proc-macro2`](https://crates.io/crates/proc-macro2)              |  1547.702293697151 | "A substitute implementation of the compiler's `proc_macro` API to decouple token-based libraries from the procedural macro use case." |
| [`trybuild`](https://crates.io/crates/trybuild)                 | 1452.1162055975733 | "Test harness for ui tests of compiler diagnostics"                                                                                    |
| [`rand`](https://crates.io/crates/rand)                     | 1108.4777776061019 | "Random number generators and other randomness functionality."                                                                         |
| [`syn`](https://crates.io/crates/syn)                      | 1047.3719317086066 | "Parser for Rust source code"                                                                                                          |
| [`rustc-std-workspace-core`](https://crates.io/crates/rustc-std-workspace-core) |  997.5769831539209 | "Explicitly empty crate for rust-lang/rust integration"                                                                                |
| [`serde_json`](https://crates.io/crates/serde_json)               |  885.3755595284102 | "A JSON serialization file format"                                                                                                     |
| [`criterion`](https://crates.io/crates/criterion)                |  845.3984645777582 | "Statistics-driven micro-benchmarking library"                                                                                         |

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

Si procede con l'esecuzione, questa volta in modalità `write`, in modo da poter effettuare in seguito query sul grafo per poter filtrare le keyword in base al label a loro assegnato, salvato nella proprietà `communityLabelPropagation`:

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

Si osserva che l'algoritmo è giunto a convergenza.

#### Campionamento dei label

Si individuano gli identificatori dei label rimasti al termine dell'algoritmo:

```cypher
MATCH (k:Keyword)
RETURN collect(DISTINCT k.communityLabelPropagation)
```

```
[129222, 107005, 129156, 105304, 105306, 105308, 105324, 114977, 105426, 128851, 105318, 105320, 105322, 105323, 105327, 120684, 105332, 105334, 126341, 105368, 129138, 118398, 109137, 105355, 105356, 124270, 105604, 105365, 114271, 105373, 126354, 113751, 105424, 109885, 105448, 111400, 105451, 105457, 105749, 105576, 105470, 105472, 105511, 105485, 106226, 105501, 105504, 114487, 105509, 105513, 109628, 105527, 105525, 105534, 110378, 105537, 105541, 116341, 118387, 128674, 105552, 105553, 105559, 105572, 112844, 122130, 105600, 111384, 105607, 105609, 109518, 105675, 108964, 116475, 105883, 114270, 113524, 112223, 105652, 120156, 105940, 105659, 119274, 105664, 105783, 105671, 105677, 105679, 113515, 105686, 119232, 105699, 112831, 105835, 105867, 105745, 105754, 117345, 105763, 105853, 105768, 105770, 105773, 105777, 105792, 105798, 118282, 118449, 105802, 105805, 113140, 117045, 115822, 105820, 128736, 122383, 105830, 105839, 126956, 114811, 105846, 105857, 118830, 105989, 119738, 120607, 106049, 105885, 105892, 105983, 105996, 108047, 105910, 111844, 105913, 105916, 105919, 105921, 113265, 110097, 105944, 105953, 105956, 105960, 105962, 111858, 106574, 105971, 105976, 106164, 106005, 106009, 106011, 108487, 106018, 106162, 106038, 106028, 106132, 106032, 106151, 106143, 106044, 106056, 106191, 121385, 112153, 115790, 106079, 114003, 106101, 111372, 108095, 111111, 106223, 106535, 106701, 106121, 106129, 106130, 106145, 106155, 106208, 114594, 112437, 107874, 116998, 106195, 107502, 106201, 106212, 106213, 106216, 106218, 129061, 111023, 106232, 106235, 109977, 106246, 108654, 106262, 106267, 106276, 106271, 119497, 106288, 106583, 113328, 119823, 106314, 106315, 106596, 106326, 106482, 112396, 116625, 116405, 106341, 117254, 106346, 115131, 106350, 106635, 113349, 108271, 108001, 106377, 106382, 106385, 106388, 116190, 106667, 106393, 106552, 113087, 127965, 106553, 106424, 106442, 106431, 106432, 108202, 106466, 106460, 114620, 106470, 106633, 111166, 123807, 106497, 113604, 110939, 115840, 118735, 106510, 113627, 106516, 106527, 106520, 120189, 107189, 109061, 113230, 106564, 106825, 106578, 111423, 106595, 106599, 106608, 106673, 116760, 106617, 106625, 114580, 106639, 106927, 106648, 106649, 124291, 106665, 106672, 126561, 106687, 106814, 106688, 125017, 106843, 106708, 118834, 106746, 106720, 111170, 106727, 106767, 106739, 112901, 106742, 108121, 119305, 128824, 121482, 106777, 121663, 106792, 107534, 106806, 112496, 106976, 106993, 106824, 106830, 106944, 123867, 108072, 106872, 106838, 106851, 107223, 128486, 106859, 106862, 106863, 107057, 106884, 106890, 106894, 106895, 122399, 119794, 106915, 106917, 106931, 106932, 106936, 106942, 106945, 107092, 106967, 106968, 106987, 106974, 106992, 107598, 108539, 107008, 107131, 107013, 110952, 107021, 107022, 107027, 107031, 107033, 107156, 107853, 108953, 107068, 107073, 107074, 107075, 107081, 109528, 120025, 107111, 108583, 110250, 107115, 109543, 107163, 107188, 118416, 107329, 107966, 107204, 112071, 108126, 120289, 107976, 107230, 107246, 107235, 109164, 108368, 107291, 107281, 114867, 127281, 107671, 120350, 109436, 107351, 113414, 107304, 107306, 107308, 107314, 122721, 107320, 109364, 114767, 113506, 107364, 107379, 117294, 107389, 107392, 124187, 107402, 107406, 112493, 107408, 107417, 113076, 107434, 107440, 107581, 107448, 116485, 115100, 107460, 107637, 107498, 118926, 107643, 107512, 107515, 107742, 107633, 107620, 107549, 107552, 107647, 107557, 128348, 108981, 107572, 107594, 107596, 109372, 107609, 107619, 107765, 107626, 123070, 107631, 110484, 107641, 107644, 107654, 107691, 107658, 107923, 119806, 107900, 107679, 111500, 110088, 107690, 113194, 126067, 107701, 107710, 107711, 110015, 107726, 109718, 108220, 108937, 109328, 116791, 107758, 124785, 107764, 107767, 108176, 116538, 118184, 107836, 107806, 107810, 107930, 108868, 108002, 108469, 107850, 112020, 107885, 107894, 121088, 107910, 107947, 116481, 107944, 124095, 107962, 107960, 109152, 119162]
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

Si osserva una community molto ben definita di label relativi all'elettronica e alla programmazione embedded, che potrebbero individuare una categoria "Elettronica".


<!-- Collegamenti -->

[Crates.io]: https://crates.io/
[introduzione della relazione del progetto a tema Neo4J]: https://github.com/Steffo99/unimore-bda-4#introduzione
[thesaurus]: https://github.com/rust-lang/crates.io/blob/master/src/boot/categories.toml
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