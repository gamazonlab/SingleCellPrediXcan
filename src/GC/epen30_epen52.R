# load library
library(data.table)
library(foreach)
library(doParallel)
library(tidyverse)
library(broom)

# read in the GReX files 
epen30 <- fread("/data/g_gamazon_lab/abehd/Sc_MR/HipSci_iPSC_data/DA_neurons/1kgp/Europeans/Epen30_eur.csv", h=T)
epen52 <- fread("/data/g_gamazon_lab/abehd/Sc_MR/HipSci_iPSC_data/DA_neurons/1kgp/Europeans/Epen52_eur.csv", h=T)

# chage to data frames
epen30 <- as.data.frame(epen30)
epen52 <- as.data.frame(epen52)

# relabel rownames
row.names(epen30) <- epen30$FID
row.names(epen52) <- epen52$FID

# remove first three columns
epen30 <- epen30[,-c(1,2,3)]
epen52 <- epen52[,-c(1,2,3)]

# find shared genes b/n two datasets
shared <- intersect(names(epen30), names(epen52))
epen30s <- epen30[,shared]
epen52s <- epen52[,shared]

# calculate granger's causality as a bivariate regression 

# step 1 - write a function that calculates multiple regression 
tf <- t(epen30)
f <- function(inputg){
  perfor <- as.data.frame(tf[,1:3])
  perfor$genes <- names(epen30)
  for (i in 1:length(names(epen30))) {
    model <- lm(epen52s[,inputg] ~ as.matrix(epen30s[,inputg]) + epen30[,i])
    jj <-  summary(model)
    other_gene_coef <- jj$coefficients[2]
    previous_inputg_coef <- jj$coefficients[3]
    perfor[i,"gene2__t1_coef"] <- other_gene_coef
    perfor[i, "gene1_t1_coef"]  <- previous_inputg_coef
    y <- epen52s[,inputg]
    x <- epen30[,i]
    z <- epen30s[,inputg]
    perfor[i, "gene2_t1_beta"] <-  other_gene_coef*(sd(x)/sd(y)) # standardizing the coefficient
    perfor[i, "gene1_t1_beta"] <-  previous_inputg_coef*(sd(x)/sd(z)) # standardizing the coefficinet
    perfor[i,"gene1_day30"] <- perfor[i,"genes"]
    perfor[i,"gene2_day52"] <- inputg
    perfor[i,"F-stat"] <- jj$fstatistic[1]
    g <- glance(model)
    perfor[i, "F-stat_pval"] <- g$p.value
  }
  perfor = perfor[,-c(1,2,3,4)]
  na.omit(perfor)
}

# apply to all genes
genes <- colnames(epen52s)
genes <- as.list(genes)
t1 <- lapply(gez, f)
lml<- plyr::ldply(t, rbind)
lml2 <- as.matrix(lml)
write.csv(lml2, "./bi_var_epen30_52.csv", row.names=F, quote=F)
