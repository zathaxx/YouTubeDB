from flask import Flask, request
import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

db = mysql.connector.connect(
  host="localhost",
  user=os.environ["USERNAME"],
  password=os.environ["PASSWORD"],
  db="youtube"
)

cursor = db.cursor()

app = Flask(__name__)

@app.route('/')
def hello():
    return """<a href="/channels">Channel</a>"""

@app.route('/channels')
def channels():
    cursor.execute("SELECT * FROM CHANNEL;")
    output = []
    for row in cursor.fetchall():
        output.append(f"<p>{row}</p>")
    return "\n".join(output)

@app.route('/test', methods=['GET', 'POST'])
def test():
  if request.method == 'POST':
    cursor.execute(request.values.get('channel_id'))
  else:
    return "Page under construction"

if __name__ == '__main__':
    app.run()