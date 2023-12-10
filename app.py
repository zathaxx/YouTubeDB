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
def videos():
    cursor.execute("SELECT * FROM VIDEO;")
    videos = cursor.fetchall()
    updated_videos = []

    for video in videos:
        video_id = video[0]
        cursor.execute(f"SELECT DISTINCT CHANNEL.channelName FROM CHANNEL JOIN VIDEO ON CHANNEL.channelID = VIDEO.channelID AND VIDEO.videoID = '{video_id}';")
        channel_name = cursor.fetchone()
        print(channel_name)
        video.append(tuple(channel_name))
        updated_video = video + (channel_name[0],)
        updated_videos.append(updated_video)

    return render_template('videos.html', videos=updated_videos)


@app.route('/playlists')
def playlists():
    cursor.execute("SELECT * FROM PLAYLIST;")
    playlists = cursor.fetchall()
    return render_template('playlists.html', playlists=playlists)

@app.route('/comments')
def comments():
    cursor.execute("SELECT * FROM COMMENT;")
    comments = cursor.fetchall()
    return render_template('comments.html', comments=comments)

@app.route('/sponsors')
def sponsors():
    cursor.execute("SELECT * FROM SPONSOR;")
    sponsors = cursor.fetchall()
    return render_template('sponsors.html', sponsors=sponsors)

@app.route('/posts')
def posts():
    cursor.execute("SELECT * FROM POST;")
    posts = cursor.fetchall()
    return render_template('posts.html', posts=posts)

if __name__ == '__main__':
    app.run()