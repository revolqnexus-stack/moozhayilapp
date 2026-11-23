#!/bin/bash

cd "/Users/ajmal/moozhayil app/moozhayilapp"

echo "🔧 Adding changes..."
git add -A

echo "📝 Committing..."
git commit -m "Add detailed logging for onboarding loop debugging + fix TypeScript lint errors"

echo "🚀 Pushing to GitHub..."
git push

echo "✅ Done! Check GitHub Actions: https://github.com/revolqnexus-stack/moozhayilapp/actions"
