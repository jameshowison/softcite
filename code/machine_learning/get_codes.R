library(rrdf)
library(dplyr)

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")
#source("code/Rscripts//analysisFromInferred.r")


# Output goes to this file (using print)
sink("output/codes_for_machine_learning.txt")

inferredData = load.rdf("output/inferredStatements.ttl", format="TURTLE")

prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")

####################
# Begin with analysis of mentions.
####################

query <- "
SELECT ?article ?mention ?full_quote ?original_name
WHERE {
	?mention rdf:type bioj:SoftwareMention ;
   	 		 bioj:from_selection ?selection ;
			 citec:has_software_name true ;
			 citec:original_name  ?original_name .
	?article bioj:has_selection ?selection .
	?selection bioj:full_quote ?full_quote .
}
ORDER BY ?article
"
mentions <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))

#mentions <- mentions %.%
#filter(grepl('bioj:a2000-04-MOL_ECOL|bioj:a2000-08-CELL_RES|bioj:a2000-22-AM_J_BOT|bioj:a2004-46-NATURE|bioj:a2005-46-NATURE|bioj:a2006-26-ACTA_CRYSTALLOGR_D|bioj:a2007-14-NAT_GENET|bioj:a2007-27-CLADISTICS|bioj:a2007-38-HUM_MOL_GENET|bioj:a2010-05-BMC_MOL_BIOL',article))

write.csv(mentions, row.names=FALSE)

sink()
closeAllConnections()