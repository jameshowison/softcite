library(rrdf)
library(ggplot2)
library(dplyr)

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

softciteData = load.rdf("data/SoftwareCitationDataset.ttl", format="TURTLE")

summarize.rdf(softciteData)
prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")

# Sample summary statistics
no_codes_query <- paste(readLines("code/Rscripts/all_data_no_codes.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

code_matrix <- sparql.rdf(softciteData, paste(prefixes, no_codes_query, collapse=" "))

data <- data.frame(code_matrix)

data %.%
  group_by(strata) %.%
  summarise(freq=count_distinct(journal_title))

data %.% 
  group_by(journal_title) %.% 
  summarise(freq = length(unique(article))) %.% 
  arrange(desc(freq))
  
  data %.% 
    group_by(stata,journal_title) %.% 
    summarise(freq = length(unique(article))) %.% 
    arrange(desc(freq))
	

all_codes_query <- paste(readLines("code/Rscripts/all_codes_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

code_matrix <- sparql.rdf(softciteData, paste(prefixes, all_codes_query, collapse=" "))

data <- data.frame(code_matrix)

############
# Overall summary
############

data %.%
  summarize( journal_count = n_distinct(journal), 
             article_count = n_distinct(article), 
			 mention_count = n_distinct(selection)
			)

############
# Summary by strata
############

mentions_by_strata <- data %.%
  group_by(strata) %.%
  summarize( journal_count = n_distinct(journal), 
             article_count = n_distinct(article), 
			 mention_count = n_distinct(selection)
			)

# Percentage of articles with mentions
round(mentions_by_strata$article_count / 30,2)

############
# Summary by journal, sorted
###########
data %.%
  group_by(journal) %.%
  summarize( article_count = n_distinct(article), 
			 mention_count = n_distinct(selection)
			) %.%
  arrange(desc(mention_count))
  
########
# Summary by article, sorted by mention_count
##########
data %.%
  group_by(strata,article) %.%
  summarize(  mention_count = n_distinct(selection)
			) %.%
  arrange(desc(mention_count))
  
  
  

##########
# Graphic of mention_count per article, split by strata.
# This turns out to be tricky, because you want a bar_plot, where the x axis is article
# the y axis is a count of mentions, but the ordering of the x axis is based on the count 
# of mentions.  Easier to use the grouped df and stat="identity" than to use stat="bin"
##########

mention_count_by_article <- data %.%
    group_by(strata,article) %.%
    summarize(  mention_count = n_distinct(selection)
    ) %.%
    arrange(desc(mention_count))
	
# Arrange(desc(mention_count)) doesn't actually produce an ordered factor	
# but that's what we need.

mention_count_by_article$article <- with(mention_count_by_article, reorder(article,-mention_count))
	
ggplot(mention_count_by_article,aes(x=article,y=mention_count)) + geom_bar(stat="identity") + facet_wrap(~strata) + scale_x_discrete(labels=c())

# Alternative, to answer the question of what was the distribution of mentions by article.

ggplot(mention_count_by_article,aes(x=strata,y=mention_count)) + geom_boxplot() + scale_y_continuous(name = "Mentions in article") + scale_x_discrete(name="Journal Impact Factor rank")

ggsave(filename="output/MentionsByStrataBoxplot.png", width=5, height=2)

#########################
# Types of mentions
########################

# with citations.

# mention with domain publication

query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
	?article dc:isPartOf ?journal .
	?journal bioj:strata ?strata .
	?selection bioj:has_reference ?ref .
  	?ref ca:isTargetOf [ ca:appliesCode [ rdf:type citec:domain_publication  ] ] .
}
"

temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "cite_to_domain_pub"

types <- temp
 
# Citation to user manual
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
	?article dc:isPartOf ?journal .
	?journal bioj:strata ?strata .
	?selection bioj:has_reference ?ref .
  	?ref ca:isTargetOf [ ca:appliesCode [ rdf:type citec:software_publication  ] ] .
}
"
temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "cite_to_software_pub"

types <- rbind(types,temp)

# citation to project_name
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
	?article dc:isPartOf ?journal .
	?journal bioj:strata ?strata .
	?selection bioj:has_reference ?ref .
  	?ref ca:isTargetOf [ ca:appliesCode [ rdf:type citec:project_name  ] ] .
}
"

temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "cite_to_project_name"

types <- rbind(types,temp)

# citation to project page.
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
	?article dc:isPartOf ?journal .
	?journal bioj:strata ?strata .
	?selection bioj:has_reference ?ref .
  	?ref ca:isTargetOf [ ca:appliesCode [ rdf:type citec:project_page  ] ] .
}
"
temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "cite_to_project_page"

types <- rbind(types,temp)


# Instrument style citation
#in-text_mention, software_name, creator, no has_ref
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
  ?article dc:isPartOf ?journal .
  ?journal bioj:strata ?strata .
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:in-text_mention ] ] . 
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:software_name ] ] .
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:creator ] ] .
  MINUS { ?selection bioj:has_reference ?ref }
}
"
temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "like_instrument"

types <- rbind(types,temp)

