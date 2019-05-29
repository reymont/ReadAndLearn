### 1. 基本用法

from bosonnlp import BosonNLP

words_list = list()

nlp = BosonNLP('g8lQg9Mxx.25818.fAbbwt6TYhh8') # 使用token
result = nlp.tag('承德市长江大桥')

print(result)
print(result[0]['word'])
print(result[0]['tag'])

for i in range(len(result[0]['word'])):
    print(result[0]['word'][i] + '/' + result[0]['tag'][i], end=' ')
print()

print(' '.join([a + '/' + b for a, b in zip(result[0]['word'], result[0]['tag'])]))

### 2. 一次处理5篇文章的方法

from bosonnlp import BosonNLP
import requests

tokens = ['g8lQxxMv.25818.fAbbwt6TYhh8',] #boson api token

# Check Usage Time
HEADERS = {'X-Token': tokens[0]}
RATE_LIMIT_URL = 'http://api.bosonnlp.com/application/rate_limit_status.json'
result = requests.get(RATE_LIMIT_URL, headers=HEADERS).json()
canUseTime = result['limits']['tag']['count-limit-remaining']
print(canUseTime)

## Word Segmentation
words_list = list()

nlp = BosonNLP(tokens[0]) #使用token
result = nlp.tag(all_news)

for seg in result:
    word = list()
    
    for w in seg['word']:
        word.append(w)
    
    words_list.append(' '.join(word))

print(words_list)"

### 3. stop words

from bosonnlp import BosonNLP
import requests

## load stop words ##
stop_words_path = cwd + '\\\\data\\\\stop_words.txt'

stop_words = set()

with open(stop_words_path,'r',encoding='utf-8') as sw:
    [stop_words.add(line.strip()) for line in sw.readlines()] #list Comprehension

stop_words.add('，');
stop_words.add('。');
stop_words.add('说');
stop_words.add('约');
stop_words.add('处');


tokens = ['g8lQg9xx5818.fAbbwt6TYhh8',] #boson api token

# Check Usage Time
HEADERS = {'X-Token': tokens[0]}
RATE_LIMIT_URL = 'http://api.bosonnlp.com/application/rate_limit_status.json'
result = requests.get(RATE_LIMIT_URL, headers=HEADERS).json()
canUseTime = result['limits']['tag']['count-limit-remaining']
print(canUseTime)

## Word Segmentation
words_list = list()

nlp = BosonNLP(tokens[0]) #使用token
result = nlp.tag(all_news)

for seg in result:
    word = list()
    
    for w in seg['word']:
        if w not in stop_words:
            word.append(w)
    
    words_list.append(' '.join(word))

print(words_list)"

### 4. 命名实体的识别

from bosonnlp import BosonNLP

words_list = list()

nlp = BosonNLP('g8lQg9Mv.25818.fAbbwt6TYhh8') # 使用token
result = nlp.tag('承德市长江大桥')

print(result)
print(result[0]['word'])
print(result[0]['tag'])

for i in range(len(result[0]['word'])):
    print(result[0]['word'][i] + '/' + result[0]['tag'][i], end=' ')
print()

print(' '.join([a + '/' + b for a, b in zip(result[0]['word'], result[0]['tag'])]))

# sensitivity (int 默认为 3) – 准确率与召回率之间的平衡， 设置成 1 能找到更多的实体，设置成 5 能以更高的精度寻找实体。
sentence = '美国国防部发言人威廉斯说，伊拉克持续将五艘共约载有万桶原油的超级油轮，与距科威特海岸五公里处的海岛石油转运站的原油倾入北波斯湾。'
result = nlp.ner(sentence, sensitivity = 2)

print(result[0]['word'])
print(result[0]['tag'])
print(result[0]['entity'])


for s, e, entity in result[0]['entity']:
    print('%-14s\\t%s' % (''.join(result[0]['word'][s:e]), entity))"