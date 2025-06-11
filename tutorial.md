# Deploy Qwen 3 Embedding to Cloud Run 🚀
<walkthrough-tutorial-duration duration="30min"></walkthrough-tutorial-duration>

Deploy the [Qwen 3 Embedding](https://qwenlm.github.io/blog/qwen3-embedding/) service to Google [Cloud Run](https://console.cloud.google.com/run?utm_campaign=CDR_0xc245fc42_default_b423604648&utm_medium=external&utm_source=social) with [vLLM](https://docs.vllm.ai/).

Click the **Start** button to move to the next step.

## Please select a project for deployment or create one

This project will be used to run Cloud Run service with L4 GPU and to host a Cloud Storage bucket for model weights cache.

<walkthrough-project-setup billing="true"></walkthrough-project-setup>

## You are ready to deploy!

Simply run this command in Cloud Shell:

```bash
./deploy.sh "<walkthrough-project-id/>" "ReplaceWithYourSecretText"
```

## Try the service

Use you favorite Python environment to try the service with the Python code-snippet below.

Since vLLM exposes an OpenAI-compatible endpoint, you need OpenAI SDK:

```bash
pip install openai
```

Now, run the code for generating text embeddings:

Make sure you set `CUSTOM_API_KEY` and `SERVICE_URL` variables before running it.

```python
# Run `pip install openai` to install OpenAI Python SDK.

# Use the same value as with ./deploy.sh command.
# You can find it in Cloud Run service "Variables & Secrets" tab.
CUSTOM_API_KEY = "ReplaceWithYourSecretText"

# Find "🚀 Service deployed to https://..." in Cloud Shell where you ran the deployment.
# Alternatively, go to https://console.cloud.google.com/run, and find it for `qwen3-embedding-vllm` service.
SERVICE_URL = ""

from openai import OpenAI

client = OpenAI(
    api_key=CUSTOM_API_KEY,
    base_url=f"{SERVICE_URL}/v1",
)
models = client.models.list()
model = models.data[0].id

responses = client.embeddings.create(
    input=[
        "Happy dog",
        "Fluffy cat",
        "Cute pet"
    ],
    model=model,
)
for data in responses.data:
    print(data.embedding)
```

## Conclusion

Thank you for using Google Cloud!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
