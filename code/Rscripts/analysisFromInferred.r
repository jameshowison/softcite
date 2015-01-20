#library(scimapClient)
library(rrdf)
library(ggplot2)
library(reshape2)
library(plyr)
library(dplyr)
library(scales)


#scimapRegister()

# Clear namespaces
rm(list = ls())

setwd("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/")
#source("code/Rscripts//analysisFromInferred.r")

inferredData = load.rdf("output/inferredStatements.ttl", format="TURTLE")

prefixes <- paste(readLines("code/Rscripts/sparql_prefixes.sparql", encoding="UTF-8"), collapse=" ")

global_fig_counter = 1

# # Output goes to this file (using print)
# sink("output/fig-analysis_output.txt")
#

#
# ####################
# # Begin with analysis of mentions.
# ####################
#
# # empty functions are just for TextMate Sectioning
# HowManyMentions <- function() {}
#
# article_count = 90
#
# query <- "
# SELECT ?article ?journal ?strata ?selection ?mention ?category
# WHERE {
# 	?mention rdf:type bioj:SoftwareMention ;
# 			 citec:mention_category [ rdfs:label ?category ] ;
#    	 		 bioj:from_selection ?selection .
# 	?article bioj:has_selection ?selection ;
# 	         dc:isPartOf ?journal .
# 	?journal bioj:strata ?strata .
# }
# "
#
# mentions <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# articles_with_mentions <- summarise(mentions, article_count = n_distinct(article))[1,1]
#
# cat("--------------------------\n")
# cat("There were ")
# cat(articles_with_mentions)
# cat(" articles with mentions and ")
# cat(article_count - articles_with_mentions)
# cat( " articles without.\n")
#
# conf_interval <- prop.test(articles_with_mentions,article_count)$conf.int
#
#
# cat("At a confidence interval of 95%, the proportion of articles in the population that mention software is between ")
# cat(round(conf_interval[1],2))
# cat(" and ")
# cat(round(conf_interval[2],2))
# cat("\n")
#
#
# ####################
# # Which articles have mentions and how many do they have?
# ####################
# HowManyArticlesHaveMentions <- function() {}
#
# cat("--------------\n")
# cat("Counts of articles, mentions, and Journals\n")
#
# mentions_by_strata <- mentions %>%
#   group_by(strata) %>%
#   summarize( journal_count = n_distinct(journal),
#              article_count = n_distinct(article),
# 			 mention_count = n_distinct(selection))
#
# print(mentions_by_strata)
#
# cat("--------------\n")
# cat("# Percentage of articles with mentions\n")
#
# print(round(mentions_by_strata$article_count / 30,2))
#
# cat("--------------\n")
# cat("In total we found ")
# cat(summarize(mentions, count = n_distinct(mention))[1,1])
# cat(" mentions\n")
#
#
# ####################
# #  Mentions by strata boxplot (note that this excludes articles with zero mentions)
# ####################
# Fig1MentionsByStrata <- function() {}
#
# mention_count_by_article <- mentions %>%
#    group_by(strata,article) %>%
#    summarize(  mention_count = n_distinct(selection)) %>%
#    arrange(desc(mention_count))
#
# ggplot(mention_count_by_article,aes(x=strata,y=mention_count)) +
#  geom_boxplot() +
#  scale_y_continuous(name = "Mentions in article") +
#  scale_x_discrete(name="Journal Impact Factor rank")
#
# ggsave(filename="output/fig-Fig1-MentionsByStrataBoxplot.png", width=5, height=4)
#
# cat("--------------------\n")
# cat("Outputted Figure 1: MentionsByStrataBoxplot.png\n")
#
#
# ######################
# # Mention classifications
# #####################
# Fig2MentionsClassifications <- function() {}
#
# # melt to vertical format.
# mmentions <- melt(mentions, id=1:5)
#
# # Arrange by order
# mmentions$value <- factor(mmentions$value,levels=c("Cite to publication", "Cite to user manual", "Cite to name or website", "Like instrument" , "URL in text", "Name only", "Not even name"))
#
# #
# cat("--------------\n")
# cat("Table 3. Types of software mentions in publications\n")
#
# total_mentions <- nrow(mentions)
#
# mentions_overall <- mmentions %>%
# group_by(value) %>%
# summarize(num=n_distinct(mention),
#           proportion = round(n_distinct(mention) / total_mentions, 2)
# 	  )
#
# mentions_overall <- ddply(mentions_overall,c("value"),transform,
#                       conf_int_low = round(prop.test(num,total_mentions)$conf.int[1],2),
# 					conf_int_high = round(prop.test(num,total_mentions)$conf.int[2],2)
# 					)
#
# print(mentions_overall)
#
# ggplot(mentions_overall,aes(x=value,y=proportion)) +
# geom_bar(stat="identity",fill="darkgray") +
# geom_errorbar(aes(ymin=conf_int_low, ymax=conf_int_high),
#               width=.2,                    # Width of the error bars
#               position=position_dodge(.9)) +
# #facet_grid(.~strata,margins=T) +
# scale_fill_grey(guide = guide_legend(title="")) +
# scale_x_discrete(name="") +
# scale_y_continuous(name="Proportion of Mentions") +
# #ggtitle("Accessibility by strata") +
# theme(legend.position="none",
#       panel.grid.major.x = element_blank(),
# 	panel.grid.minor.y = element_blank(),
# 	panel.border = element_blank(),
# 	axis.title.y=element_text(vjust=0.3),
# 	axis.title.x=element_text(vjust=0.1),
# 	text=element_text(size=10),
# 	axis.text.x=element_text(angle=25,hjust=1)
# 	)
#
# ggsave(filename="output/fig-Fig2-TypesOfSoftwareMentions.png", width=5, height=4)
# cat("--------------------\n")
# cat("Outputted Figure 2: TypesOfSoftwareMentions.png\n")
#
# ####################
# # Major mention types by strata.
# ####################
# Fig3MentionTypesByStrata <- function() {}
# # Table for software mentions, including proportions
# # total_mentions <- n_distinct(mentions$selection)
#
# # Want proportions of each type within its strata.
#
# # Get total in strata
# mentions_by_strata <- mentions %>% group_by(strata) %>%
# summarize(total_in_strata = n_distinct(selection))
#
# #     strata total_in_strata
# # 1     1-10             130
# # 2   11-110              89
# # 3 111-1455              65
#
# # Count number of each category in each strata
# types_by_strata <- mentions %>%
# group_by(strata, category) %>%
# summarize(type_in_strata = n_distinct(selection))
#
# #      strata                category type_in_strata
# # 1      1-10 Cite to name or website              2
# # 2      1-10     Cite to publication             47
# # 6      1-10           Not even name              3
# # 7      1-10             URL in text              6
# # 8    11-110 Cite to name or website              8
# # 9    11-110     Cite to publication             34
#
# # Add the total for that strata to each row, to be used to create percentage
# types_by_strata <- merge(types_by_strata,mentions_by_strata)
#
# # create the percentage for each row.
# types_by_strata <- within(types_by_strata, proportion <- round(type_in_strata / total_in_strata, 2))
#
# # create confidence intervals
# types_for_graph <- filter(types_by_strata, category %in% c("Cite to publication","Like instrument","Name only"))
#
# types_for_graph <- ddply(types_for_graph,c("strata","category"),transform,
#                         conf_int_low = prop.test(type_in_strata,total_in_strata)$conf.int[1],
# 						conf_int_high = prop.test(type_in_strata,total_in_strata)$conf.int[2]
# 						)
#
# #ddply(types_by_strata,c("strata","category"),transform, conf_int_high = prop.test(type_in_strata,total_in_strata)$conf.int[2])
# #types_by_strata <- within(types_by_strata, conf_low <- prop.test(type_in_strata,total_in_strata)$conf.int[1])
#
# # This would give you a usable table to show these data
# # dcast(types_by_strata, category ~ strata , sum, value.var="type_in_strata")
#
# # reduce to just the 'major categories
# #types_for_graph <- filter(types_by_strata, category %in% c("Cite to publication","Like instrument","Name only"))
#
# # Then graph as dodged bars with errorbars.
# ggplot(types_for_graph,aes(x=strata,y=proportion,fill=strata)) +
#   geom_bar(stat="identity") +
#   geom_errorbar(aes(ymin=conf_int_low, ymax=conf_int_high),
#                 width=.2,                    # Width of the error bars
#                 position=position_dodge(.9)) +
#   facet_grid(.~category) +
#   scale_y_continuous(name="Proportion",limits=c(0,max(types_for_graph$conf_int_high))) +
#   scale_x_discrete(name="Strata") +
#   scale_fill_grey() +
#   theme(legend.position="none",
#         panel.grid.major.x = element_blank(),
# 		panel.grid.minor.y = element_blank(),
# 		panel.border = element_blank(),
# 		axis.title.y=element_text(vjust=0.3),
# 		axis.title.x=element_text(vjust=0.1),
# 		text=element_text(size=10),
# 		axis.text.x=element_text(angle=25,hjust=1)) +
#   ggtitle("Major software mention types by journal strata")
#
# ggsave(filename="output/fig-Fig3-MentionTypesByStrata.png", width=5, height=4)
# cat("--------------------\n")
# cat("Outputted Figure 3: MentionTypesByStrata.png\n")
#
# #types_for_graph <- dcast(filter(types_for_graph, value=="true"),variable ~ strata , sum , value.var="count")
#
# #chisq.test(types_for_graph)
#
# cat("\n\n--------------------\n")
# cat("Do commercial packages drive 'like instrument")
#
# query <- "
# SELECT ?mention ?software ?cite_category
# WHERE {
# 	?software	rdf:type              bioj:SoftwarePackageUsed ;
# 				citec:is_accessible   true  ;
# 				citec:is_free         false ;
# 				rdfs:label            ?software_name ;
# 				bioj:mentioned_in  	  ?mention .
# 	?mention    citec:mention_category   [ rdfs:label ?cite_category]
# }
# "
#
# commercial_software <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# #View(commerical_software)
#
# commercial_software$software_type <- "Commercial"
#
# query <- "
# SELECT ?mention ?software ?cite_category
# WHERE {
# 	?software	rdf:type              bioj:SoftwarePackageUsed ;
# 				citec:is_accessible   true  ;
# 				citec:is_free         true ;
# 				citec:is_source_accessible true ;
# 				rdfs:label            ?software_name ;
# 				bioj:mentioned_in  	  ?mention .
# 	?mention    citec:mention_category   [ rdfs:label ?cite_category] ;
# 	}
# "
#
# oss_software <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# oss_software$software_type <- "No payment"
#
# # Note that this includes each mention, removal of duplicates.
# types_and_cites <- unique(rbind(commercial_software,oss_software))
#
# mentions_by_type <- types_and_cites %>% group_by(software_type) %>% summarize(total_of_type = n_distinct(mention))
#
# #     strata total_in_strata
# # 1     1-10             130
# # 2   11-110              89
# # 3 111-1455              65
#
# # Count number of each category in each strata
# software_types_by_cite_category <- types_and_cites %>% group_by(software_type, cite_category) %>% summarize(type_in_category = n_distinct(mention))
#
# #      strata                category type_in_strata
# # 1      1-10 Cite to name or website              2
# # 2      1-10     Cite to publication             47
# # 6      1-10           Not even name              3
# # 7      1-10             URL in text              6
# # 8    11-110 Cite to name or website              8
# # 9    11-110     Cite to publication             34
#
# # Add the total for that strata to each row, to be used to create percentage
# types_by_category <- merge(mentions_by_type,software_types_by_cite_category)
#
# types_by_category$cite_category <- gsub("Cite to name or website","Cite name/web",types_by_category$cite_category)
# types_by_category$cite_category <- gsub("Cite to publication","Cite publication",types_by_category$cite_category)
# types_by_category$cite_category <- gsub("Cite to user manual","Cite user manual",types_by_category$cite_category)
# # create the percentage for each row.
# types_by_category <- within(types_by_category, proportion <- round(type_in_category / total_of_type, 2))
#
# # create confidence intervals
# #types_by_category <- filter(types_by_strata, category %in% c("Cite to publication","Like instrument","Name only"))
#
# types_by_category <- ddply(types_by_category,c("software_type","cite_category"),transform,
#                         conf_int_low = prop.test(type_in_category,total_of_type)$conf.int[1],
# 						conf_int_high = prop.test(type_in_category,total_of_type)$conf.int[2]
# 						)
#
#
# ggplot(types_by_category,aes(x=software_type,y=proportion)) +
# geom_bar(stat="identity",fill="darkgrey") +
# geom_errorbar(aes(ymin=conf_int_low, ymax=conf_int_high),
#               width=.2,                    # Width of the error bars
#               position=position_dodge(.9)) +
# facet_grid(.~cite_category) +
# scale_fill_grey(guide = guide_legend(title="")) +
# scale_x_discrete(name="") +
# scale_y_continuous(name="Proportion of Mentions") +
# ggtitle("Type of citation by software type") +
# theme(legend.position="none",
#       panel.grid.major.x = element_blank(),
# 	panel.grid.minor.y = element_blank(),
# 	panel.border = element_blank(),
# 	axis.title.y=element_text(vjust=0.3),
# 	axis.title.x=element_text(vjust=0.1),
# 	text=element_text(size=10),
# 	strip.text = element_text(size=6),
# 	axis.text.x=element_text(angle=25,hjust=1)
# 	)
#
# ggsave(filename="output/fig-Fig4-CiteTypesBySoftwareTypes.png", width=5, height=4)
#
# #########################
# #
# #########################
# AreLikeInstrumentBetterAtCreditAndVersion <- function() {}
#
# cat("\n\n--------------------\n")
# cat("Do commercial packages drive 'like instrument")
#
# query <- "
# SELECT ?mention ?cite_category ?credited ?findable ?identifiable ?versioned
# WHERE {
# 	?mention    citec:mention_category   [ rdfs:label ?cite_category ] .
# 	?article_software_link  bioj:from_mention ?mention ;
# 	                        bioj:mentions_software ?software ;
# 					        citec:is_credited              ?credited ;
# 					        citec:is_findable              ?findable ;
# 					        citec:is_identifiable          ?identifiable ;
# 					        citec:is_versioned             ?versioned .
# }
# "
#
# mentions_category_and_functions <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
#
# mentions_category_and_functions <- unique(mentions_category_and_functions)
#
# # Of those in each category, how many were credited etc.
# category_totals <- mentions_category_and_functions %>% group_by(cite_category) %>% summarize(total_in_category = n())
#
# mfunctions <- melt(mentions_category_and_functions, id=1:2)
#
# # Count number of each function in each category
# function_counts <- mfunctions %>%
# filter(value == "true") %>%
# filter(cite_category %in% c("Cite to publication","Like instrument","Name only")) %>%
# group_by(cite_category,variable) %>%
# summarize(count = n())
#
# # Add the total for that strata to each row, to be used to create percentage
# mentions_by_cite_category <- merge(function_counts,category_totals)
#
# # create the percentage for each row.
# mentions_by_cite_category <- within(mentions_by_cite_category, proportion <- round(count / total_in_category, 2))
#
# mentions_by_cite_category <- ddply(mentions_by_cite_category,c("cite_category","variable"),transform,
#                         conf_int_low = prop.test(count,total_in_category)$conf.int[1],
# 						conf_int_high = prop.test(count,total_in_category)$conf.int[2]
# 						)
#
# #Order the factors for graphing
# mentions_by_cite_category$variable <- factor(mentions_by_cite_category$variable,levels=c("credited","identifiable","findable","versioned"))
#
# ggplot(mentions_by_cite_category,aes(x=cite_category,y=proportion)) +
# geom_bar(stat="identity",fill="darkgrey") +
# geom_errorbar(aes(ymin=conf_int_low, ymax=conf_int_high),
#               width=.2,                    # Width of the error bars
#               position=position_dodge(.9)) +
# facet_grid(.~variable) +
# scale_fill_grey(guide = guide_legend(title="")) +
# scale_x_discrete(name="") +
# scale_y_continuous(name="Proportion of Mentions") +
# ggtitle("Citation function by citation type") +
# theme(legend.position="none",
#       panel.grid.major.x = element_blank(),
# 	panel.grid.minor.y = element_blank(),
# 	panel.border = element_blank(),
# 	axis.title.y=element_text(vjust=0.3),
# 	axis.title.x=element_text(vjust=0.1),
# 	text=element_text(size=10),
# #	strip.text = element_text(size=6),
# 	axis.text.x=element_text(angle=25,hjust=1)
# 	)
#
#
# ###################
# # Summary of software mentioned
# ###################
# MostUsedSoftware <- function() {}
#
# query <- "
# SELECT ?article_link ?article ?software ?software_name
# WHERE {
# 	?article_link rdf:type bioj:ArticleSoftwareLink ;
# 	              bioj:mentions_software ?software ;
# 				  bioj:from_article ?article .
# 	?software rdfs:label ?software_name .
# }
# "
#
# software_with_names <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# software_in_articles <- software_with_names %>%
# group_by(software_name) %>%
# summarize(article_count = n_distinct(article))
#
# cat("--------------------\n")
# cat("Most used software\n")
#
# most_used <- software_in_articles %>%
# #filter(article_count > 1) %>%
# arrange(desc(article_count))
#
# cat(paste(most_used$software_name, collapse="\n"))
# cat("\n\n")
# cat(paste(most_used$article_count, collapse="\n"))
#
#
# HowManyPiecesOfSoftware <- function() {}
#
# query <- "
# SELECT DISTINCT ?software
# WHERE {
# 	?software rdf:type bioj:SoftwarePackage .
# }
# "
#
# software_packages <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
#
# cat("--------------------\n")
# cat("We found references to ")
# cat(nrow(software_packages))
# cat(" distinct pieces of software\n")
#
# # Then analysis of ArticleSoftwareLinks (identifiable/findable/credited)
#
# SoftwareAndArticles <- function() {}
#
# query <- "
# SELECT DISTINCT ?software_article_link
# WHERE {
# 	?software_article_link rdf:type bioj:ArticleSoftwareLink .
# }
# "
#
# article_links <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# total_links <- nrow(article_links)
#
# cat("--------------------\n")
# cat("there are  ")
# cat(nrow(article_links))
# cat("  unique combinations of software and articles\n")
#
#
#
# query <- "
# SELECT ?article ?journal ?strata ?software_article_link ?credited ?findable ?identifiable ?versioned ?version_findable
# WHERE {
# 	?software_article_link 	rdf:type bioj:ArticleSoftwareLink ;
# 							citec:is_credited       ?credited ;
# 							citec:is_findable       ?findable ;
# 							citec:is_identifiable   ?identifiable ;
# 							citec:is_versioned      ?versioned ;
# 							citec:version_is_findable ?version_findable ;
# 	 						bioj:from_article ?article .
# 	?article dc:isPartOf ?journal .
# 	?journal bioj:strata ?strata .
# }
# "
# #
# links <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# # Convert to %
# # get totals
# links_by_strata <- links %>% group_by(strata) %>%
# summarize(total_in_strata = n_distinct(software_article_link))
#
# # melt to vertical format.
# mlinks <- melt(links, id=1:4)
#
# # Count number of each category in each strata
# link_counts <- mlinks %>%
# group_by(strata,variable,value) %>%
# summarize(count = n())
#
# # Add the total for that strata to each row, to be used to create percentage
# links_by_strata <- merge(links_by_strata,link_counts)
#
# # create the percentage for each row.
# links_by_strata <- within(links_by_strata, proportion <- round(count / total_in_strata, 2))
#
# links_by_strata <- ddply(links_by_strata,c("strata","variable","value"),transform,
#                         conf_int_low = prop.test(count,total_in_strata)$conf.int[1],
# 						conf_int_high = prop.test(count,total_in_strata)$conf.int[2]
# 						)
#
#
#
# cat("--------------------\n")
# cat("ArticleSoftwareLinks and credited, findable, identifiable\n")
#
# links_by_strata_matrix <- dcast(filter(links_by_strata, value=="true"),variable ~ strata , sum , value.var="count")
#
# chisq.test(links_by_strata_matrix[,2:4],simulate.p.value=T)
#
#
# print(dcast(filter(links_by_strata, value=="true"),variable ~ strata , mean , value.var="proportion"))
#
#
#
# cat("Overall, with confidence intervals\n")
#
# all_link_counts <- mlinks %>% group_by(variable,value) %>% summarize(count = n())
#
# all_link_counts <- within(all_link_counts, proportion <- round(count / total_links, 2))
#
# ddply(all_link_counts,c("variable","value"),transform, conf_int_low = prop.test(count,total_links)$conf.int[1],
# 						conf_int_high = prop.test(count,total_links)$conf.int[2] )
#
#
#
# has_version_info <- nrow(filter(links,versioned == "true"))
#
# versions_found <- nrow(filter(links,versioned == "true" & version_findable == "true"))[1]
#
# cat("\nprovided any version information: ")
# cat(has_version_info)
# cat(" percent: ")
# cat(round(has_version_info/nrow(article_links),2))
# cat("\n")
# cat("provided any version information and could be found: ")
# cat(versions_found)
# cat(" percent: ")
# cat(round(versions_found/nrow(article_links),2))
# cat("\n")
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
# SELECT ?strata ?software ?accessible ?modifiable ?source ?free
# WHERE {
# 	?software	rdf:type                        bioj:SoftwarePackageUsed ;
# 				bioj:mentioned_in	[ bioj:article_software_link [ bioj:from_article [ dc:isPartOf [ bioj:strata ?strata ]]]];
# 				citec:is_accessible             ?accessible  ;
# 				citec:is_explicitly_modifiable  ?modifiable  ;
# 				citec:is_source_accessible      ?source      .
# 	OPTIONAL { ?software citec:is_free          ?free  }
#
# }
# "
#
# software <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
# #
# # # melt to vertical format.
# msoftware <- melt(software, id=1:2)
# #
# total_software = summarize(msoftware, n_distinct(software))[1,1]
#
# cat("--------------------\n")
# cat("there are  ")
# cat(total_software)
# cat("  software packages used across our paper sample\n")
#
# #
# software_overall <- msoftware %>%
# filter(value=="true") %>%
# group_by(variable) %>%
# summarize(num=n_distinct(software),
# 	      percent=round( num / total_software, 2 ) )
#
#
# ddply(software_overall,c("variable"),transform, conf_int_low = prop.test(num,total_software)$conf.int[1],
# 		  						conf_int_high = prop.test(num,total_software)$conf.int[2] )
#
# # Do these across strata, but need totals in strata.
# # Get total in strata
# software_by_strata_totals <- software %>% group_by(strata) %>%
# summarize(total_in_strata = n_distinct(software))
#
# #     strata total_in_strata
# # 1     1-10             130
# # 2   11-110              89
# # 3 111-1455              65
#
# # Count number of each category in each strata
# software_by_strata <- msoftware %>%
# filter(value=="true") %>%
# group_by(variable,strata) %>%
# summarize(software_in_strata = n_distinct(software))
#
# #      strata                category type_in_strata
# # 1      1-10 Cite to name or website              2
# # 2      1-10     Cite to publication             47
# # 6      1-10           Not even name              3
# # 7      1-10             URL in text              6
# # 8    11-110 Cite to name or website              8
# # 9    11-110     Cite to publication             34
#
# # Add the total for that strata to each row, to be used to create percentage
# software_by_strata <- merge(software_by_strata,software_by_strata_totals)
#
# # create the percentage for each row.
# software_by_strata <- within(software_by_strata, proportion <- software_in_strata / total_in_strata)
#
# software_by_strata <- ddply(software_by_strata,c("variable","strata"),transform,
#                                 conf_int_low = prop.test(software_in_strata,total_in_strata)$conf.int[1],
# 		  						conf_int_high = prop.test(software_in_strata,total_in_strata)$conf.int[2] )
#
# software_by_strata$variable <- factor(software_by_strata$variable, levels=c("accessible","free","source","modifiable"))
#
#
#
# software_summary <- dcast(software_by_strata, variable ~ strata , mean , value.var="proportion")
#
#
# print(software_summary)
#
# ggplot(software_by_strata, aes(x=strata,y=proportion)) +
#   geom_bar(stat="identity",fill="darkgrey") +
#   geom_errorbar(aes(ymin=conf_int_low, ymax=conf_int_high),
#                 width=.2,                    # Width of the error bars
#                 position=position_dodge(.9)) +
#   facet_grid(~variable) +
#  # scale_fill_grey(name="",start=0.2,end=0.6) +
#   theme(legend.position="bottom",
#         legend.text = element_text(size=14),
#         panel.grid.major.x = element_blank(),
# 		panel.grid.minor.y = element_blank(),
# 		panel.border = element_blank(),
# 		axis.title.y=element_text(vjust=0.3),
# 		axis.title.x=element_blank(),
# 		text=element_text(size=10),
# 		axis.text.x=element_blank(),
# 		axis.ticks.x=element_blank()
# 		)
#
# ggsave(filename="output/fig-Fig5-FunctionsByStrataBoxplot.png", width=5, height=4)
#
# ########################
# # Misses/Matches preferred citation
# ########################
#
# query <- "
# SELECT ?strata ?article ?software_article_link ?software ?preferred
# WHERE {
# 	?software_article_link 	rdf:type bioj:ArticleSoftwareLink ;
# 							citec:includes_preferred_cite ?preferred ;
# 							bioj:mentions_software ?software ;
# 							bioj:from_article ?article .
# 	?article dc:isPartOf ?journal .
# 	?journal bioj:strata ?strata .
# }
# "
# #
# links_preferred <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# cat("--------------------\n")
# cat("Preferred citation counts\n\n")
#
# # How many pieces of software are here?
# print(summarize(links_preferred,num_software = n_distinct(software), num_links = n_distinct(software_article_link),num_articles=n_distinct(article)))
#
# print(links_preferred %>%
# group_by(preferred) %>%
# summarize(count = n(), percent = round(n()/nrow(links_preferred),2),num_articles=n_distinct(article)))
#
# cat("--------------------\n")
# cat("Appendix 1 table")
# query <- "
# SELECT ?strata ?title ?policy
# WHERE {
#   ?journal rdf:type bioj:journal ;
#           dc:title ?title ;
#           bioj:strata ?strata ;
# 		  citec:has_software_policy ?policy .
# }
# "
# journals <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
#
# cat("\n\n--------------------\n")
# cat("1-10\n")
# j <- journals %>% filter(strata == "1-10") %>% select(title)
# cat(paste(j$title,collapse="\n"))
#
# cat("\n\n--------------------\n")
# cat("11-110\n")
# j <- journals %>% filter(strata == "11-110") %>% select(title)
# cat(paste(j$title,collapse="\n"))
#
# cat("\n\n--------------------\n")
# cat("111-1455\n")
# j <- journals %>% filter(strata == "111-1455") %>% select(title)
# cat(paste(j$title,collapse="\n"))
#
# journal_totals <- journals %>% group_by(strata) %>%
# summarize(total_in_strata = n_distinct(title))
#
# # Count number of each category in each strata
# journals_by_strata <- journals %>%
# filter(policy=="true") %>%
# group_by(strata) %>%
# summarize(policy_in_strata = n_distinct(title))
#
#
# # Add the total for that strata to each row, to be used to create percentage
# journals_by_strata <- merge(journals_by_strata,journal_totals)
#
# # create the percentage for each row.
# journals_by_strata <- within(journals_by_strata, proportion <- round(policy_in_strata / total_in_strata, 2))
#
# ddply(journals_by_strata,c("strata"),transform, conf_int_low = prop.test(policy_in_strata,total_in_strata)$conf.int[1],
# 		  						conf_int_high = prop.test(policy_in_strata,total_in_strata)$conf.int[2] )
#
#
# cat("\n\n--------------------\n")
# cat("Percentage of journals with software citation guidelines\n")
#
# print(journals_by_strata)
# cat("Overall : ")
# cat(round(sum(journals_by_strata$policy_in_strata) / sum(journals_by_strata$total_in_strata),2))
#
# print(chisq.test(journals_by_strata[,2:4],simulate.p.value=T))

