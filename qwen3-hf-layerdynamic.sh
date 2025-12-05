# accelerate launch\
#     -m lm_eval --model hf_qwen3 \
#     --model_args pretrained=../Qwen/Qwen3-30B-A3B-Instruct-2507,load_in_4bit=True \
#     --tasks hellaswag \
#     --batch_size auto

accelerate launch\
    -m lm_eval --model hf_qwen3_layerdynamic \
    --model_args pretrained=../Qwen/Qwen3-30B-A3B-Instruct-2507,load_in_4bit=True \
    --tasks hellaswag \
    --batch_size auto

# accelerate launch -m lm_eval --model hf_qwen3 \
#     --model_args pretrained=/home/user1/workspace/bobchenyx/Qwen/Qwen3-30B-A3B-Instruct-2507,load_in_4bit=True \
#     --tasks hellaswag \
#     --batch_size 1
