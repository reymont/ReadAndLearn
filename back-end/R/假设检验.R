#5.3.1 Pearson拟合优度χ2检验
X<-c(210, 312, 170, 85, 223)
n<-sum(X); m<-length(X)
p<-rep(1/m, m)
K<-sum((X-n*p)^2/(n*p));K
Pr<-1-pchisq(K, m-1);Pr

#例5.9
X<-scan()
25 45 50 54 55 61 64 68 72 75 75
78 79 81 83 84 84 84 85 86 86 86
87 89 89 89 90 91 91 92 100

A<-table(cut(X, br=c(0,69,79,89,100)));A
p<-pnorm(c(70,80,90,100), mean(X), sd(X));p
p<-c(p[1], p[2]-p[1], p[3]-p[2], 1-p[3]);p
chisq.test(A,p=p)