# Name and URL
#in-text_mention, software_name, URL, no has_ref
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
  ?article dc:isPartOf ?journal .
  ?journal bioj:strata ?strata .
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:in-text_mention ] ] . 
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:software_name ] ] .
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:url] ] .
  MINUS { ?selection bioj:has_reference ?ref }
  MINUS {  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:creator] ] . }
}
"

temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "url_in_text"

types <- rbind(types,temp)

# Name only
#in-text_mention, software_name, no has_ref, no URL, no creator
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
  ?article dc:isPartOf ?journal .
  ?journal bioj:strata ?strata .
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:in-text_mention ] ] . 
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:software_name ] ] .
  MINUS { ?selection bioj:has_reference ?ref }
  MINUS { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:creator ] ] . }
  MINUS { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:url ] ] .}
}
"

temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "name_only"

types <- rbind(types,temp)

# not even by name
#in-text_mention, no ref, no creator, no software_name, no url
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
  ?selection bioj:full_quote ?fullquote .
  ?article dc:isPartOf ?journal .
  ?journal bioj:strata ?strata .
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:in-text_mention ] ] . 
  MINUS { ?selection bioj:has_reference ?ref }
  MINUS { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:creator ] ] . }
  MINUS { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:url ] ] .}
  MINUS { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:software_name ] ] .}
}
"

temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "not_even_name"

types <- rbind(types,temp)





#################
#  Percent Agreement, between cgrady and jhowison as coders
#  Uses data from different files.
#################

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

catherineCoding = load.rdf("data/agreement_testing/Round1-SeeingMentions/JamesCatherine/CatherineCoding.ttl", format="TURTLE")

jamesCoding = load.rdf("data/agreement_testing/Round1-SeeingMentions/JamesCatherine/JamesCoding.ttl", format="TURTLE")

combindedCoding = combine.rdf(jamesCoding,catherineCoding)

#summarize.rdf(combindedCoding)  # 2432 triples

#combindedCoding = load.rdf("data/agreement_testing/Round1-SeeingMentions/testingMatchesQueries.ttl", format="TURTLE")

# Ok, need to get three numbers.  Both agreeing, J not C, and C not J.

# One useful format:
# URL, J, C 
# ..., coded, coded 
# ..., not-coded, coded

agreement_query <- paste(readLines("code/Rscripts/catherine_james_agree_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

agreement_urls <- sparql.rdf(combindedCoding, paste(prefixes, agreement_query, collapse=" "))

james_only_query <- paste(readLines("code/Rscripts/james_only_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

james_only_urls <- sparql.rdf(combindedCoding, paste(prefixes, james_only_query, collapse=" "))

catherine_only_query <- paste(readLines("code/Rscripts/catherine_only_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

catherine_only_urls <- sparql.rdf(combindedCoding, paste(prefixes, catherine_only_query, collapse=" "))

# combine lists into frame.
agreement_data_both <- data.frame("urls" = agreement_urls, "james" = 1, "catherine" = 1)

agreement_data_james <- data.frame("urls" = james_only_urls, "james" = 1, "catherine" = 0)

agreement_data_catherine <- data.frame("urls" = catherine_only_urls, "james" = 0, "catherine" = 1)

agreement_data <- rbind(agreement_data_both, agreement_data_james)
agreement_data <- rbind(agreement_data, agreement_data_catherine)

library(irr)

agree(agreement_data[,2:3])

##########################################
# Percent agreement. James and Julia.
#########################################

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

juliaCoding = load.rdf("data/agreement_testing/Round1-SeeingMentions/JamesJulia/JuliaCoding.ttl", format="TURTLE")

jamesCoding = load.rdf("data/agreement_testing/Round1-SeeingMentions/JamesJulia/JamesCoding.ttl", format="TURTLE")

combindedCoding = combine.rdf(jamesCoding,juliaCoding)

# ..., not-coded, coded

agreement_query <- paste(readLines("code/Rscripts/julia_james_agree_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

agreement_urls <- sparql.rdf(combindedCoding, paste(prefixes, agreement_query, collapse=" "))

james_only_query <- paste(readLines("code/Rscripts/james_only_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

james_only_urls <- sparql.rdf(combindedCoding, paste(prefixes, james_only_query, collapse=" "))

julia_only_query <- paste(readLines("code/Rscripts/julia_only_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

julia_only_urls <- sparql.rdf(combindedCoding, paste(prefixes, julia_only_query, collapse=" "))

# combine lists into frame.
agreement_data <- data.frame("urls" = agreement_urls, "james" = 1, "julia" = 1)

if (length(james_only_urls) > 0) {
  agreement_data_james <- data.frame("urls" = james_only_urls, "james" = 1, "julia" = 0)
  agreement_data <- rbind(agreement_data, agreement_data_james)
}

if (length(julia_only_urls) > 0) {
  agreement_data_julia <- data.frame("urls" = julia_only_urls, "james" = 0, "julia" = 1)
  agreement_data <- rbind(agreement_data, agreement_data_julia)
}

library(irr)

agree(agreement_data[,2:3])



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

=======
>>>>>>> External Changes
=======
>>>>>>> External Changes
