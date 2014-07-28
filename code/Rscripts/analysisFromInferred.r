library(rrdf)
library(ggplot2)
library(reshape2)
library(dplyr)

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")

inferredData = load.rdf("output/inferredStatements.ttl", format="TURTLE")

prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")

# Begin with analysis of mentions. 

# Then analysis of ArticleSoftwareLinks (identifiable/findable/credited)
# bioj:from_selection
# citec:from_mention      citec:a2001-40-MOL_ECOL-C05-mention ;
query <- "
SELECT ?article ?journal ?strata ?selection ?software_article_link ?credited ?findable ?identifiable
WHERE {
	?software_article_link 	rdf:type bioj:ArticleSoftwareLink;
							citec:is_credited       ?credited ;
							citec:is_findable       ?findable ;
							citec:is_identifiable   ?identifiable ;
	 						bioj:from_mention [ bioj:from_selection ?selection ] .
	?article bioj:has_selection ?selection ;
	         dc:isPartOf ?journal .
	?journal bioj:strata ?strata .
}
"

links <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))

# melt to vertical format.
mlinks <- melt(links, id=1:5)

# order factors
mlinks$variable <- factor(mlinks$variable,levels=c("identifiable","findable","credited"))
mlinks$value <- factor(mlinks$value,levels=c("true","false"))

ggplot(mlinks,aes(x=variable,fill=value)) +
geom_bar() +
facet_grid(.~strata,margins=T) +
scale_fill_grey(guide = guide_legend(title="")) + 
scale_x_discrete(name="") +
scale_y_continuous(name="Count of Software Article tuples") +
#ggtitle("Accessibility by strata") +
theme(
	legend.position="bottom",
    panel.grid.major.x = element_blank(),
	panel.grid.minor.y = element_blank(),
	panel.border = element_blank(),
	axis.title.y=element_text(vjust=0.3),
	#axis.title.x=element_text(vjust=0.1),
	text=element_text(size=10)
#	axis.text.x=element_blank(),
#	axis.ticks.x=element_blank()
 )
 
mlinks %.%
summarize(num=n_distinct(software_article_link))

##################
# Software analysis
# a                               bioj:SoftwarePackage ;
# rdfs:label                      "Macclade" ;
# bioj:mentioned_in               citec:a2007-27-CLADISTICS-C03-mention ;
# citec:is_accessible             true ;
# citec:is_explicitly_modifiable  false ;
# citec:is_free                   true ;
# citec:is_source_accessible      false .
#################
query <- "
SELECT ?software ?accessible ?modifiable ?free ?source
WHERE {
	?software	rdf:type                        bioj:SoftwarePackage ;
				citec:is_accessible             ?accessible  ;
				citec:is_explicitly_modifiable  ?modifiable  ;
				citec:is_free                   ?free        ;
				citec:is_source_accessible      ?source      ;
}
"

software <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))

software %.%
group_by(software) %.%
summarize(count = n()) %.%
filter(count > 1)

# melt to vertical format.
msoftware <- melt(software, id=1)


