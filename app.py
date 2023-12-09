from flask import Flask, request, render_template
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
def home():
    return render_template('index.html')



@app.route('/channels')
def channels():
    cursor.execute("SELECT * FROM CHANNEL;")
    output = []
    for row in cursor.fetchall():
        output.append(f"<p>{row}</p>")
    return "\n".join(output)

if __name__ == '__main__':
    app.run()