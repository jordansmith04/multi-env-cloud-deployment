import os
from flask import Flask, render_template_string

# Get the environment name from the Task Definition
ENVIRONMENT = os.environ.get("TF_ENVIRONMENT", "Dev")

app = Flask(__name__)

# Basic HTML site
HTML_TEMPLATE = """
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>DevOps Pipeline App</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 50px; background-color: #f4f4f9; }
        .container { background-color: #ffffff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); display: inline-block; }
        h1 { color: #2c3e50; }
        .env { color: #e74c3c; font-weight: bold; font-size: 1.5em; padding: 10px; border: 2px dashed #e74c3c; border-radius: 8px; margin-top: 20px; }
        .status { color: #27ae60; margin-top: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello from the Containerized App!</h1>
        <p class="status">Application Status: Running successfully on port 8080.</p>
        <div class="env">
            DEPLOYED ENVIRONMENT: {{ env }}
        </div>
        <p>This is a placeholder demonstrating successful Fargate deployment and ALB routing.</p>
    </div>
</body>
</html>
"""

@app.route("/")
def hello():
    """Returns the environment status."""
    return render_template_string(HTML_TEMPLATE, env=ENVIRONMENT.upper())

@app.route("/health")
def health_check():
    """Simple health check endpoint."""
    return "OK", 200

if __name__ == "__main__":
    # The application runs on 0.0.0.0 and port 8080, matching the ECS configuration.
    app.run(host='0.0.0.0', port=8080)