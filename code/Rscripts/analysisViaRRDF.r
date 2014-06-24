library(rrdf)
library(ggplot2)
library(reshape2)
library(dplyr)
library(irr)

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

softciteData = load.rdf("data/SoftwareCitationDataset.ttl", format="TURTLE")

#summarize.rdf(softciteData)
prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")

# Sample summary statistics
no_codes_query <- paste(readLines("code/Rscripts/all_data_no_codes.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

code_matrix <- sparql.rdf(softciteData, paste(prefixes, no_codes_query, collapse=" "))

data <- data.frame(code_matrix)

# data %.%
#   group_by(strata) %.%
#   summarise(freq=count_distinct(journal_title))
#
# data %.%
#   group_by(journal_title) %.%
#   summarise(freq = length(unique(article))) %.%
#   arrange(desc(freq))
#
#   data %.%
#     group_by(stata,journal_title) %.%
#     summarise(freq = length(unique(article))) %.%
#     arrange(desc(freq))
#

all_codes_query <- paste(readLines("code/Rscripts/all_codes_query.sparql", warn=FALSE, encoding="UTF-8"), collapse=" ")

code_matrix <- sparql.rdf(softciteData, paste(prefixes, all_codes_query, collapse=" "))

data <- data.frame(code_matrix)

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

agree(agreement_data[,2:3])


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

#mention_count_by_article$article <- with(mention_count_by_article, reorder(article,-mention_count))
	
#ggplot(mention_count_by_article,aes(x=article,y=mention_count)) + geom_bar(stat="identity") + facet_wrap(~strata) + scale_x_discrete(labels=c())

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

#temp$mention_type <- "cite_to_domain_pub"
temp$mention_type <- "Cite to publication"

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

temp$mention_type <- "Cite to publication"

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

#temp$mention_type <- "cite_to_project_name"
temp$mention_type <- "Cite to name"

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

#temp$mention_type <- "cite_to_project_page"
temp$mention_type <- "Cite to name"

# users_manual
types <- rbind(types,temp)

query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
	?article dc:isPartOf ?journal .
	?journal bioj:strata ?strata .
	?selection bioj:has_reference ?ref .
  	?ref ca:isTargetOf [ ca:appliesCode [ rdf:type citec:users_manual  ] ] .
}
"
temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "Cite to manual"

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
    FILTER NOT EXISTS { ?selection bioj:has_reference ?ref }
}
"
temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "Like instrument"

types <- rbind(types,temp)

# special type for bioj:a2009-35-NAT_BIOTECHNOL-C06  / C-05. This is "Zeiss software" has a creator but no software name.
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
    ?article bioj:has_selection ?selection .
    ?article dc:isPartOf ?journal .
    ?journal bioj:strata ?strata .
    ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:in-text_mention ] ] . 
    ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:creator ] ] .
	FILTER NOT EXISTS { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:software_name ] ] . }
    FILTER NOT EXISTS { ?selection bioj:has_reference ?ref }
}
"
temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

#temp$mention_type <- "Like instrument_no_name"
temp$mention_type <- "Like instrument"

types <- rbind(types,temp)



# Name and URL
#in-text_mention, URL, no has_ref
# Some, including bioj:a2006-47-SYST_BIOL-C02 don't have software_name but have a URL.
query <- "
SELECT ?selection ?article ?journal ?strata
WHERE {
  ?article bioj:has_selection ?selection .
  ?article dc:isPartOf ?journal .
  ?journal bioj:strata ?strata .
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:in-text_mention ] ] . 
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:url] ] .
  FILTER NOT EXISTS  { ?selection bioj:has_reference ?ref }
  FILTER NOT EXISTS  {  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:creator] ] . }
}
"

temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "URL in text"

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
  FILTER NOT EXISTS  { ?selection bioj:has_reference ?ref }
  FILTER NOT EXISTS  { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:creator ] ] . }
  FILTER NOT EXISTS  { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:url ] ] .}
}
"

temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "Name only"

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
  FILTER NOT EXISTS  { ?selection bioj:has_reference ?ref }
  FILTER NOT EXISTS  { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:creator ] ] . }
  FILTER NOT EXISTS  { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:url ] ] .}
  FILTER NOT EXISTS  { ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:software_name ] ] .}
}
"

temp <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

temp$mention_type <- "No name"

types <- rbind(types,temp)



mention_type_levels <- c("Cite to publication",
						 "Cite to name",
						 "Cite to manual",
						 "Like instrument",
						 "URL in text",
						 "Name only",
						 "No name")
						 
types$mention_type <- factor(types$mention_type, levels=mention_type_levels)



# Graph totals for mention types.
ggplot(types,aes(x=mention_type)) + 
  geom_bar() + 
 # scale_y_continuous(name="Proportion",limits=c(0,0.5)) +
  scale_x_discrete(name="Mention Type") +
 # scale_fill_grey() + 
  theme(legend.position="none",
        panel.grid.major.x = element_blank(),
		panel.grid.minor.y = element_blank(),
		panel.border = element_blank(),
		axis.title.y=element_text(vjust=0.3),
		axis.title.x=element_text(vjust=0.1),
		text=element_text(size=10),
		axis.text.x=element_text(angle=25,hjust=1)) +
  ggtitle("Types of software mentions")

ggsave(filename="output/MentionTypesOverall.png", width=5, height=4)

# Table for software mentions, including proportions
total_mentions <- n_distinct(types$selection)

types %.%
group_by(mention_type) %.%
summarize(num_type = n_distinct(selection), 
          proportion = round(num_type / total_mentions, 2) ) %.%
arrange(desc(num_type))

# Mentions by strata
mentions_by_strata <- types %.% group_by(strata) %.%
summarize(total_in_strata = n_distinct(selection))

types_by_strata <- types %.%
group_by(strata, mention_type) %.%
summarize(type_in_strata = n_distinct(selection))

types_by_strata <- merge(types_by_strata,mentions_by_strata)

types_by_strata <- within(types_by_strata, proportion <- round(type_in_strata / total_in_strata, 2))

# Count By strata, cahgne from long format to wide format.
dcast(types_by_strata,mention_type~strata,sum,value.var="type_in_strata")
#           mention_type 1-10 11-110 111-1455
# 1 Cite to name    2      8        6
# 2  Cite to publication   47     34       24
# 3 Cite to manual    3      0        3
# 4      Like instrument   33     14        5
# 5            Name only   36     25       28
# 6        Not even name    3      1        0
# 7          URL in text    6      7        0

# > dcast(types_by_strata,mention_type~strata,sum,value.var="proportion")
#           mention_type 1-10 11-110 111-1455
# 1 Cite to name 0.02   0.09     0.09
# 2  Cite to publication 0.36   0.38     0.37
# 3 Cite to manual 0.02   0.00     0.05
# 4      Like instrument 0.25   0.16     0.08
# 5            Name only 0.28   0.28     0.43
# 6        Not even name 0.02   0.01     0.00
# 7          URL in text 0.05   0.08     0.00

#ggplot(types_by_strata,aes(y=mention_type,x=strata)) + geom_tile(aes(fill=proportion), color="white") + scale_fill_gradient(low="white",high="steelblue")


# reverse levels back for faceted presentation
#types_by_strata$mention_type <- factor(types_by_strata$mention_type, 
	                           # levels = mention_type_levels)
#ggplot(types_by_strata,aes(x=mention_type,y=proportion)) + geom_bar(stat="identity") + facet_grid(strata~.)

# Ok, try a dodge bar chart.

#ggplot(types_by_strata,aes(x=mention_type,y=proportion,fill=strata)) + geom_bar(stat="identity",position="dodge") + theme(axis.text.x = element_text(size = rel(1.5), angle = 45, hjust = 1)) + scale_fill_grey()

#ggplot(types_by_strata,aes(x=strata,y=proportion,fill=strata)) + geom_bar(stat="identity",position="dodge") + facet_wrap(~mention_type,nrow=2,ncol=4) + scale_fill_grey() + scale_y_continuous(limits=c(0,1))

