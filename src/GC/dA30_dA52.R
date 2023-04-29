# load library
library(data.table)
library(foreach)
library(doParallel)
library(tidyverse)
library(broom)

# read in the GReX files 
da30 <- fread("./DA30_eur.csv", h=T)
da52 <- fread("./DA52_eur.csv", h=T)

# chage to data frames
da30 <- as.data.frame(da30)
da52 <- as.data.frame(da52)

# relabel rownames
row.names(da30) <- da30$FID
row.names(da52) <- da52$FID

# remove first three columns
da30 <- da30[,-c(1,2,3)]
da52 <- da52[,-c(1,2,3)]

# find shared genes b/n two datasets
shared <- intersect(names(da30), names(da52))
da30s <- da30[,shared]
da52s <- da52[,shared]

# calculate granger's causality as a bivariate regression 

# step 1 - write a function that calculates multiple regression 
tf <- t(da30)
f <- function(inputg){
  perfor <- as.data.frame(tf[,1:3])
  perfor$genes <- names(da30)
  for (i in 1:length(names(da30))) {
    model <- lm(da52s[,inputg] ~ as.matrix(da30[,i]) + da30[,inputg])
    jj <-  summary(model)
    other_gene_coef <- jj$coefficients[2]
    previous_inputg_coef <- jj$coefficients[3]
    perfor[i,"gene2__t1_coef"] <- other_gene_coef
    perfor[i, "gene1_t1_coef"]  <- previous_inputg_coef
    y <- da52s[,inputg]
    x <- da30[,i]
    z <- da30[,inputg]
    perfor[i, "gene2_t1_beta"] <-  other_gene_coef*(sd(x)/sd(y)) # standardizing the coefficient
    perfor[i, "gene1_t1_beta"] <-  other_gene_coef*(sd(x)/sd(z)) # standardizing the coefficinet
    perfor[i,"gene1_day30"] <- inputg
    perfor[i,"gene2_day52"] <- perfor[i,"genes"]
    perfor[i,"F-stat"] <- jj$fstatistic[1]
    g <- glance(model)
    perfor[i, "F-stat_pval"] <- g$p.value
  }
  perfor = perfor[,-c(1,2,3,4)]
  na.omit(perfor)
}

# apply to all genes
genes <- colnames(da52s)
genes <- as.list(genes)
t <- lapply(genes, f)
lml<- plyr::ldply(t, rbind)
lml2 <- as.matrix(lml)
write.csv(lml2, "./bi_var_da30_52.csv", row.names=F, quote=F)
