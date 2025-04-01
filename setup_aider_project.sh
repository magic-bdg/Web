#!/bin/bash

# Project directory name
PROJECT_DIR="aider-website"

# Create project directory and navigate into it
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit

# Create run_aider.py (Flask wrapper for Aider)
cat << 'EOF' > run_aider.py
import os
import subprocess
from flask import Flask

app = Flask(__name__)

# Set the API key from environment variable
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY", "your-openai-api-key-here")

# Start Aider in a subprocess
def start_aider():
    aider_process = subprocess.Popen(["aider", "--browser"])
    return aider_process

@app.route('/')
def home():
    return "Aider Chat is running! Check the Render logs for the browser mode URL."

if __name__ == "__main__":
    # Start Aider in the background
    aider_process = start_aider()
    # Run Flask on the Render-provided port
    port = int(os.getenv("PORT", 8080))  # Default to 8080 if PORT not set
    app.run(host="0.0.0.0", port=port)
EOF

# Create requirements.txt
cat << 'EOF' > requirements.txt
aider-chat
flask
EOF

# Create .gitignore
cat << 'EOF' > .gitignore
__pycache__
*.pyc
.env
EOF

# Create README.md
cat << 'EOF' > README.md
# Aider Chat Website

This project runs Aider Chat as a website hosted on Render.

## Setup
1. Deploy to Render by connecting this repository.
2. Set the `OPENAI_API_KEY` environment variable in Render.
3. Check the Render logs for the Aider browser mode URL.
EOF

# Initialize Git repository
git init
git add .
git commit -m "Initial commit: Set up Aider Chat website"

echo "Project files created in $PROJECT_DIR and Git repository initialized."
echo "Next steps:"
echo "1. Create a new GitHub repository (e.g., aider-website)."
echo "2. Run: git remote add origin https://github.com/yourusername/aider-website.git"
echo "3. Run: git push -u origin main"
echo "4. Set up the GitHub Actions workflow (see below) to automate updates."
