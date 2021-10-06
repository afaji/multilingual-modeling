from datasets import load_dataset
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("output_dir")
parser.add_argument("--num_train_epochs", type=int, default=30)
parser.add_argument("--learning_rate", type=float, default=1e-5)
parser.add_argument("--per_device_train_batch_size", type=int, default=4)
parser.add_argument("--gradient_accumulation_steps", type=int, default=4)
parser.add_argument("--pretrained_model")
args = parser.parse_args()


from datasets import load_dataset

xnli_dataset = load_dataset("flue", "XNLI", cache_dir="/users/zyong2/data/zyong2/bigscience/data/external/flue")
xnli_train_dataset = xnli_dataset['train']
xnli_val_dataset = xnli_dataset['validation']
xnli_test_dataset = xnli_dataset['test']

import torch
from transformers import GPT2Tokenizer, GPT2ForSequenceClassification

tokenizer = GPT2Tokenizer.from_pretrained('/users/zyong2/data/zyong2/bigscience/data/processed/exp-001/oscar-fr-tokenizer')
model = GPT2ForSequenceClassification.from_pretrained(args.pretrained_model, 
                                                      num_labels=3, 
                                                      pad_token_id=0)

def tokenize_function(examples):
    return tokenizer(f'{examples["premise"]} {tokenizer.eos_token} {examples["hypo"]}', padding="max_length", truncation=True)

tokenizer.pad_token = tokenizer.eos_token  # tokenizer.encode(tokenizer.eos_token) = [0]
full_train_dataset = paws_train_dataset.map(tokenize_function, batched=False)
full_val_dataset = paws_val_dataset.map(tokenize_function, batched=False)
full_test_dataset = paws_test_dataset.map(tokenize_function, batched=False)
small_train_dataset = full_train_dataset.shuffle(seed=42).select(range(100))
small_val_dataset = full_val_dataset.shuffle(seed=42).select(range(100))
small_test_dataset = full_test_dataset.shuffle(seed=42).select(range(100))

from transformers import TrainingArguments

training_args = TrainingArguments(
    args.output_dir,
    overwrite_output_dir=True,
    do_train=True,
    do_eval=True,
    num_train_epochs=args.num_train_epochs,
    per_device_train_batch_size=args.per_device_train_batch_size,
    gradient_accumulation_steps=args.gradient_accumulation_steps,
    learning_rate=args.learning_rate,
    evaluation_strategy="epoch",
    save_strategy="epoch",
    logging_strategy="epoch",
    logging_steps=1,
    report_to="tensorboard",
    logging_dir=f"{args.output_dir}/logs",
    load_best_model_at_end=True,
)

from transformers import Trainer
from datasets import load_metric
import numpy as np

metric = load_metric("accuracy")

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)
    return metric.compute(predictions=predictions, references=labels)


trainer = Trainer(
    model=model, 
    args=training_args, 
    train_dataset=full_train_dataset, 
    eval_dataset=full_val_dataset, 
    compute_metrics=compute_metrics
)

trainer.train()

# best_model = GPT2ForSequenceClassification.from_pretrained(f'{args.output_dir}/checkpoint-9000', 
#                                                       num_labels=2, 
#                                                       pad_token_id=0)

# trainer = Trainer(
#     model=best_model, 
#     args=training_args, 
#     train_dataset=full_train_dataset, 
#     eval_dataset=full_test_dataset, 
#     compute_metrics=compute_metrics
# )

# print("Evaluate:", trainer.evaluate())

