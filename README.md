softcite
========

A repo to hold the data and analysis files for a study of the citation of scientific software.

Currently the code that runs and executes some SPARQL queries against the data/SoftwareCitationDataset.ttl file.  Those are run with mvn exec:java.

To run the SPIN rules:

mvn -Dtest=AppTest#testSPINoutput test

Contact: 

James Howison
jhowison@ischool.utexas.edu

[![DOI](https://zenodo.org/badge/9584/jameshowison/softcite.svg)](http://dx.doi.org/10.5281/zenodo.14727)


machine_learning branch->data->pdf_articles->mention_nltk_sentence

there are 10 txt files that are transformed from pdf files using pdftotext tool. all the supplement files are copy manually to the corresponding txt files. all the txt files are splited into sentences using NLTK(each line is considered as a sentence)

mention.csv is the original code from James.

mention_nltk_sentences.csv is the result of applying nltk algorithm to mention.csv (seperate the full_quote into sentences)

mention_nltk_sentence.json is kind of the same as mention_nltk_sentences.csv, the json file contain:
article_name, mention_name,
original full_quote,<software_name>
nltk_output_fragment,<software_name>
full_quote_change? (T or F)
match(T or F)