# sink()
# closeAllConnections()

# Output goes to this file (using print)
sink("output/analysis_output_new.txt")

##########
# Concepts: Mentions, Software, FunctionsOfMentions
##########

MentionBasics <- function() {}
	
	# How many mentions? Articles mentioning software.
	article_count = 90

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

	conf_interval <- prop.test(articles_with_mentions,article_count)$conf.int

	cat("--------------------------\n")
	cat("There were ", articles_with_mentions, " articles with mentions and ", article_count - articles_with_mentions,  " articles without.\n", sep="")

	cat("At a confidence interval of 95%, the proportion of articles in the population that mention software is between ")
	cat(round(conf_interval[1],2), " and ", round(conf_interval[2],2), "\n", sep="")
	
	mention_count_by_article <- mentions %>%
	   group_by(strata,article) %>%
	   summarize(  mention_count = n_distinct(selection)) %>%
	   arrange(desc(mention_count))

	ggplot(mention_count_by_article,aes(x=strata,y=mention_count)) +
	 geom_boxplot() +
	 scale_y_continuous(name = "Mentions in article") +
	 scale_x_discrete(name="Journal Impact Factor rank")
	
	thisFilename = paste("output/fig-",global_fig_counter,"-MentionsByStrataBoxplot.png",sep="")
	assign("global_fig_counter", global_fig_counter + 1, envir = .GlobalEnv)
	ggsave(filename=thisFilename, width=5, height=4)

	cat("--------------------\n")
	cat("Outputted Figure 1: MentionsByStrataBoxplot.png\n")

