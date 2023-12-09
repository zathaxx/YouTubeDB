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

app = Flask(__name__, static_url_path='/static')

@app.route('/')
def home():
    return render_template('index.html')



@app.route('/channels')
def channels():
    cursor.execute("SELECT * FROM CHANNEL;")
    channels = cursor.fetchall()
    return render_template('channels.html', channels)

if __name__ == '__main__':
    app.run()