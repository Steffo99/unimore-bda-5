MATCH (k:Keyword)
RETURN collect(DISTINCT k.communityLabelPropagation)
