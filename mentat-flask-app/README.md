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
