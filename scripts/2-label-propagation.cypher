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
