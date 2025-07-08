#!/bin/bash

# Production run script for QuickBills

echo "Running QuickBills in production mode..."

flutter run \
  --release \
  --dart-define=API_BASE_URL=https://api.quickbills.com \
  --dart-define=IS_PRODUCTION=true \
  --dart-define=ENABLE_LOGGING=false \
  --dart-define=RAZORPAY_KEY_ID=your_production_razorpay_key