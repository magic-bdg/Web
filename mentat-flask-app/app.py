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
