#%%
# pip install gensim
from gensim.models import word2vec #詞轉向量

sentences = word2vec.LineSentence(cwd+'/segms.txt') #input 已斷好的詞

#sg : 0->CBOW ,1->skip-gram 
#size : vector size
#window : window size
#min_count : min_TF
model = word2vec.Word2Vec(sentences, sg=1, size=5, window=5, iter=10000, min_count=1)

#%%
from gensim.models import KeyedVectors

print(model['帝都'].tolist()) #取vector
print(model.wv.vocab.keys()) #所有的詞

try:
    semi = model.wv.most_similar('帝都', topn=3) #與keyword最相似的k個詞
except KeyError:
    print('The word is not in vocalbulary')
    
for term in semi:
    print('%-5s \t %.3f'%(term[0],term[1]))

for w in model.wv.vocab.keys():
    print('%-5s \t %s' % (w, model.wv.most_similar(w, topn=3)))

#%%
### 2. 保存

import re

# pip install gensim
from gensim.models import word2vec #詞轉向量

sentences = word2vec.LineSentence(cwd+'/segms.txt') #input 已斷好的詞

#sg : 0->CBOW ,1->skip-gram 
#size : vector size
#window : window size
#min_count : min_TF
model = word2vec.Word2Vec(sentences, sg=1, size=5, window=5, iter=10000, min_count=1)

model.save(cwd+'/data/skipgram.model')#save model

#write vector
with open(cwd+'/data/skipgram.csv','w',encoding='utf-8') as f:
    f.write('\ufeff')
    for k in model.wv.vocab.keys():
        f.write(k+','+','.join(str(e) for e in model[k].tolist()))
        f.write('\n')

print('write s100w5_skipgram ok!')

#%%
### 3. 讀model出來


model = word2vec.Word2Vec.load(cwd+'/skipgram.model') #skipgram model

print('Vector Length: ' + str(len(model['帝都'].tolist())))

semi = ''

try:
    semi = model.most_similar('帝都',topn=3) #與keyword最相似的k個詞
except KeyError:
    print('The word is not in vocalbulary')

for term in semi:
    print('%-7s \t %.3f'%(term[0],term[1]))

print()
print(model.most_similar('北京',topn=3))
print()
print(model.most_similar('台北',topn=3))