MentionTypes <- function() {}

	# Overall (all categories)
	# melt to vertical format.
	mmentions <- melt(mentions, id=1:5) #article, journal, strata, selection, mention, variable, value
	
	# Arrange by order
	mmentions$value <- factor(mmentions$value,levels=c("Cite to publication", "Cite to user manual", "Cite to name or website", "Like instrument" , "URL in text", "Name only", "Not even name"))
	
	# Overall (collapsing to Other)
	
	mmentions_collapse <- mmentions
	mmentions_collapse$value <- gsub("Cite to user manual","Cite to publication",mmentions_collapse$value)

	mmentions_collapse$value <- gsub("URL in text","Other",mmentions_collapse$value)
	mmentions_collapse$value <- gsub("Name only","Other",mmentions_collapse$value)
	mmentions_collapse$value <- gsub("Not even name","Other",mmentions_collapse$value)
	mmentions_collapse$value <- gsub("Cite to name or website","Other",mmentions_collapse$value)
	
	mmentions_collapse$value <- factor(mmentions_collapse$value,levels=c("Cite to publication", "Like instrument" , "Other"))
	
	outputProportionAndCI <- function(datain) {
		percent = percent(datain$proportion)
		print(paste(percent, " (95% CI: ",sprintf("%.2f",datain$conf_int_low),"–",sprintf("%.2f",datain$conf_int_high),")",sep=""))
	}

	GetProportionsAndGraph <- function (datain, id_column, id_column_total, title) {
		
		# Not only used for mentions but not changing the var names.
		mention <- id_column
		#total_mentions <- summarise_(datain, count=interp(~n_distinct(var), var = as.name(mention)))[1,1]
#		total_mentions <- summarise(datain, count=n_distinct(mention))[1,1]
#		                 summarise_(data, count = interp(~n_distinct(var), var = as.name(col)))
		
		total_mentions <- id_column_total
		
		print(total_mentions)
		#group by value, sums and proportions
		datain_overall <- datain %>% group_by(value) %>%
		summarize_(num=interp(~n_distinct(var), var = as.name(mention))) %>%
		mutate(proportion = round(num / total_mentions, 2),
			   total_mentions_in_frame = total_mentions
			   )

		#Add confidence intervals
		datain_overall <- ddply(datain_overall,c("value"),transform,
		                      conf_int_low = round(prop.test(num,total_mentions_in_frame,conf.level = 0.95)$conf.int[1],2),
							  conf_int_high = round(prop.test(num,total_mentions_in_frame,conf.level = 0.95)$conf.int[2],2)
							)

		# Output table
		print(datain_overall)
		
		
		d_ply(datain_overall, c("value"),outputProportionAndCI)

		#Output plot
		ggplot(datain_overall,aes(x=value,y=proportion,fill=value)) +
		geom_bar(stat="identity") +
		geom_errorbar(aes(ymin=conf_int_low, ymax=conf_int_high),
		              width=.2,                    # Width of the error bars
		              position=position_dodge(.9)) +
		#facet_grid(.~strata,margins=T) +
		scale_fill_grey(guide = guide_legend(title=""),start=0.6,end=0.2) +
		scale_x_discrete(name="") +
		scale_y_continuous(name="Proportion of mentions") +
		ggtitle(title) +
		theme(legend.position="none",
		      panel.grid.major.x = element_blank(),
			panel.grid.minor.y = element_blank(),
			panel.border = element_blank(),
			axis.title.y=element_text(vjust=0.3),
			axis.title.x=element_text(vjust=0.1),
			text=element_text(size=10),
			axis.text.x=element_text(angle=25,hjust=1)
			)
	  	thisFilename = paste("output/fig-",global_fig_counter,"-",title,".png",sep="")
		assign("global_fig_counter", global_fig_counter + 1, envir = .GlobalEnv)
		ggsave(filename=thisFilename, width=5, height=4)
		cat("--------------------\n")
		cat("Outputted ",thisFilename,"\n\n",sep="")
	}
	
	GetProportionsByX <- function (datain, id_column, facet_column) {
		
		mention <- id_column
		# Get total in strata
		totals_by_strata <- datain %>% group_by_(interp(~var,var=as.name(facet_column))) %>% summarize_(total_in_strata = interp(~n_distinct(var), var=as.name(mention)))

		#     strata total_in_strata
		# 1     1-10             130
		# 2   11-110              89
		# 3 111-1455              65

		# Count number of each category in each strata
		types_by_strata <- datain %>% group_by_(interp(~var,var=as.name(facet_column)), quote(value)) %>% summarize_(type_in_strata = interp(~n_distinct(var), var=as.name(mention)))

		#      strata                category type_in_strata
		# 1      1-10 Cite to name or website              2
		# 2      1-10     Cite to publication             47
		# 6      1-10           Not even name              3
		# 7      1-10             URL in text              6
		# 8    11-110 Cite to name or website              8
		# 9    11-110     Cite to publication             34

		# Add the total for that strata to each row, to be used to create percentage
		types_by_strata <- merge(types_by_strata,totals_by_strata)

		# create the percentage for each row.
		types_by_strata <- within(types_by_strata, proportion <- round(type_in_strata / total_in_strata, 2))

		# create confidence intervals
		types_by_strata <- ddply(types_by_strata,c(facet_column,"value"),transform, 
		                        conf_int_low = round(prop.test(type_in_strata,total_in_strata,conf.level = 0.95)$conf.int[1],2), 
								conf_int_high = round(prop.test(type_in_strata,total_in_strata,conf.level = 0.95)$conf.int[2],2) 
								)
		
		print(types_by_strata)
		d_ply(types_by_strata, c(facet_column,"value"),outputProportionAndCI)
		return(types_by_strata)
		#ddply(types_by_strata,c("strata","category"),transform, conf_int_high = prop.test(type_in_strata,total_in_strata)$conf.int[2])
		#types_by_strata <- within(types_by_strata, conf_low <- prop.test(type_in_strata,total_in_strata)$conf.int[1])

		# This would give you a usable table to show these data
		# dcast(types_by_strata, category ~ strata , sum, value.var="type_in_strata")

		# reduce to just the 'major categories
		#types_for_graph <- filter(types_by_strata, category %in% c("Cite to publication","Like instrument","Name only"))

		# Then graph as dodged bars with errorbars.

	}
	
	OutputGraph <- function(types_by_strata, facet_column, title) {
		ggplot(types_by_strata,aes_string(x=facet_column,y=quote(proportion),fill=facet_column)) + 
		  geom_bar(stat="identity") + 
		  geom_errorbar(aes(ymin=conf_int_low, ymax=conf_int_high),
		                width=.2,                    # Width of the error bars
		                position=position_dodge(.9)) + 
		  facet_grid(. ~ value) + 
		  scale_y_continuous(name="Proportion",limits=c(0,max(types_by_strata$conf_int_high))) +
		  scale_x_discrete(name="") +
		  scale_fill_grey(guide = guide_legend(title="")) +
		  theme(legend.position="none",
		        panel.grid.major.x = element_blank(),
				panel.grid.minor.y = element_blank(),
				panel.border = element_blank(),
				axis.title.y=element_text(vjust=0.3),
				axis.title.x=element_text(vjust=0.1),
				text=element_text(size=10),
				axis.text.x=element_text(angle=25,hjust=1)) +
		  ggtitle(title)
  
  		thisFilename = paste("output/fig-",global_fig_counter,"-",title,".png",sep="")
		assign("global_fig_counter", global_fig_counter + 1, envir = .GlobalEnv)
  		ggsave(filename=thisFilename, width=5, height=4)
  		cat("--------------------\n")
  		cat("Outputted ",thisFilename,"\n\n",sep="")
	}
	
	GetProportionsAndGraphByX <- function (datain, id_column, facet_column, title) {
		summary <- GetProportionsByX(datain, id_column, facet_column)
		OutputGraph(summary, facet_column, title)
	} 

	GetProportionsAndGraph(mmentions, "mention", length(levels(mmentions$mention)), "Mentions, all categories")

	GetProportionsAndGraph(mmentions_collapse, "mention", length(levels(mmentions_collapse$mention)), "Mentions, collapsed categories")

	# Per strata (Collapsed)	
	GetProportionsAndGraphByX(mmentions_collapse, "mention", "strata", "Mentions by strata, collapsed categories")
	
	
