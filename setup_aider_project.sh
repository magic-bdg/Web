#!/bin/bash

# Project directory name (root of repo in GitHub Actions)
PROJECT_DIR="."

# Create run_aider.py (Flask wrapper for Aider)
cat << 'EOF' > "$PROJECT_DIR/run_aider.py"
import os
import subprocess
from flask import Flask

app = Flask(__name__)

# Set the API key from environment variable
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY")

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
cat << 'EOF' > "$PROJECT_DIR/requirements.txt"
aider-chat
flask
EOF

# Create .gitignore
cat << 'EOF' > "$PROJECT_DIR/.gitignore"
__pycache__
*.pyc
.env
EOF

# Create README.md
cat << 'EOF' > "$PROJECT_DIR/README.md"
# Web - Aider Chat Website

This project runs Aider Chat as a website hosted on Render.

## Setup
1. Deploy to Render by connecting the 'Web' repository.
2. Set the `OPENAI_API_KEY` environment variable in Render.
3. Check the Render logs for the Aider browser mode URL.
EOF

echo "Project files created in $PROJECT_DIR for the 'Web' repository."
echo "The GitHub Actions workflow will commit and push these files."