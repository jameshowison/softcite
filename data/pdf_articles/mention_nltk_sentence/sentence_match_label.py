import os
import csv
from fuzzywuzzy import fuzz

already_done = set()
label_1=[]
label_2=[]

#get file form a path
for item in os.listdir(os.getcwd()):
    #select only txt files
    if item.endswith('.txt'):
        if item not in already_done:
            #read each line of a txt file 
            sentences=open(item).readlines()
            #read each line in csv file
            for line in csv.reader(open("mention_nltk_sentence.csv")):
                #pair files with the lines in csv file
                if item.replace(".txt","")==line[0].replace("bioj:a",""):
                    l_score=[]
                    #string matching for each sentence and full-quote
                    for sentence in sentences:
                        s=fuzz.ratio(sentence, line[2])
                        #get score
                        l_score.append(s)
                    #get the largest score and the index of matched sentence
                    index=l_score.index(max(l_score))
                    
                    #compare original sentences with matched sentences, without annotation
                    compare_1=str(line[2])+'\n'+sentences[index].replace('\n','')+'\n\n'
                    label_1.append(compare_1)                    
                    
                    #annotation
                    sentences[index]= "\n<annotation article=\"{article_id}\",mention=\"{mention_id}\",software_name=\"{name}\">{sentence}</annotation>\n\n"\
                    .format(article_id=line[0],mention_id=line[1],name=line[3],sentence=sentences[index].replace("\n",""))
                    
                    ##compare original sentences with matched sentences, with annotation
                    compare_2=str(line)+'\n'+sentences[index].replace('\n','')+'\n\n'
                    label_2.append(compare_2)
             
            #output the new annotated txt file
            for sentence in sentences:
                open('annotation/{name}'.format(name=item),'a').write("{segment}".format(segment=sentence))
        already_done.add(item)
j=0
for i in label_2:
    j+=1
    open('annotation/summury with annotation.txt','a').write('index:{j}\n{i}'.format(j=j,i=i))


j=0
for i in label_1:
    j+=1
    open('annotation/summury without annotation.txt','a').write('index:{j}\n{i}'.format(j=j,i=i))