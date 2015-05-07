# -*- coding: utf-8 -*-
#article_name, mention_name,
#original full_quote, software_name
#nltk_output_fragment,software_name
#full_quote_change? (T or F)
#match(T or F)

import csv
import nltk.data
import json

whole={}

i=1
for line in csv.reader(open("mention.csv")):
    d={}#for 1 line in csv(for 1 full quote)
    d["article_id"]=line[0]
    d["mention_id"]=line[1]
    d["original_full_quote & software"]=line[2]
    d["match"]=""
    d["software"]=line[3]
    tokenizer = nltk.data.load('tokenizers/punkt/english.pickle')#split text into sentence
    segments= tokenizer.tokenize(str(line[2]))#split text into sentence
    
    if len(segments) !=1:
        d["change"]="T"
    else: d["change"]="F" 
    
    #nltk_output_fragment
    b={}
    for segment in segments:
        a={}
        idx=segments.index(segment)
        a["nltk_output_fragment"]=segment
        a["software"]=line[3]
        
        b[idx]=a
    d["nltk_output_fragments"]=b
    whole[i]=d
    i+=1
    
data = json.dumps(whole,sort_keys=True,indent=4)
outputfile = open('mention_nltk_sentence_v3.json', 'w') 
outputfile.write(data.strip())

