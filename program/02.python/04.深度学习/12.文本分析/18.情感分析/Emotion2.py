#%% Change working directory from the workspace root to the ipynb file location. Turn this addition off with the DataScience.changeDirOnImportExport setting
# ms-python.python added
import os
try:
	os.chdir(os.path.join(os.getcwd(), 'program\\02.python\04.深度学习\12.文本分析\18.情感分析'))
	print(os.getcwd())
except:
	pass

#%%
import os
import numpy as np
import scipy as sp
import codecs
from sklearn import tree
from matplotlib import pyplot
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import  CountVectorizer  
from sklearn.metrics import precision_recall_curve
from sklearn.metrics import classification_report
from numpy import *


#%%
cwd = os.getcwd()
file_dir = cwd + "\\keyword_CSCorp.csv"
print(file_dir)


#%%
##讀檔
data = [] #評論
labels = [] #正負評標籤

with codecs.open(file_dir, "r", encoding='utf-8') as file:
    for line in file.readlines():
        line=line.strip().split(',')
        data.append(line[0].strip())
        labels.append(line[1].strip())

print(data[0] + ' => ' + labels[0])

print(len(data))


#%%
count_vec = CountVectorizer(binary = True) #關鍵詞01矩陣(sklearn 物件)

x_train, x_test, y_train, y_test= train_test_split(data, labels, test_size=0.2)#training:0.8;test:0.2  

x_train = count_vec.fit_transform(x_train) #將評論轉為關鍵詞01矩陣(是否出現)
x_test  = count_vec.transform(x_test) #將評論轉為關鍵詞01矩陣(是否出現)

print(x_train[0])
#print(x_test[0])


#%%
clf=tree.DecisionTreeClassifier(max_depth=10,min_impurity_decrease=0.001)
clf.fit(x_train, y_train)


#%%
# draw tree  ##
import graphviz 
dot_data = tree.export_graphviz(clf, out_file=None,
                                feature_names=count_vec.get_feature_names(),)
graph = graphviz.Source(dot_data) 

graph.format = 'svg'
graph.render(cwd+"\\tree" ,view=True)


#%%
y_true = y_test
y_pred = clf.predict(x_test)

from sklearn.metrics import confusion_matrix
print(confusion_matrix(y_true, y_pred, labels = ['0','1']))


#%%
y_pred = clf.predict(x_test) 

#precision and recall  
#precision, recall, thresholds = precision_recall_curve(y_test, clf.predict(x_test))  
    
print(classification_report(y_true, y_pred , target_names = ['0','1']))
print("--------------------")
from sklearn.metrics import accuracy_score
print('準確率: %.2f' % accuracy_score(y_true, y_pred))
print('準確率: %.2f' % np.mean(y_true == y_pred))#預測值與真實值


#%%



#%%



#%%



#%%



#%%



#%%



#%%



#%%



#%%



