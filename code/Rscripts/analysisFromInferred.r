library(rrdf)
library(ggplot2)
library(reshape2)
library(dplyr)

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

# Output goes to this file (using print)
sink("output/analysis_output.txt")

inferredData = load.rdf("output/inferredStatements.ttl", format="TURTLE")

prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")

####################
# Begin with analysis of mentions.
####################

query <- "
SELECT ?article ?journal ?strata ?selection ?mention ?category
WHERE {
	?mention rdf:type bioj:SoftwareMention ;
			 citec:mention_category [ rdfs:label ?category ] ;
   	 		 bioj:from_selection ?selection .
	?article bioj:has_selection ?selection ;
	         dc:isPartOf ?journal .
	?journal bioj:strata ?strata .
}
"

mentions <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))

articles_with_mentions <- summarise(mentions, article_count = n_distinct(article))[1,1]

cat("--------------------------\n")
cat("There were ")
cat(articles_with_mentions)
cat(" articles with mentions and ")
cat(90 - articles_with_mentions)
cat( " articles without.\n")

####################
# Which articles have mentions and how many do they have?
####################
cat("--------------\n")
cat("Counts of articles, mentions, and Journals\n")

mentions_by_strata <- mentions %.%
  group_by(strata) %.%
  summarize( journal_count = n_distinct(journal), 
             article_count = n_distinct(article), 
			 mention_count = n_distinct(selection))

print(mentions_by_strata)

cat("--------------\n")
cat("# Percentage of articles with mentions\n")

print(round(mentions_by_strata$article_count / 30,2))

####################
#  Mentions by strata boxplot
####################

mention_count_by_article <- mentions %.%
   group_by(strata,article) %.%
   summarize(  mention_count = n_distinct(selection)
   ) %.%
   arrange(desc(mention_count))

ggplot(mention_count_by_article,aes(x=strata,y=mention_count)) + geom_boxplot() + scale_y_continuous(name = "Mentions in article") + scale_x_discrete(name="Journal Impact Factor rank")

ggsave(filename="output/MentionsByStrataBoxplot.png", width=5, height=2)

cat("--------------------\n")
cat("Outputted Figure 1: MentionsByStrataBoxplot.png\n")
######################
# Mention classifications
#####################

# melt to vertical format.
mmentions <- melt(mentions, id=1:5)

# Arrange by order
mmentions$value <- factor(mmentions$value,levels=c("Cite to publication", "Cite to user manual", "Cite to name or website", "Like instrument" , "URL in text", "Name only", "Not even name"))

# 
cat("--------------\n")
cat("Table 3. Types of software mentions in publications\n")

print(mmentions %.%
group_by(value) %.%
summarize(num=n_distinct(mention)))

ggplot(mmentions,aes(x=value)) +
geom_bar() +
#facet_grid(.~strata,margins=T) +
scale_fill_grey(guide = guide_legend(title="")) +
scale_x_discrete(name="") +
scale_y_continuous(name="Count of Mentions") +
#ggtitle("Accessibility by strata") +
theme(legend.position="none",
      panel.grid.major.x = element_blank(),
	panel.grid.minor.y = element_blank(),
	panel.border = element_blank(),
	axis.title.y=element_text(vjust=0.3),
	axis.title.x=element_text(vjust=0.1),
	text=element_text(size=10),
	axis.text.x=element_text(angle=25,hjust=1)
	)

ggsave(filename="output/TypesOfSoftwareMentions.png", width=5, height=4)
cat("--------------------\n")
cat("Outputted Figure 2: TypesOfSoftwareMentions.png\n")

