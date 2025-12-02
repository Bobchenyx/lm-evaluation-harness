lm_eval --model llama-server \
    --tasks mmlu \
    --model_args base_url=http://127.0.0.1:8080 \
    --num_fewshot 5 \
    --output_path qwen3-llama-results 