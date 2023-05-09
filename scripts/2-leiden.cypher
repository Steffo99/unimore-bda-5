CALL gds.beta.leiden.write(
	"kwds_native",
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