#
# # Then analysis of ArticleSoftwareLinks (identifiable/findable/credited)
# # bioj:from_selection
# # citec:from_mention      citec:a2001-40-MOL_ECOL-C05-mention ;
# query <- "
# SELECT ?article ?journal ?strata ?selection ?software_article_link ?credited ?findable ?identifiable
# #?version ?version_findable
# WHERE {
# 	?software_article_link 	rdf:type bioj:ArticleSoftwareLink;
# 							citec:is_credited       ?credited ;
# 							citec:is_findable       ?findable ;
# 							citec:is_identifiable   ?identifiable ;
# 						#	citec:has_version_indicator ?version ;
# 						#	citec:version_is_findable ?version_findable ;
# 	 						bioj:from_mention [ bioj:from_selection ?selection ] .
# 	?article bioj:has_selection ?selection ;
# 	         dc:isPartOf ?journal .
# 	?journal bioj:strata ?strata .
# }
# "
#
# links <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# # melt to vertical format.
# mlinks <- melt(links, id=1:5)
#
# # order factors
# mlinks$variable <- factor(mlinks$variable,levels=c("identifiable","findable","credited"))
# mlinks$value <- factor(mlinks$value,levels=c("true","false"))
#
# ggplot(mlinks,aes(x=variable,fill=value)) +
# geom_bar() +
# facet_grid(.~strata,margins=T) +
# scale_fill_grey(guide = guide_legend(title="")) +
# scale_x_discrete(name="") +
# scale_y_continuous(name="Count of Software Article tuples") +
# #ggtitle("Accessibility by strata") +
# theme(
# 	legend.position="bottom",
#     panel.grid.major.x = element_blank(),
# 	panel.grid.minor.y = element_blank(),
# 	panel.border = element_blank(),
# 	axis.title.y=element_text(vjust=0.3),
# 	#axis.title.x=element_text(vjust=0.1),
# 	text=element_text(size=10)
# #	axis.text.x=element_blank(),
# #	axis.ticks.x=element_blank()
#  )
#
# mlinks %.%
# filter(variable=="version") %.%
# group_by(value) %.%
# summarize(num=n_distinct(software_article_link))
#
# mlinks %.%
# filter(variable=="version_findable"|variable=="version") %.%
# group_by(variable) %.%
# summarize(num=n_distinct(software_article_link))
#
# mlinks %.%
# summarize(num=n_distinct(software_article_link))
#
# total_mentions = summarize(mlinks, n_distinct(software_article_link))[1,1]
#
# mlinks %.%
# filter(value=="true") %.%
# group_by(variable) %.%
# summarize(num=n_distinct(software_article_link),
# 	      percent=round( num / total_mentions, 2 ) )
#
#
# ##################
# # Software analysis
# # a                               bioj:SoftwarePackage ;
# # rdfs:label                      "Macclade" ;
# # bioj:mentioned_in               citec:a2007-27-CLADISTICS-C03-mention ;
# # citec:is_accessible             true ;
# # citec:is_explicitly_modifiable  false ;
# # citec:is_free                   true ;
# # citec:is_source_accessible      false .
# #################
# query <- "
# SELECT ?software ?accessible ?modifiable ?free ?source
# WHERE {
# 	?software	rdf:type                        bioj:SoftwarePackage ;
# 				citec:is_accessible             ?accessible  ;
# 				citec:is_explicitly_modifiable  ?modifiable  ;
# 				citec:is_free                   ?free        ;
# 				citec:is_source_accessible      ?source      ;
# }
# "
#
# software <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# # melt to vertical format.
# msoftware <- melt(software, id=1)
#
# total_software = summarize(msoftware, n_distinct(software))[1,1]
#
# msoftware %.%
# filter(value=="true") %.%
# group_by(variable) %.%
# summarize(num=n_distinct(software),
# 	      percent=round( num / total_software, 2 ) )
#
#
# # Ok, across the three units of analysis (Mentions, ArticleSoftwareLinks, SoftwarePackages), need percentages for each of the tags.
#
# tags <- c("identifiable","findable","accessible","source","modifiable")
#
# # for each tag, need the percentage of whatever the unit of analysis was.
#
#

sink()
closeAllConnections()
