# accelerate launch\
#     -m lm_eval --model hf_qwen3 \
#     --model_args pretrained=../Qwen/Qwen3-30B-A3B-Instruct-2507,load_in_4bit=True \
#     --tasks hellaswag \
#     --batch_size auto

# accelerate launch\
#     -m lm_eval --model hf_qwen3_layerdynamic \
#     --model_args pretrained=../Qwen/Qwen3-30B-A3B-Instruct-2507,load_in_4bit=True \
#     --tasks hellaswag \
#     --batch_size auto

# accelerate launch -m lm_eval --model hf_qwen3 \
#     --model_args pretrained=/home/user1/workspace/bobchenyx/Qwen/Qwen3-30B-A3B-Instruct-2507,load_in_4bit=True \
#     --tasks hellaswag \
#     --batch_size 1

# CUDA_VISIBLE_DEVICES=0,2,3,4,5,6,7 
accelerate launch\
    -m lm_eval --model hf_qwen3_layerdynamic \
    --model_args pretrained=../Qwen/Qwen3-30B-A3B-Instruct-2507,load_in_4bit=True \
    --tasks mmlu \
    --num_fewshot 5 \
    --batch_size auto
