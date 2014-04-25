library(rrdf)
library(ggplot2)


setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

softciteData = load.rdf("data/SoftwareCitationDataset.ttl", format="TURTLE")

summarize.rdf(softciteData)
prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")
query <- paste(readLines("code/Rscripts/all_codes_query.sparql", encoding="UTF-8"), collapse=" ")

code_matrix <- sparql.rdf(softciteData, paste(prefixes, query, collapse=" "))

data <- data.frame(code_matrix)

ggplot(data, aes(x=strata,fill=code)) + geom_bar()