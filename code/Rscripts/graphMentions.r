library(ggplot2)

data <- read.csv("/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/output/articles_with_mentions_by_strata.csv")

data <- unique(data)

# Replace code value with True or False.  Query include unbound vars, they are now set to False.
data$anycode <- ifelse(data$anycode == "", FALSE, TRUE)

ggplot(data, aes(x=strata,fill=anycode)) + geom_bar()

