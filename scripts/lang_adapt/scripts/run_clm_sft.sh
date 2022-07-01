# axis
LANG="th"
MAX_TRAIN_SAMPLES=100000
BIGS_MODEL="bigscience/bloom-1b3"
ADPT_REDUCTION_FACTOR=16
ADPT_STRATEGY="emb-and-sft"
EMB_STRATEGY="replace"

tokenizer_dir=""
cache_dir="./cache"
output_dir="/home/lily/nos6/bloom-adapt/multilingual-modeling/scripts/lang_adapt/sft_testing_merged"
logging_dir="/home/lily/nos6/bloom-adapt/multilingual-modeling/scripts/lang_adapt/sft_testing_merged"
mkdir -p $output_dir
mkdir -p $logging_dir

CUDA_VISIBLE_DEVICES=0 python madx_run_clm.py \
    --seed 0 \
    --fp16 \
    --model_name_or_path $BIGS_MODEL \
    --tokenizer_name $tokenizer_dir \
    --dataset_name oscar \
    --dataset_config_name "unshuffled_deduplicated_$LANG" \
    --cache_dir $cache_dir \
    --logging_dir $logging_dir \
    --report_to "tensorboard" \
    --learning_rate 0.001 \
    --do_train \
    --do_eval \
    --train_sft \
    --load_best_model_at_end \
    --output_dir $output_dir \
    --preprocessing_num_workers 8 \
    --overwrite_output_dir \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 8 \
    --per_device_eval_batch_size 1 \
    --eval_accumulation_steps 8 \
    --eval_steps 1000 \
    --evaluation_strategy "steps" \
    --max_eval_samples 5000 \
    --logging_steps 100 \
    --save_steps 5000 \
    --save_strategy "steps" \
    --max_train_samples $MAX_TRAIN_SAMPLES \
    --max_steps 50000 \
    --lang_adapt_strategies "$ADPT_STRATEGY" \
    --embedding_strategies "$EMB_STRATEGY" \
    --adapter_reduction_factor $ADPT_REDUCTION_FACTOR \
    --language $LANG \
    --full_ft_max_steps_per_iteration 5000 \
    --n_ft_iterations 1





