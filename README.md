# Deploying Qwen 3 Embedding to Cloud Run 🚀

Click the button below to deploy the [Qwen 3 Embedding](https://qwenlm.github.io/blog/qwen3-embedding/) service to Google [Cloud Run](https://console.cloud.google.com/run?utm_campaign=CDR_0xc245fc42_default_b423604648&utm_medium=external&utm_source=social) with [vLLM](https://docs.vllm.ai/).

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/?terminal=true&show=terminal&cloudshell_git_repo=https://github.com/vladkol/qwen-3-enbedding-cloud-run&cloudshell_tutorial=tutorial.md&utm_campaign=CDR_0xc245fc42_default_b423604648&utm_medium=external&utm_source=social)

The below performs the following operations:

* Creates a Cloud Storage bucket for caching model files
so that the model container doesn't have to download them
from Hugging Face Hub every time the container starts.
* Downloads model files to a temporary local cache.
* Uploads model files to the Storage Bucket. Options `--no-clobber` doesn't let the command overwrite existing files.
* Deploys Cloud Run service `qwen3-embedding` with the following notable parameters:
    * Use NVIDIA L4 GPU (`--gpu-type=nvidia-l4` and `--gpu=1`)
    * GCS bucket is mounted to `/model-cache` directory (`--add-volume...` options).
    * Hugging Face hub cache is configured to `/model-cache` directory which the storage bucket is mounted to
    (`HF_HOME` environment variable set via `--set-env-vars` option).
    This way all service instances share the same Hugging Face cache data.
    * Another environment variable `HF_HUB_OFFLINE=1` set in `--set-env-vars` option ensures that
    vLLM doesn't re-download the model.
    * Use a vLLM container image optimized for Google Cloud (`--image="us-docker.pkg.dev/vertex-ai/vertex-vision-model-garden-dockers/pytorch-vllm-serve:20250601_0916_RC01"`)
    * Start vLLM's OpenAI compatible server with option `--task=embed` (for Embeddings API), and `--api-key` - to set a simple key-based authentication.

> The recommended secure way to control access to Cloud Run services is to require IAM-based authentication
(use `--no-allow-unauthenticated` rather than `--allow-unauthenticated`). Using `--api-key` option would be unnecessary in that case.
Read more about it in [Cloud Run Authentication Overview](https://cloud.google.com/run/docs/authenticating/overview).

## 🗒️ Disclaimers

This is not an officially supported Google product. This project is not eligible for the [Google Open Source Software Vulnerability Rewards Program](https://bughunters.google.com/open-source-security).

Code and data from this repository are intended for demonstration purposes only. It is not intended for use in a production environment.
