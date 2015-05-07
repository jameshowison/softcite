import json
import csv
import operator

json_data = json.loads(open("mention_nltk_sentence_v2.json").read())


csv_data=[]

for (lineNO,value) in json_data.items():
    for (m,n) in value["nltk_output_fragments"].items():
        fragment=(str(value["article_id"]),str(value["mention_id"]),str(n["nltk_output_fragment"].encode('utf-8')),str(n["software"]))
        csv_data.append(fragment)
 
csv.writer(file('jsontocsv.csv','w')) .writerows(csv_data)


reader=csv.reader(open("jsontocsv.csv"))
sortedlist = sorted(reader, key=operator.itemgetter(1))
csv.writer(file('mention_nltk_sentence.csv','w')) .writerows(sortedlist)