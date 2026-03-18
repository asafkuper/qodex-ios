#!/bin/bash
# deploy.sh - Deployment script for QodeX

echo "🚀 QodeX Deployment Starting..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null
then
    echo "${RED}Firebase CLI not found. Installing...${NC}"
    npm install -g firebase-tools
fi

# Check if user is logged in to Firebase
firebase login --reauth

echo "${YELLOW}Step 1/4: Deploying Firestore Rules...${NC}"
firebase deploy --only firestore:rules

echo "${YELLOW}Step 2/4: Deploying Firestore Indexes...${NC}"
firebase deploy --only firestore:indexes

echo "${YELLOW}Step 3/4: Deploying Storage Rules...${NC}"
firebase deploy --only storage

echo "${YELLOW}Step 4/4: Deploying Cloud Functions...${NC}"
cd firebase-functions
npm install
firebase deploy --only functions

echo "${GREEN}✅ Backend deployment complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Deploy admin dashboard: cd admin-dashboard && vercel"
echo "2. Build iOS app: xcodebuild -workspace QodeX.xcworkspace -scheme QodeX"
echo "3. Upload to TestFlight"