SoftwareTypes <- function() {}
	
	# Detailed software characteristics.
	query <- "
	SELECT ?software ?accessible ?modifiable ?source_available ?free
	WHERE {
		?software	rdf:type                        bioj:SoftwarePackageUsed ;
					citec:is_accessible             ?accessible  ;
					citec:is_explicitly_modifiable  ?modifiable  ;
					citec:is_source_accessible      ?source_available      .
		OPTIONAL { ?software citec:is_free          ?free  }

	}
	"
	software_char <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
	
	msoftware_char <- melt(software_char,id=1)
	
	# drop false, rejig dataframe to match functions above.
	msoftware_char <- msoftware_char %>% filter(value == "true") 
	msoftware_char <- msoftware_char %>% select(-value)
	msoftware_char <- msoftware_char %>% rename(value = variable)
	
	msoftware_char$value <- factor(msoftware_char$value, levels=c("accessible", "free", "source_available", "modifiable"))
	
	GetProportionsAndGraph(msoftware_char, "software", length(levels(msoftware_char$software)), "Characteristics of mentioned software")
	
	# Simplified Software Types
	query <- "
	SELECT ?software ?category
	WHERE {
		?software rdf:type bioj:SoftwarePackage ;
		          citec:software_category ?category .
	}
	"

	software <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))

	software <- unique(software)

	cat("--------------------\n")
	cat("We found references to ")
	cat(nrow(software))
	cat(" distinct pieces of software\n")
	
	# Overall (proprietary, non-commercial, explicitly open source)
	msoftware <- melt(software, id=1) #software, variable, value
	
	# Arrange by order
	msoftware$value <- factor(msoftware$value,levels=c("Not accessible","Proprietary","Non-commercial","Open source"))

	GetProportionsAndGraph(msoftware, "software", length(levels(msoftware$software)), "Types of Software mentioned")
	# Per strata
	# Decided against this, since software is mentioned in multiple strata.
