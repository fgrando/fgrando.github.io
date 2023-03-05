# Check if git repo has new commits
05/Mar/2023

```bash
cd /your/repo

git fetch
git diff --quiet main origin/main || echo changes detected
```