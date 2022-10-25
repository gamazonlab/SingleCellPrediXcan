## this is a script for applying PEER on gene expression data 
## more detailed info can be found: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3398141/

# load library and data
# columns = genes, rows = samples

library(peer)
l <- read.csv("DA_30_norm.csv")
l[1:3, 1:3]
l2 <- t(l[-c(1)])
l2[1:3, 1:3]
colnames(l2) <- l$gene
expr<-as.data.frame(l2)

# learning hidden factors
# build the model
# 'NULL' response means no error here


model=PEER()
PEER_setPhenoMean(model,as.matrix(expr))

# set the max number of unobserved factors to model
# recommendation:  25% of the number of individuals contained in the study but no more than 100 factors.
# choosing 15 PEER factors based on GTEx eQTL recommendation, since sample size is less than 100. 

PEER_setNk(model, 15)

# Train the model, observing convergence and and perform the inference.
# defualt is 1000 iteration

PEER_update(model)


# outputting the results

factors = PEER_getX(model)
weights = PEER_getW(model)
precision = PEER_getAlpha(model)
residuals = PEER_getResiduals(model)


## write out the residuals and factors 

write.table(residuals,'DA_30_norm.peer.residual.txt', quote = F, sep='\t')
write.table(factors,'DA_30_norm.peer.factors.txt',quote = F,sep='\t')

print("fin")