#	GetProportionsAndGraphByX(msoftware, "software", "strata", "Proportion of Software by strata")
	
	
SoftwareTypeVsCitationType <- function() {}
	# Does software of different types get cited differently?
	query <- "
	SELECT ?mention ?mention_category ?software_category  
	WHERE {
		?software_article_link 	rdf:type bioj:ArticleSoftwareLink ;
		 						bioj:from_article ?article ;
		 					    bioj:mentions_software [ citec:software_category ?software_category ] ;
								bioj:from_mention ?mention .
		?mention citec:mention_category [ rdfs:label ?mention_category ] .
	}
	"
	
	categories <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
	
	mcategories <- melt(categories, id=1:2)
	
	mcategories$mention_category <- gsub("Cite to user manual","Cite to publication",mcategories$mention_category)

	mcategories$mention_category <- gsub("URL in text","Other",mcategories$mention_category)
	mcategories$mention_category <- gsub("Name only","Other",mcategories$mention_category)
	mcategories$mention_category <- gsub("Not even name","Other",mcategories$mention_category)
	mcategories$mention_category <- gsub("Cite to name or website","Other",mcategories$mention_category)
	
	mcategories$mention_category <- factor(mcategories$mention_category,levels=c("Cite to publication", "Like instrument" , "Other"))
	
	mcategories$value <- factor(mcategories$value,levels=c("Not accessible","Proprietary","Non-commercial","Open source"))
	
	
	GetProportionsAndGraphByX(mcategories, "mention", "mention_category","Mention types and Software Types")
	
	myTable <- dcast(mcategories,mention_category ~ value, length)
	myTable2 <- as.matrix(myTable[1:3,2:4])
	dimnames(myTable2) <- list(mention_category = myTable[,1], software_type = names(myTable)[2:4])
	Xsq <- chisq.test(myTable2)
	print(Xsq)
	

