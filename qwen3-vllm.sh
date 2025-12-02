CUDA_VISIBLE_DEVICES=0,1,2,3 lm_eval --model vllm \
    --model_args pretrained=/home/user1/workspace/bobchenyx/Qwen/Qwen3-30B-A3B-Instruct-2507,tensor_parallel_size=4,dtype=auto,gpu_memory_utilization=0.8,max_model_len=4096,enforce_eager=True \
    --tasks ifeval \
    --batch_size auto \
    --output_path qwen3-e8-results 