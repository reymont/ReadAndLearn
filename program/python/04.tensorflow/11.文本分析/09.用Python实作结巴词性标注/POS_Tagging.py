import os

cwd = os.getcwd()
Data_Folder = cwd + '\Demo5Files'

print(Data_Folder)

from os import walk # 文件走訪
from os.path import join # 路徑合併

file_list = list()

for root, dirs, files in walk(Data_Folder):
    for file in files:
        file = join(root, file)
        print(file)
        file_list.append(file)

import codecs        

## load news ##
all_news = list()
category = list()

for file in file_list:
    with codecs.open(file, 'r', encoding='utf-8') as news:
        all_news.append(news.read())
        category.append(file.split('\\')[-2]) #-2為類別層  ex:XXX/娛樂/0.txt  

print(all_news)
print(category)

import jieba
import jieba.posseg as pseg

seg_POS_list = pseg.cut("承德市长江大桥")

for w,s in seg_POS_list:
    print(w + '/' + s + ' ', end = '')
    
print()

import jieba

## word segmentation ##
words_list = list()

for i in range(len(all_news)):
    word = list()
    line = all_news[i]
    
    result = pseg.cut(str(line)) 
    
    for w,s in result:
        print(w + '/' + s, end=' ')
        word.append(w)
    
    words_list.append(word)
    
    print()
    print('-' * 40)

import jieba

jieba.add_word('吉田荣作', tag='nr')

## load user dictionary ##
user_dict_path = cwd + '\\userdict_p.txt'
jieba.load_userdict(user_dict_path)

## word segmentation ##
words_list = list()

for i in range(len(all_news)):
    word = list()
    line = all_news[i]
    
    result = pseg.cut(str(line)) 
    
    for w,s in result:
        print(w + '/' + s, end=' ')
        word.append(w)
    
    words_list.append(word)
    
    print()
    print('-' * 40)

import jieba

## load user dictionary ##
user_dict_path = cwd + '\\userdict_p.txt'
jieba.load_userdict(user_dict_path)
    
## load stop words ##
stop_words_path = cwd + '\\stop_words.txt'

stop_words = set()

with open(stop_words_path,'r',encoding='utf-8') as sw:
    [stop_words.add(line.strip()) for line in sw.readlines()] #list Comprehension

stop_words.add('，');
stop_words.add('。');
stop_words.add('说');
stop_words.add('约');
stop_words.add('处');

jieba.suggest_freq(('中', '待'), True)

# subject = ['ng','n','nr','ns','nt','nz','ag','a','ad','an','d','dg','e','v','vg','vd','vn','x']

## word segmentation ##
words_list = list()

for i in range(len(all_news)):
    word = list()
    line = all_news[i]
    
    result = pseg.cut(str(line)) 
    
    for w,s in result:
        if w not in stop_words and s[0] == 'n':
            word.append(w)
            print(w + '/' + s, end=' ')
    
    words_list.append(' '.join(word))
    
    print()
    print('-' * 40)

import jieba.analyse as analyse

for i in range(len(words_list)):
    print('Doc ' + str(i) + ' :')
    for key,value in analyse.extract_tags(words_list[i], 10, withWeight=True):
        print('%-7s\t%7.5f' % (key, value))
    print()

import jieba.analyse as analyse

for i in range(len(all_news)):
    print('Doc ' + str(i) + ' :')
    for key,value in analyse.extract_tags(all_news[i], 10, withWeight=True, allowPOS=('n', 'nr', 'nrt', 'ns', 'nt', 'nz')):
        print('%-7s\t%7.5f' % (key, value))
    print()

