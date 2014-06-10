library(rrdf)
library(ggplot2)


setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

softciteData = load.rdf("data/SoftwareCitationDataset.ttl", format="TURTLE")

summarize.rdf(softciteData)
prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")
query <- paste(readLines("code/Rscripts/all_codes_query.sparql", encoding="UTF-8"), collapse=" ")

code_matrix <- sparql.rdf(softciteData, paste(prefixes, query, collapse=" "))

data <- data.frame(code_matrix)

# Now produce a few relevant graphs.

ggplot(data, aes(x=strata,fill=code)) + geom_bar()

# Mentions by strata.

tempdata <- subset(data, code == "citec:in-text_mention")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

# Of all the mentions, which were findable, which were not?
tempdata <- subset(data, code == "citec:findable" | code == "citec:unfindable")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

# Of all the mentions, which were 
tempdata <- subset(data, code == "citec:identifiable" | code == "citec:unidentifiable")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

tempdata <- subset(data, code == "citec:findable_version" | code == "citec:unfindable_version")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

tempdata <- subset(data, code == "citec:permission_modify" | code == "citec:prohibited_modify")
tempdata <- droplevels(tempdata)
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

tempdata <- subset(data, code == "citec:access_free" | code == "citec:access_purchase" | code == "citec:no_access")
tempdata$code <- ordered(tempdata$code, levels=c("citec:no_access", "citec:access_free", "citec:access_purchase"))
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

tempdata <- subset(data, code == "citec:source_available" | code == "citec:source_unavailable")
tempdata$code <- ordered(tempdata$code, levels=c("citec:source_available", "citec:source_unavailable"))
ggplot(tempdata, aes(x=strata, fill=code)) + geom_bar() + scale_y_continuous(name = "Count of mentions") + scale_x_discrete(name = "strata impact factor (30 articles per strata)")

