# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

LM Evaluation Harness is a unified framework for evaluating language models across hundreds of benchmarks. It supports multiple model backends (HuggingFace, vLLM, SGLang, OpenAI, Anthropic, etc.) and task types.

## Commands

### Install

```bash
pip install -e ".[dev,hf]"   # dev tools + HuggingFace backend
pip install -e ".[dev,vllm]" # dev tools + vLLM backend
```

### Linting

```bash
pre-commit install          # install hooks (run once)
pre-commit run --all-files  # run linter manually (uses ruff)
```

### Testing

```bash
# Run all unit tests (parallel)
pytest --showlocals -s -vv -n=auto --ignore=tests/models/test_openvino.py --ignore=tests/models/test_hf_steered.py

# Run a single test file
pytest tests/test_evaluator.py -s -vv

# Run a specific test function
pytest tests/test_tasks.py::test_task_name -s -vv
```

Enable verbose logging during development:
```bash
export LMEVAL_LOG_LEVEL="debug"
```

### Running Evaluations

```bash
# List available tasks
lm-eval ls tasks

# Basic evaluation
lm-eval run --model hf --model_args pretrained=gpt2 --tasks hellaswag

# With few-shot
lm-eval run --model hf --model_args pretrained=gpt2 --tasks arc_easy --num_fewshot 5

# With vLLM backend
lm-eval run --model vllm --model_args pretrained=meta-llama/Llama-3-8B --tasks mmlu

# Save results
lm-eval run --model hf --model_args pretrained=gpt2 --tasks hellaswag --output_path ./results/ --log_samples
```

The legacy single-command `lm-eval --model hf --tasks hellaswag` still works (auto-inserts `run`).

### Python API

```python
import lm_eval

results = lm_eval.simple_evaluate(
    model="hf",
    model_args={"pretrained": "gpt2"},
    tasks=["hellaswag"],
    num_fewshot=5,
)
```

## Architecture

### Core Abstractions

**`lm_eval/api/model.py`** — `LM` abstract base class. All model backends must implement three methods:
- `loglikelihood(requests)` — score (context, continuation) pairs
- `loglikelihood_rolling(requests)` — full-sequence log-likelihood for perplexity
- `generate_until(requests)` — free-form generation with stop conditions

**`lm_eval/api/task.py`** — `Task` abstract base class. Tasks produce `Instance` objects (requests to the model) and score results. Tasks support four output types: `loglikelihood`, `multiple_choice`, `loglikelihood_rolling`, `generate_until`.

**`lm_eval/api/registry.py`** — Central registry for models, tasks, metrics, and filters. Use `@register_model("name")` decorator to register new model backends; tasks are auto-discovered from YAML files.

**`lm_eval/evaluator.py`** — `simple_evaluate()` is the main entry point. Orchestrates task loading, request batching, model inference, and result aggregation.

### Model Backends (`lm_eval/models/`)

Each file implements a specific backend by subclassing `LM`:
- `huggingface.py` — `HFLM` class for transformers models (registered as `hf`)
- `vllm_causallms.py` — vLLM backend
- `sglang_causallms.py` — SGLang backend
- `api_models.py` — Base for REST API-based models (OpenAI-compatible)
- `openai_completions.py` — OpenAI/local-completions
- `anthropic_llms.py` — Anthropic API

### Tasks (`lm_eval/tasks/`)

Tasks are primarily YAML-configured. Each task subfolder contains `.yaml` files with:
- Dataset source (HuggingFace datasets)
- Prompt templates (Jinja2)
- Evaluation metrics
- Few-shot configuration

Task groups (collections of related tasks) are defined with `group:` in YAML or `lm_eval/api/group.py`.

**`lm_eval/tasks/manager.py`** (`TaskManager`) — discovers and loads tasks from the filesystem. Tasks can also be loaded from external paths via `--include_path`.

### CLI (`lm_eval/_cli/`)

Subcommand structure since Dec 2025:
- `run.py` — evaluation runner
- `ls.py` — list tasks/groups
- `validate.py` — validate task YAML configs

### Filters (`lm_eval/filters/`)

Post-processing pipeline applied to model outputs before scoring. Built-in filters: `extraction.py` (regex extraction), `transformation.py` (string transforms), `selection.py`. Custom filters can be registered via `@register_filter`.

### Logging (`lm_eval/loggers/`)

`EvaluationTracker` handles result storage. Supports WandB (`wandb_logger.py`) and Zeno integration.

## Adding a New Task

1. Create `lm_eval/tasks/<task_name>/<task_name>.yaml`
2. Or copy template: `cp -r templates/new_yaml_task lm_eval/tasks/<task_name>/`
3. Validate: `lm-eval validate --tasks <task_name>`
4. Test with a small model and `--limit 10`

## Adding a New Model Backend

1. Create `lm_eval/models/<backend_name>.py` (avoid shadowing package names)
2. Subclass `lm_eval.api.model.LM` and implement the three required methods
3. Decorate with `@register_model("backend-name")`
4. Register lazy-load entry point in `pyproject.toml` if needed

## Key Configuration

- Task YAML fields documented in `docs/new_task_guide.md` and `docs/task_guide.md`
- Model args documented in `docs/model_guide.md`
- Full CLI reference in `docs/interface.md`
- YAML config file support documented in `docs/config_files.md`
