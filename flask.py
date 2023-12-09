from flask import Flask
import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

db = mysql.connector.connect(
  host="localhost",
  user=os.environ["USERNAME"],
  password=os.environ["PASSWORD"]
)

app = Flask(__name__)

@app.route('/')
def hello():
    return 'gaming'

@app.route('/channels')
def channels():
    return 'gaming'

if __name__ == '__main__':
    app.run()