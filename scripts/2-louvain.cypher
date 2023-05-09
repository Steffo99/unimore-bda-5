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