#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --ntasks=1 #--cup-per-task=1
#SBATCH --time=00:40:00
#SBATCH --mem-per-cpu=8G
#SBATCH --job-name=4/13
#SBATCH --array=1-150

main_dir=/data/g****/a***/****/model_training/


#1. model training 
ml GCC/8.2.0  OpenMPI/3.1.4 R/3.6.0
module load PLINK/1.9b_5.2

Rscript ${main_dir}/src/predixcan_elnet.r \
        --model_training \
        --main_dir ${main_dir} \
        --plink_file_name fpp_11 \
        --expression_file_name training_ready_fpp11.txt \
        --subjob_id ${SLURM_ARRAY_TASK_ID} \
        --n_genes_for_each_subjob 100 \
        --annotation_file_name gencode.v32.GRCh37.txt


#2. generate .db and .cov file
ml GCC/8.2.0  OpenMPI/3.1.4 R/3.6.0
module load PLINK/1.9b_5.2
Rscript ${main_dir}/src/predixcan_elnet.r \
         --generate_db_and_cov \
         --main_dir ${main_dir} \
         --plink_file_name fpp_11 \
         --expression_file_name training_ready_fpp11.txt \
         --annotation_file_name gencode.v32.GRCh37.txt \
         --output_file_name fpp11