FunctionsOfCitation <- function() {}
	
	# Unit of analysis: ArticleSoftwareLink
	
	query <- "
	SELECT ?strata ?software_article_link ?software_category ?mention_category ?identifiable ?findable ?versioned ?version_findable ?credited 
	WHERE {
		?software_article_link 	rdf:type bioj:ArticleSoftwareLink ;
								citec:is_credited       ?credited ;
								citec:is_findable       ?findable ;
								citec:is_identifiable   ?identifiable ;
								citec:is_versioned      ?versioned ;
								citec:version_is_findable ?version_findable ;
		 						bioj:from_article ?article ;
		 					    bioj:mentions_software ?software ;
								bioj:from_mention [ citec:mention_category [ rdfs:label ?mention_category ]].
	    ?software citec:software_category ?software_category .
		?article dc:isPartOf ?journal .
		?journal bioj:strata ?strata .
	}
	"
	
	#
	links <- data.frame(sparql.rdf(inferredData, paste(prefixes, query, collapse=" ")))
	
	links$software_category <- factor(links$software_category,levels=c("Not accessible","Proprietary","Non-commercial","Open source"))
	
	mlinks <- melt(links, id=1:4)
	
	# drop false, rejig dataframe to match functions above.
	mlinks <- mlinks %>% filter(value == "true") 
	mlinks <- mlinks %>% select(-value)
	mlinks <- mlinks %>% rename(value = variable)
	
	# Collpase mention_category
	mlinks$mention_category <- gsub("Cite to user manual","Cite to publication",mlinks$mention_category)

	mlinks$mention_category <- gsub("URL in text","Other",mlinks$mention_category)
	mlinks$mention_category <- gsub("Name only","Other",mlinks$mention_category)
	mlinks$mention_category <- gsub("Not even name","Other",mlinks$mention_category)
	mlinks$mention_category <- gsub("Cite to name or website","Other",mlinks$mention_category)
	
	mlinks$mention_category <- factor(mlinks$mention_category,levels=c("Cite to publication", "Like instrument" , "Other"))
	

	GetProportionsAndGraph(mlinks, "software_article_link", length(levels(mlinks$software_article_link)), "Functions of Citation")
	GetProportionsAndGraphByX(mlinks, "software_article_link", "strata","Functions of Citation By Strata")

