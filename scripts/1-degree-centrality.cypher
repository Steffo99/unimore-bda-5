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
