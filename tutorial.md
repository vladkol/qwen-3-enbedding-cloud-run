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
./deploy.sh "<walkthrough-project-id/>"
```

## Conclusion

Thanks for using Google Cloud!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
