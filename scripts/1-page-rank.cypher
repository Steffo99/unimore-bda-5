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