# Ok, this one is the one to use.  First drop the lower proportion mention_types

types_for_graph <- filter(types_by_strata, mention_type %in% c("Cite to publication","Like instrument","Name only"))
# Then graph as dodged bars?
ggplot(types_for_graph,aes(x=strata,y=proportion,fill=strata)) + 
  geom_bar(stat="identity") + 
  facet_grid(.~mention_type) + 
  scale_y_continuous(name="Proportion",limits=c(0,0.5)) +
  scale_x_discrete(name="Strata") +
  scale_fill_grey() + 
  theme(legend.position="none",
        panel.grid.major.x = element_blank(),
		panel.grid.minor.y = element_blank(),
		panel.border = element_blank(),
		axis.title.y=element_text(vjust=0.3),
		axis.title.x=element_text(vjust=0.1),
		text=element_text(size=10),
		axis.text.x=element_text(angle=25,hjust=1)) +
  ggtitle("Major software mention types by journal strata")
  
ggsave(filename="output/MentionTypesByStrata.png", width=5, height=4)

#########################
# Move to individual codes.
##########################

# First, most of these only really make sense at an article-software combo, since
# many of the mentions are for the same pieces of software.

# How many pieces of software mentioned.  Unique values of software_name label.
query <- "
SELECT ?selection ?article ?journal ?strata ?software_name
WHERE {
  ?article bioj:has_selection ?selection .
  ?article dc:isPartOf ?journal .
  ?journal bioj:strata ?strata .
  ?selection ca:isTargetOf [ ca:appliesCode [ rdf:type citec:software_name ; rdfs:label ?software_name ] ] . 
}
"

software_names <- data.frame(sparql.rdf(softciteData, paste(prefixes, query, collapse=" ")))

# Going to need to search for those that are similar too.
# get just list of names and make all lower case.
all_names <- to.lower(unique(software_names$software_name))

# Make dissimilarity matrix
stringdisttest <- stringdistmatrix(all_names,all_names,method="jw",p=0.1)
# Perform clustering using this matrix
nameCluster<-agnes(stringdisttest,diss=T)
# cut the tree down low (ie make 6 groups)
name_cluster_labels <- cutree(nameCluster,k=13)
culstered_names <- data.frame(software_name = all_names, cluster_label = name_cluster_labels)
arrange(culstered_names,cluster_label)

# Make a copy
software_names$standardized_name <- software_names$software_name

# Replace if a match
name_mappings <- list(
	"Image J"             = c("ImageJ"),
	"Excel"               = c("excel"),
	"BLAST"               = c("Basic Local Alignment Search Tool (BLAST)",
	                          "TBLASTN",
							  "BLASTP",
							  "BLASTX",
							  "BLASTN"),
	"SAS"                 = c("Statistical Analysis Software"),
	"Stereo Investigator" = c("StereoInvestigator"),
	"USeq"                = c("USeq IntersectLists",
	                          "USeq IntersectRegions",
							  "USeq AggregatePlots",
							  "USeq FNG"),
	"PAUP"                = c("PAUP*"),
	"ClustalW"            = c("CLUSTAL W",
							  "CLUSTALW",
							  "ClustalX")
)

# replace_name <- function(replacement) {
# 	software_names$standardized_name <- replace(software_names$standardized_name,
# 				  software_names$software_name %in% name_mappings[[replacement]],
# 				  replacement)
#
# }
#
# lapply(names(name_mappings), replace_name)

for (i in 1:length(name_mappings)) {
	replacement <- names(name_mappings[i])
	items_to_replace <- name_mappings[i][[replacement]]
	software_names$standardized_name <- replace(software_names$standardized_name, 
		                                        software_names$software_name %in% items_to_replace, 
												replacement)
}

#software_names %.%
#filter(standardized_name != software_name) %.%
#arrange(standardized_name)

software_names %.%
group_by(standardized_name) %.%
summarize(num_articles = n_distinct(article)) %.%
arrange(desc(num_articles))



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
