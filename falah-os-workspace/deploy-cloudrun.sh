#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════
#  Falah OS — Google Cloud Run deployment
#  Usage: bash deploy-cloudrun.sh [PROJECT_ID] [REGION]
#  Example: bash deploy-cloudrun.sh my-gcp-project us-central1
# ════════════════════════════════════════════════════════════════
set -euo pipefail

PROJECT="${1:-$(gcloud config get-value project 2>/dev/null)}"
REGION="${2:-us-central1}"
SERVICE="falahos"
IMAGE="gcr.io/${PROJECT}/${SERVICE}"

if [ -z "$PROJECT" ]; then
  echo "Usage: $0 <GCP_PROJECT_ID> [REGION]"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "► Project : $PROJECT"
echo "► Region  : $REGION"
echo "► Image   : $IMAGE"
echo ""

# ── 1. Build and push image via Cloud Build ───────────────────
echo "[1/3] Building image with Cloud Build..."
gcloud builds submit \
  --project "$PROJECT" \
  --tag "$IMAGE" \
  .

# ── 2. Deploy to Cloud Run ────────────────────────────────────
echo "[2/3] Deploying to Cloud Run..."
gcloud run deploy "$SERVICE" \
  --project "$PROJECT" \
  --image "$IMAGE" \
  --region "$REGION" \
  --platform managed \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 3 \
  --timeout 60

# ── 3. Print URL ──────────────────────────────────────────────
echo "[3/3] Done."
URL=$(gcloud run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format "value(status.url)")

echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Falah OS is live at: $URL"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Redeploy: bash deploy-cloudrun.sh $PROJECT $REGION"
echo ""
