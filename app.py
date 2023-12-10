from flask import Flask, request, render_template, redirect, url_for
import mysql.connector
import os
from dotenv import load_dotenv
from youtube import *

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

@app.route('/channels', methods=['GET', 'POST'])
def channels():
    if request.method == 'POST':
        channel_id = request.form['channel_id']
        print(channel_id)
        if channel_id:
            query = get_channel(channel_id)
            cursor.execute(query)
            db.commit()
            return redirect(url_for('channels'))
    
    cursor.execute("SELECT * FROM CHANNEL;")
    channels = cursor.fetchall()
    return render_template('channels.html', channels=channels)

@app.route('/delete_channel/<string:channel_id>', methods=['POST'])
def delete_channel(channel_id):
    if channel_id:
        query = f"DELETE FROM CHANNEL WHERE channelID = '{channel_id}';"
        cursor.execute(query)
        db.commit()
    return redirect(url_for('channels'))

@app.route('/update_channel/<string:channel_id>', methods=['POST'])
def update_channel_route(channel_id):
    if channel_id:
        update_query = update_channel(channel_id)
        cursor.execute(update_query)
        db.commit()

    return redirect(url_for('channels'))

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
        category_id = video[2]
        cursor.execute(f"SELECT DISTINCT CHANNEL.channelName FROM CHANNEL JOIN VIDEO ON CHANNEL.channelID = VIDEO.channelID AND VIDEO.videoID = '{video_id}';")
        channel_name = cursor.fetchone()
        cursor.execute(f"SELECT CATEGORY.categoryName FROM CATEGORY WHERE CATEGORY.categoryID = '{category_id}';")
        category_name = cursor.fetchone()
        updated_video = video + (channel_name[0],) + (category_name[0],)
        updated_videos.append(updated_video)

    return render_template('videos.html', videos=updated_videos)

@app.route('/playlists')
def playlists():
    cursor.execute("SELECT * FROM PLAYLIST;")
    playlists = cursor.fetchall()
    updated_playlists = []

    for playlist in playlists:
        playlist_id = playlist[0]
        cursor.execute(f"SELECT DISTINCT CHANNEL.channelName FROM CHANNEL JOIN PLAYLIST ON CHANNEL.channelID = PLAYLIST.channelID AND PLAYLIST.playlistID = '{playlist_id}';")
        channel_name = cursor.fetchone()

        updated_playlist = playlist + (channel_name[0],)
        updated_playlists.append(updated_playlist) 

    return render_template('playlists.html', playlists=updated_playlists)

@app.route('/comments')
def comments():
    cursor.execute("SELECT * FROM COMMENT;")
    comments = cursor.fetchall()
    updated_comments = []

    for comment in comments:
        comment_id = comment[0]
        cursor.execute(f"SELECT DISTINCT VIDEO.videoName FROM VIDEO JOIN COMMENT ON VIDEO.videoID = COMMENT.videoID AND COMMENT.commentID = '{comment_id}';")
        video_name = cursor.fetchone()

        if video_name is not None:
            updated_comment = comment + (video_name[0],)
            updated_comments.append(updated_comment)
        else:
            print(f"No video name found for comment ID: {comment_id}")

    return render_template('comments.html', comments=updated_comments)


@app.route('/sponsors')
def sponsors():
    cursor.execute("SELECT * FROM SPONSOR;")
    sponsors = cursor.fetchall()
    return render_template('sponsors.html', sponsors=sponsors)

@app.route('/posts')
def posts():
    cursor.execute("SELECT * FROM POST;")
    posts = cursor.fetchall()

    updated_posts = []

    for post in posts:
        post_id = post[0]
        cursor.execute(f"SELECT DISTINCT CHANNEL.channelName FROM CHANNEL JOIN POST ON CHANNEL.channelID = POST.channelID AND POST.postID = '{post_id}';")
        channel_name = cursor.fetchone()

        updated_post = post + (channel_name[0],)
        updated_posts.append(updated_post)
    return render_template('posts.html', posts=updated_posts)

if __name__ == '__main__':
    app.run()