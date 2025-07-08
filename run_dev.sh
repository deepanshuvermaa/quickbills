#!/bin/bash

# Development run script for QuickBills

echo "Running QuickBills in development mode..."

flutter run \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=IS_PRODUCTION=false \
  --dart-define=ENABLE_LOGGING=true \
  --dart-define=RAZORPAY_KEY_ID=your_razorpay_key_here