#!/bin/bash

# Request half an hour of runtime:
#SBATCH --time=6-23:59:00

# Ask for the GPU partition and 1 GPU
#SBATCH --partition=gpu-he --gres=gpu:4

# Default resources are 1 core with 2.8GB of memory.
#SBATCH --ntasks=16

# Use more memory (10GB) (CPU RAM):
#SBATCH --mem=50g

# Specify a job name:
#SBATCH -J exp-005-run_clm_de

# Specify an output file
#SBATCH -o /users/zyong2/data/zyong2/bigscience/logs/005/run_clm_de.out
#SBATCH -e /users/zyong2/data/zyong2/bigscience/logs/005/run_clm_de.err

# Set up the environment by loading modules
set -a # automatically export all variables
source ~/.env
set +a

module load python/3.7.4
module load gitlfs/2.7.1
source $FP_BIGS/env_lang_mod/bin/activate

tokenizer_dir="/users/zyong2/data/zyong2/bigscience/data/processed/exp-005/oscar-de-tokenizer"
cache_dir="${FP_BIGS}/data/external/oscar_de"
output_dir="${FP_BIGS}/data/processed/exp-005/ft-gpt2-de"
logging_dir="${FP_BIGS}/reports/exp-005/ft-gpt2-de"

python $FP_BIGS/scripts/exp-005/run_clm.py \
    --model_name_or_path gpt2 \
    --tokenizer_name $tokenizer_dir \
    --dataset_name oscar \
    --cache_dir $cache_dir \
    --dataset_config_name unshuffled_deduplicated_de \
    --logging_dir $logging_dir \
    --report_to "tensorboard" \
    --learning_rate 0.001 \
    --do_train \
    --do_eval \
    --output_dir $output_dir \
    --preprocessing_num_workers 8 \
    --overwrite_output_dir \
    --per_device_train_batch_size 2 \
    --gradient_accumulation_steps 4 \
    --per_device_eval_batch_size 2 \
    --eval_accumulation_steps 4 \
    --eval_steps 1000 \
    --evaluation_strategy "steps" \
    --max_eval_samples 5000