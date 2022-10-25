# load in the packages
library(Seurat)
library(SeuratData)
library(SeuratDisk)
library(irlba)
library(ggplot2)
library(dplyr)
library(Matrix)
library(uwot)
library(RColorBrewer)   
library(cowplot)

## Convert h5ad to seurat
Convert("./D11.log.norm.h5ad", dest= "h5seurat", assay = "RNA", overwrite = FALSE, verbose = TRUE) 

## Load in the normalized seurat object 
D11 <- LoadH5Seurat("./D11.log.norm.h5seurat", meta.data = FALSE, misc = FALSE)

## Find highly variable genes - top 2000
D11 <- FindVariableFeatures(D11, selection.method = "vst", nfeatures = 2000)

## Scale the data so that the mean = 0 and var = 1, and extract the matrix from the seurat object
all.genes <- rownames(D11)
D11 <- ScaleData(D11, features = all.genes) # scale data 
matrix <- D11[["RNA"]]@scale.data # extract the scaled matrix out 
matrix[1:3, 1:3]

## Do the PCA dimensional reduction - first 10 PCs - to get the continous PCs
p1 <- prcomp_irlba(matrix, n=10) 
hj <- as.data.frame(p1[4]) #Get the PCs that differentiate the cells 
rownames(hj) <- rownames(as.data.frame(p1[5]))
head(hj)


### load in the normalized data 

d11 <- load("/gpfs52/data/****/ab***/****/***/D11/normalized.d11.RData")
d11

exp <- d11
expression <- exp # making another copy

### Regress out all PCs 

for (i in 1:length(colnames(exp))) {
    fit = lm(exp[,i] ~ hj$rotation.PC1 + hj$rotation.PC2 + hj$rotation.PC3 + hj$rotation.PC4 + hj$rotation.PC5 + hj$rotation.PC6 + hj$rotation.PC7 + hj$rotation.PC8 + hj$rotation.PC9 + hj$rotation.PC10)
    expression[,i] <- residuals(fit)
  }

## save the residual expression as RData
save(expression, file="PC_regressed_d11.RData")

################################################################################
library(dplyr)
library(tidyr)
library(reshape2)
library(Matrix)
library(data.table)


# load in the residual expression data after regressing the effect of the PCs
d11 <- load("PC_regressed_d11.RData")
d11 # output here will be 'expression'


exp1 <- expression[, 1:23986]
exp1 <- as.data.frame(exp1)

# read in the meta data that contains the samples and the cell annotation
meta <- fread("/gpfs52/data/****/ab***/****/***/D11/raw_data/meta_data/d11_meta.data.csv")
exp1$sampels <- meta$donor_id

# change to the long format 
exp1 <- melt(exp1, id.vars="sampels")

# summarize by samples - by calculating the mean value 
out1 <- exp1 %>% group_by(sampels, variable) %>% summarize(mean_size = mean(value, na.rm = TRUE))

# changing it back to a wide format 
out1_wide <- spread(out1, key = variable, value = mean_size)
out1_wide <- as.data.frame(out1_wide)
dim(out1_wide)

save(out_wide, "d11_pseudobulk.csv", row.names=F, quote=F)

## next steps include quantile normalization,peer_adjustment, and training models
