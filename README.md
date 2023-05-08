\[ Stefano Pigozzi | Grafo "creato da zero" | Tema Graph Analytics | Big Data Analytics | A.A. 2022/2023 | Unimore \]

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

Si sono realizzate varie ricerche di Graph Analytics sul database a grafo dell'indice [Crates.io], realizzato per il progetto a tema Neo4J, determinando le crate più importanti all'ecosistema attraverso gli algoritmi di *Degree Centrality*, *Betweenness Centrality*, e *PageRank*, e ricercando cluster di tag per migliorare la classificazione delle crate nell'indice attraverso gli algoritmi di *Louvain*, *Label Propagation*, e *Leiden*.


<!-- Collegamenti -->

[Crates.io]: https://crates.io/