#!/bin/bash
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PROJECT_ID="${1}" # <-- Replace with your Google Cloud Project ID
REGION="us-central1"

HF_MODEL="Qwen/Qwen3-Embedding-0.6B"
CUSTOM_API_KEY="ReplaceWithSecretText" # <-- Replace with your secret text
SERVICE_NAME="qwen3-embedding-vllm"

if [[ "${PROJECT_ID}" == "" ]]; then
    PROJECT_ID=$(gcloud config get-value project -q)
fi
echo "Deploying to project ${PROJECT_ID}"

pip install -U "huggingface_hub[cli]" -q

set -e

echo "Creating the service account if doesn't exist..."
SERVICE_ACCOUNT="vllm-cloud-run-sa"
SERVICE_ACCOUNT_ADDRESS="${SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com"
sa_list=$(gcloud iam service-accounts list --quiet --format "value(email)" --project "${PROJECT_ID}" --filter "email:${SERVICE_ACCOUNT_ADDRESS}" 2>/dev/null)
if [ -z "${sa_list}" ]; then
    echo "Creating Service Account ${SERVICE_ACCOUNT}."
    gcloud iam service-accounts create "${SERVICE_ACCOUNT}" \
        --project "${PROJECT_ID}" \
        --display-name="${SERVICE_ACCOUNT} - Cloud Run Service Account"
fi

BUCKET_NAME="huggingface-cache-${PROJECT_ID}-${REGION}"
echo "Creating ${BUCKET_NAME} GCS bucket if doesn't exist..."
gcloud storage buckets describe "gs://${BUCKET_NAME}" -q &> /dev/null || gcloud storage buckets create "gs://${BUCKET_NAME}" --location="${REGION}" --project="${PROJECT_ID}"
echo "Granting the service account access to the bucket..."
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" --member="serviceAccount:${SERVICE_ACCOUNT_ADDRESS}" --role="roles/storage.objectViewer"

echo "Downloading the model..."
temp_dir=$(mktemp -d)
huggingface-cli download "${HF_MODEL}" --cache-dir="${temp_dir}"

echo "Uploading model files to the bucket..."
gcloud storage cp --recursive --no-clobber "${temp_dir}/*" "gs://${BUCKET_NAME}/hub"
rm -rf "${temp_dir}"

echo "Deploying Cloud Run service..."
gcloud beta run deploy "${SERVICE_NAME}" \
    --image="us-docker.pkg.dev/vertex-ai/vertex-vision-model-garden-dockers/pytorch-vllm-serve:20250601_0916_RC01" \
    --project="${PROJECT_ID}" \
    --region="${REGION}" \
    --service-account="${SERVICE_ACCOUNT_ADDRESS}" \
    --add-volume name=model-cache-volume,type=cloud-storage,bucket=${BUCKET_NAME},readonly=true \
    --add-volume-mount volume=model-cache-volume,mount-path=/model-cache \
    --set-env-vars VLLM_LOGGING_LEVEL=WARNING,HF_HUB_OFFLINE=1,HF_HOME=/model-cache \
    --command="python3" \
    --args="-m,vllm.entrypoints.openai.api_server,--model=${HF_MODEL},--task=embed,--port=8080,--api-key=${CUSTOM_API_KEY}" \
    --port=8080 \
    --cpu=8 \
    --memory=32Gi \
    --gpu-type=nvidia-l4 \
    --gpu=1 \
    --max-instances=3 \
    --no-gpu-zonal-redundancy \
    --cpu-boost \
    --no-cpu-throttling \
    --allow-unauthenticated \
    --timeout 1h

SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --project=${PROJECT_ID} --region=${REGION} --format="value(status.url)" -q)

echo "Testing service ${SERVICE_URL}/v1/embeddings:"
curl "${SERVICE_URL}/v1/embeddings" \
    -H "Authorization: Bearer ${CUSTOM_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{ \"input\": [\"Hello world!\"], \"model\": \"${HF_MODEL}\" }"
echo "Done!"
