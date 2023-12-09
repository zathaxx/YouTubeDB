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
    return render_template('channels.html', channels=channels)

@app.route('/categories')
def categories():
    cursor.execute("SELECT * FROM CATEGORY;")
    categories = cursor.fetchall()
    return render_template('categories.html', categories=categories)

@app.route('/videos')
def categories():
    cursor.execute("SELECT * FROM VIDEO;")
    videos = cursor.fetchall()
    return render_template('videos.html', videos=videos)

@app.route('/playlists')
def categories():
    cursor.execute("SELECT * FROM PLAYLIST;")
    playlists = cursor.fetchall()
    return render_template('playlists.html', playlists=playlists)

@app.route('/comments')
def categories():
    cursor.execute("SELECT * FROM COMMENT;")
    comments = cursor.fetchall()
    return render_template('comments.html', comments=comments)

@app.route('/sponsors')
def categories():
    cursor.execute("SELECT * FROM SPONSOR;")
    sponsors = cursor.fetchall()
    return render_template('sponsors.html', sponsors=sponsors)

@app.route('/posts')
def categories():
    cursor.execute("SELECT * FROM POST;")
    posts = cursor.fetchall()
    return render_template('posts.html', posts=posts)

if __name__ == '__main__':
    app.run()