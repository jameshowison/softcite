import os
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
import numpy as np
import random
from sklearn import svm
from sklearn import metrics


all_items = os.listdir(os.getcwd())

all_sentences=[]

#read all sentences from txt files
for item in all_items:
    if item.endswith('.txt'):
        sentences=open(item).readlines()
        for i in sentences:
            all_sentences.append(i)
  
#random sample to get training and test dataset
#80% as training and 20% as test         
random.shuffle(all_sentences)
training_sentences=all_sentences[:len(all_sentences)*4/5]
test_sentences=all_sentences[len(all_sentences)*4/5:]


#function to split the sentences into positive and negtive, according the annotation
def label_split(sentences,positive,negtive):
    for i in sentences:
        i=i.replace('\n',"").decode('utf-8')
        if u'</annotation>' in i:
            i=i.replace('</annotation>', '')
            i=re.sub(r'(\<.*\>)','',i)
            positive.append(i)                        
        else:
            negtive.append(i)
  
#split training     
training_positive=[]
training_negtive=[]
label_split(training_sentences,training_positive,training_negtive)

#split test
test_positive=[]
test_negtive=[]
label_split(test_sentences,test_positive,test_negtive)

# undersampling to get final training dataset
random.shuffle(training_negtive)
negtive_sample=training_negtive[:len(training_positive)]

#final training dataset
training_data=training_positive+negtive_sample
training_class=[1]*len(training_positive)+[0]*len(training_positive)

#final test dataset
testing_data=test_positive+test_negtive
testing_class=[1]*len(test_positive)+[0]*len(test_negtive)

#bag of words; vectorizer
count_vect = CountVectorizer()
train_counts = count_vect.fit_transform(training_data)
train_counts.shape

#tr-idf
tfidf_transformer = TfidfTransformer()
train_tfidf = tfidf_transformer.fit_transform(train_counts)
train_tfidf.shape

#training model
clf = svm.SVC().fit(train_tfidf, training_class)  

#pre-process for test data
test_counts = count_vect.transform(testing_data)
test_tfidf = tfidf_transformer.transform(test_counts)


#predict
predict= clf.predict(test_tfidf)

#accuracy
print(np.mean(predict== testing_class)) 



print(metrics.classification_report(testing_class, predict))

metrics.confusion_matrix(testing_class, predict)

