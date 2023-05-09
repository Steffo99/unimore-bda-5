CALL gds.graph.project(
	"kwds",
	"Keyword",
	{IS_RELATED_TO: {orientation: "UNDIRECTED"}}
) YIELD
	graphName,
	nodeCount,
	relationshipCount,
	projectMillis