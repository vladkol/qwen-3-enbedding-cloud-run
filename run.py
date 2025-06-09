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
