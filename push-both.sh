#!/bin/bash

# Script to push to both GitLab and GitHub with appropriate emails

# Push to GitLab (origin) 
echo "🦊 Pushing to GitLab..."
git config user.email "robert.lanier@phreesia.com"
git push origin "$@"
gitlab_result=$?

# Push to GitHub
echo "🐙 Pushing to GitHub..."
git config user.email "lanier@posteo.com"
git push github "$@"
github_result=$?

# Restore default email (GitLab)
git config user.email "robert.lanier@phreesia.com"

if [ $gitlab_result -eq 0 ] && [ $github_result -eq 0 ]; then
    echo "✅ Push completed successfully to both remotes!"
    exit 0
else
    echo "❌ Some pushes failed. GitLab: $gitlab_result, GitHub: $github_result"
    exit 1
fi