#######
# Analyses
#######

CitationTypeByFunction <- function() {}
	
	# Which mention types are driving issues in functions?	
	#GetProportionsAndGraphByX(mlinks, "software_article_link", "mention_category","Functions of Citation By Mention Category")
	
	summary_by_function <- GetProportionsByX(mlinks, "software_article_link", "mention_category")
	title = "Functions of Citation By Mention Category"
	
	print(summary_by_function)
		d_ply(summary_by_function, c("mention_category","value"),outputProportionAndCI)
	
	# Special plotting.
	ggplot(summary_by_function,aes(x=mention_category,y=proportion,fill=mention_category)) + 
	  geom_bar(stat="identity") + 
	  geom_errorbar(aes(ymin=conf_int_low, ymax=conf_int_high),
	                width=.2,                    # Width of the error bars
	                position=position_dodge(.9)) + 
	  facet_grid(. ~ value) + 
	  scale_y_continuous(name="Proportion",limits=c(0,max(summary_by_function$conf_int_high))) +
	  scale_x_discrete(name="") +
	  scale_fill_grey(guide = guide_legend(title="")) +
	  theme(legend.position="none",
	        panel.grid.major.x = element_blank(),
			panel.grid.minor.y = element_blank(),
			panel.border = element_blank(),
			axis.title.y=element_text(vjust=0.3),
			axis.title.x=element_text(vjust=0.1),
			text=element_text(size=10),
			axis.text.x=element_text(angle=25,hjust=1)) +
	  ggtitle(title)

	thisFilename = paste("output/fig-",title,".png",sep="")
	ggsave(filename=thisFilename, width=5, height=4)
	cat("--------------------\n")
	cat("Outputted ",thisFilename,sep="")

SoftwareTypeByFunction <- function() {}
	
	# Which software types are driving issues in functions?

	GetProportionsAndGraphByX(mlinks, "software_article_link", "software_category","Functions of Citation By Software Category")



#####
# Discussion
#####

# Problems 

sink()
closeAllConnections()

