#!/bin/bash

# Create project directory structure
mkdir -p mentat-flask-app/{static,templates}

# Create app.py
cat > mentat-flask-app/app.py << 'EOF'
from flask import Flask, render_template, request, redirect, url_for, flash
from github import Github
import subprocess
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("FLASK_SECRET_KEY")

github_token = os.getenv("GITHUB_TOKEN")
g = Github(github_token)

@app.route("/", methods=["GET"])
def index():
    return render_template("index.html")

@app.route("/run", methods=["POST"])
def run_mentat():
    repo_name = request.form.get("repo_name")
    mentat_command = request.form.get("mentat_command")

    try:
        repo = g.get_repo(repo_name)
        clone_url = repo.clone_url.replace("https://", f"https://{github_token}@")
        repo_dir = repo_name.split("/")[1]

        if not os.path.exists(repo_dir):
            subprocess.run(["git", "clone", clone_url], check=True)

        os.chdir(repo_dir)
        mentat_cmd = ["mentat"] + mentat_command.split()
        result = subprocess.run(mentat_cmd, capture_output=True, text=True)

        subprocess.run(["git", "add", "."], check=True)
        subprocess.run(["git", "commit", "-m", "Mentat.ai edits"], check=True)
        subprocess.run(["git", "push"], check=True)

        os.chdir("..")
        output = result.stdout if result.stdout else result.stderr
        return render_template("result.html", output=output)

    except Exception as e:
        flash(f"Error: {str(e)}")
        return redirect(url_for("index"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
EOF

# Create index.html
cat > mentat-flask-app/templates/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Mentat.ai Web Interface</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <h1>Mentat.ai Web Interface</h1>
    <form method="POST" action="{{ url_for('run_mentat') }}">
        <p>GitHub Repository (e.g., username/repo):</p>
        <input type="text" name="repo_name" required>
        <p>Mentat Command (e.g., file1.py file2.py):</p>
        <input type="text" name="mentat_command" required>
        <br><br>
        <button type="submit">Run Mentat</button>
    </form>
    {% with messages = get_flashed_messages() %}
        {% if messages %}
            <div>
                {% for message in messages %}
                    <p>{{ message }}</p>
                {% endfor %}
            </div>
        {% endif %}
    {% endwith %}
</body>
</html>
EOF

# Create result.html
cat > mentat-flask-app/templates/result.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Mentat.ai Output</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <h1>Mentat.ai Output</h1>
    <pre>{{ output }}</pre>
    <a href="{{ url_for('index') }}">Back to Home</a>
</body>
</html>
EOF

# Create style.css
cat > mentat-flask-app/static/style.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    margin: 20px;
}
h1 {
    color: #333;
}
form {
    margin-top: 20px;
}
input[type="text"] {
    width: 300px;
    padding: 5px;
}
button {
    padding: 10px 20px;
    background-color: #007bff;
    color: white;
    border: none;
    cursor: pointer;
}
button:hover {
    background-color: #0056b3;
}
pre {
    background-color: #f8f9fa;
    padding: 10px;
    border: 1px solid #ddd;
}
EOF

# Create requirements.txt
cat > mentat-flask-app/requirements.txt << 'EOF'
flask==2.3.3
pygithub==2.3.0
mentat==1.0.8
python-dotenv==1.0.1
EOF

# Create .env template (empty values to be filled by user)
cat > mentat-flask-app/.env << 'EOF'
GITHUB_TOKEN=
OPENAI_API_KEY=
FLASK_SECRET_KEY=
EOF

# Create README.md
cat > mentat-flask-app/README.md << 'EOF'
# Mentat Flask App

## Prerequisites
- Python 3.7+
- GitHub Personal Access Token with repo scope
- OpenAI API Key

## Setup
1. Fill in the `.env` file with your credentials
2. Install dependencies: `pip install -r requirements.txt`
3. Run the app: `python app.py`

## Deployment on Render
1. Create a new Web Service on Render
2. Set Environment Variables in Render dashboard
3. Set Build Command: `pip install -r requirements.txt`
4. Set Start Command: `python app.py`
EOF

# Create Render configuration file
cat > mentat-flask-app/render.yaml << 'EOF'
services:
  - type: web
    name: mentat-flask-app
    env: python
    plan: free
    buildCommand: "pip install -r requirements.txt"
    startCommand: "python app.py"
    envVars:
      - key: GITHUB_TOKEN
        sync: false
      - key: OPENAI_API_KEY
        sync: false
      - key: FLASK_SECRET_KEY
        sync: false
      - key: PYTHON_VERSION
        value: "3.9.6"
EOF

# Make the script executable
chmod +x build.sh

echo "Build script created successfully! To build the project:"
echo "1. Run './build.sh' to create all files"
echo "2. cd into mentat-flask-app/"
echo "3. Fill in the .env file with your credentials"
echo "4. Deploy to Render using the render.yaml configuration"
