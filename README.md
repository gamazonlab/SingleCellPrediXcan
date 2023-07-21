## sc-TWAS [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/gamazonlab/SingleCellPrediXcan/blob/main/LICENSE)

# References 

Mapping the landscape of lineage-specific dynamic regulation of gene expression using single-cell transcriptomics and application to genetics of complex disease

Hanna Abe<sup>1</sup>,Phillip Lin<sup>2</sup>, Dan Zhou<sup>2</sup>, Douglas Ruderfer<sup>2,3</sup>, Eric R. Gamazon<sup>2,3

<sup>1</sup>Vanderbilt University, Nashville, TN, USA <br>
<sup>2</sup>Division of Genetic Medicine, Department of Medicine, Vanderbilt University Medical Center, Nashville, TN, USA <br>
<sup>3</sup>Vanderbit Genetics Institute, Vanderbilt University Medical Center, Nashville, TN, USA<br>
<sup>4</sup>Clare Hall, University of Cambridge, Cambridge, United Kingdom<br>

Send correspondence to:<br>
Eric R. Gamazon ericgamazon@gmail.com<br>

Code being maintained by:<br>
Hanna Abe abehanna1@gmail.com

## Using this resource

### Download prediction models <br>
The cell type and cell state adjusted prediction models are available on Zenodo at (to be provided up on publication). Pre-trained tissue-specific PrediXcan gene expression models leveraged here are available for download from the JTI repository (https://doi.org/10.5281/zenodo.3842289).

### Application of models to GWAS summary data 
To apply the cell type prediction models to a GWAS summary statistics and get TWAS results, we use a method that has been developed by Barbeira et al, 2018, S-PrediXcan (https://github.com/hakyimlab/MetaXcan/blob/master/software/SPrediXcan.py).<br>
Reference: Barbeira, Alvaro N., et al. "Exploring the phenotypic consequences of tissue specific gene expression variation inferred from GWAS summary statistics." Nature communications 9.1 (2018): 1-20. (https://www.nature.com/articles/s41467-018-03621-1)


### PheWAS using cell type application to UKBB
---
We have applied our cell type models to > 4000 GWAS summary statistics in the UKBB. The R package below performs PheWAS using the UKBB associaitions. Given a gene, or multiple genes, the package will return signficant associations (those that pass the multiple testing correction) and returns a PheWAS plot. 

### TUTORIAL
Install the R package <br>
R CMD INSTALL sctwas_0.2.0_R_x86_64-pc-linux-gnu.tar.gz
