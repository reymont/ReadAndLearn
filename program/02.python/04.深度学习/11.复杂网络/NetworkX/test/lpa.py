import networkx as nx
import random


def getMaxNeighborLabel(G,node_index):
    dict = {}
    for neighbor_index in G.neighbors(node_index):
        neighbor_label = G.node[neighbor_index]["label"]
        if(dict.has_key(neighbor_label)):
            dict[neighbor_label] += 1
        else:
            dict[neighbor_label] = 1
    max = 0
    for k,v in dict.items():
        if(v>max):
            max = v
    for k,v in dict.items():
        if(v != max):
            dict.pop(k)
    return dict


def canStop(G):
    for i in range(len(G.node)):
        node = G.node[i]
        label = node["label"]
        dict = getMaxNeighborLabel(G, i)
        
        if(not dict.has_key(label)):
            return False
    
    return True
    
'''asynchronous update'''
def populateLabel(G):
    #random visit
    visitSequence = random.sample(G.nodes(),len(G.nodes()))
    for i in visitSequence:
        node = G.node[i]
        label = node["label"]
        dict = getMaxNeighborLabel(G, i)
        
        if(not dict.has_key(label)):
            newLabel = dict.keys()[random.randrange(len(dict.keys()))]
            node["label"] = newLabel
        
def generateCommunity(G):
    dict = {}
    for node in G.nodes(True):
        label = node[1]["label"]
        if(dict.has_key(label)):
            dict.get(label).append(node[0]+1)
        else:
            l = []
            l.append(node[0]+1)
            dict[label] = l
    
    for k,v in dict.items():
        print("label: " + str(k) +" size: "+str(len(v))+" "+ str(v))


def run():
    G = nx.karate_club_graph()
    #initial label
    for i in range(len(G.node)):
        G.node[i]["label"] = i
    
    while(not canStop(G)):
        populateLabel(G)
        
    generateCommunity(G)
    
    
if __name__ == '__main__':
    run()