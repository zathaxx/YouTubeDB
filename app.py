from flask import Flask, request, render_template, redirect, url_for, session
from flask_session import Session
from flask_login import LoginManager
import mysql.connector
import os
from dotenv import load_dotenv
from youtube import *
import random

load_dotenv()

db = mysql.connector.connect(
  host="localhost",
  user=os.environ["USERNAME"],
  password=os.environ["PASSWORD"],
  db="youtube"
)

cursor = db.cursor()

app = Flask(__name__, static_url_path='/static')

app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

PASSWORD = os.environ["S_PASSWORD"]

@app.route('/')
def home():
    return render_template('index.html')

@app.route("/login", methods=["POST", "GET"])
def login():
    path = request.args.get("redirect", "/")
    if request.method == "POST":
        session["password"] = request.form.get("password")
        return redirect(path)
    else:
      return render_template("login.html", path=path)

@app.route('/channels', methods=['GET', 'POST'])
def channels():
    if session.get("password") != PASSWORD:
        return redirect(url_for("login", redirect="/channels"))
    
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

@app.route('/videos', methods=['GET', 'POST'])
def videos():
    if session.get("password") != PASSWORD:
        return redirect(url_for("login", redirect="/videos"))
    if request.method == 'POST':
        video_id = request.form['video_id']
        if video_id:
            query = get_video(video_id)
            channel_id = query[42:66]
            cursor.execute(f"SELECT channelID FROM CHANNEL WHERE channelID = '{channel_id}';")
            result = cursor.fetchone()
            if result is None:
                channel_query = get_channel(channel_id)
                cursor.execute(channel_query)
                db.commit()
            cursor.execute(query)
            db.commit()
            return redirect(url_for('videos'))

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


@app.route('/delete_video/<string:video_id>', methods=['POST'])
def delete_video(video_id):
    if video_id:
        query = f"DELETE FROM VIDEO WHERE videoID = '{video_id}';"
        cursor.execute(query)
        db.commit()
    return redirect(url_for('videos'))

@app.route('/update_video/<string:video_id>', methods=['POST'])
def update_video_route(video_id):
    if video_id:
        update_query = update_video(video_id)
        cursor.execute(update_query)
        db.commit()
    return redirect(url_for('videos'))

@app.route('/playlists', methods=['GET', 'POST'])
def playlists():
    if session.get("password") != PASSWORD:
        return redirect(url_for("login", redirect="/playlists"))
    if request.method == 'POST':
        playlist_id = request.form['playlist_id']
        if playlist_id:
            query = get_playlist(playlist_id)
            cursor.execute(query)
            db.commit()
            return redirect(url_for('playlists'))
    
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

@app.route('/delete_playlist/<string:playlist_id>', methods=['POST'])
def delete_playlist(playlist_id):
    if playlist_id:
        query = f"DELETE FROM PLAYLIST WHERE playlistID = '{playlist_id}';"
        cursor.execute(query)
        db.commit()
    return redirect(url_for('playlists'))

@app.route('/update_playlist/<string:playlist_id>', methods=['POST'])
def update_playlist_route(playlist_id):
    if playlist_id:
        update_query = update_playlist(playlist_id)
        cursor.execute(update_query)
        db.commit()
    return redirect(url_for('playlists'))


@app.route('/comments', methods=['GET', 'POST'])
def comments():
    if session.get("password") != PASSWORD:
        return redirect(url_for("login", redirect="/comments"))        
    if request.method == 'POST':
        video_id = request.form['video_id']
        if video_id:
            top_comments_sql = get_top_comments(video_id)

            if top_comments_sql:
                for comment_sql in top_comments_sql:
                    cursor.execute(comment_sql)
                    db.commit()
    
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

@app.route('/delete_comment/<string:comment_id>', methods=['POST'])
def delete_comment(comment_id):
    if comment_id:
        query = f"DELETE FROM COMMENT WHERE commentID = '{comment_id}';"
        cursor.execute(query)
        db.commit()
    return redirect(url_for('comments'))

@app.route('/update_comment/<string:comment_id>', methods=['POST'])
def update_comment_route(comment_id):
    if comment_id:
        query= update_comment(comment_id)
        cursor.execute(query)
        db.commit()
    return redirect(url_for('comments'))

@app.route('/sponsors')
def sponsors():
    if session.get("password") != PASSWORD:
        return redirect(url_for("login", redirect="/sponsors"))
    cursor.execute("SELECT * FROM SPONSOR;")
    sponsors = cursor.fetchall()
    return render_template('sponsors.html', sponsors=sponsors)

@app.route('/insert_sponsor', methods=['POST'])
def insert_sponsor():
    if request.method == 'POST':
        sponsor_name = request.form['sponsor_name']
        sponsor_website = request.form['sponsor_website']

        if sponsor_name and sponsor_website:
            query = f"INSERT INTO SPONSOR VALUES ('{sponsor_name}', '{sponsor_website}');"
            cursor.execute(query)
            db.commit()

    return redirect(url_for('sponsors'))

@app.route('/delete_sponsor/<string:sponsor_id>', methods=['POST'])
def delete_sponsor(sponsor_id):
    if sponsor_id:
        query = f"DELETE FROM SPONSOR WHERE sponsorName = '{sponsor_id}';"
        cursor.execute(query)
        db.commit()
    return redirect(url_for('sponsors'))

@app.route('/update_sponsor/<string:sponsor_id>', methods=['POST'])
def update_sponsor(sponsor_id):
    if sponsor_id:
        updated_website = request.form['updated_website']
        update_query = f"UPDATE SPONSOR SET sponsorWebsite = '{updated_website}' WHERE sponsorName = '{sponsor_id}';"
        cursor.execute(update_query)
        db.commit()
    return redirect(url_for('sponsors'))

@app.route('/posts')
def posts():
    if session.get("password") != PASSWORD:
        return redirect(url_for("login", redirect="/posts"))
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

@app.route('/insert_post', methods=['POST'])
def insert_post():
    if request.method == 'POST':
        channel_id = request.form['channel_id']
        post_description = request.form['post_description']
        post_date = request.form['post_date']
        post_likes = request.form['post_likes']
        post_description=clean_text(post_description)


        if channel_id and post_description and post_date and post_likes:
            postID = random.randint(100000, 999999) 
            insert_query = (
                "INSERT INTO POST "
                f"VALUES ({postID}, '{channel_id}', '{post_date}', '{post_description}', {post_likes});"
            )
            cursor.execute(insert_query)
            db.commit()
    return redirect(url_for('posts'))

@app.route('/delete_post/<string:post_id>', methods=['POST'])
def delete_post(post_id):
    if post_id:
        query = f"DELETE FROM POST WHERE postID = '{post_id}';"
        cursor.execute(query)
        db.commit()
    return redirect(url_for('posts'))

@app.route('/update_post/<string:post_id>', methods=['POST'])
def update_post(post_id):
    if post_id:
        updated_contents = request.form['updated_contents']
        updated_contents = clean_text(updated_contents)
        update_query = f"UPDATE POST SET postDescription = '{updated_contents}' WHERE postID = '{post_id}';"
        cursor.execute(update_query)
        db.commit()
    return redirect(url_for('posts'))

@app.route('/query', methods=['GET', 'POST'])
def query():
    results = None
    query_type = None
    headers = []

    if request.method == 'POST':
        query_type = request.form.get('queryType')
        first_param = request.form.get('first_param')
        print("First Param Value: ", first_param)
        second_param = request.form.get('second_param')
        print("Second Param Value: ", second_param)

        sql_query = ""

        if query_type:
            if query_type == '1':
                sql_query = print(f"SELECT * FROM CHANNEL ORDER BY channelSubs DESC LIMIT 10;")
            elif query_type == '2':
                sql_query = print(f"SELECT * FROM VIDEO ORDER BY videoViews DESC LIMIT 10;")
            elif query_type == '3':
                sql_query = f"""
                    SELECT
                        v.videoID,
                        v.videoName,
                        v.videoLikes,
                        v.videoViews,
                        v.videoLikes / v.videoViews AS likesToViewsRatio,
                        ch.channelName,
                        c.categoryName
                    FROM
                        VIDEO v
                    JOIN
                        CHANNEL ch ON v.channelID = ch.channelID and ch.channelName = '{first_param}'
                    JOIN
                        CATEGORY c ON v.categoryID = c.categoryID
                    WHERE
                        v.videoViews > 10000
                    ORDER BY
                        likesToViewsRatio DESC
                    LIMIT 5;
                """
            elif query_type == '4':
                sql_query = f"""
                    SELECT
                        v.videoName AS 'Video Name',
                        v.videoViews AS 'Video Views'
                    FROM
                        VIDEO v
                        JOIN CONTAINS co ON v.videoID = co.videoID
                        JOIN PLAYLIST p ON co.playlistID = p.playlistID
                        JOIN CHANNEL ch ON p.channelID = ch.channelID
                    WHERE
                        ch.channelName = '{first_param}'
                        AND p.playlistName = '{second_param}'
                        AND v.videoViews > (
                            SELECT
                                AVG(v1.videoViews)
                            FROM
                                CONTAINS c1
                                JOIN VIDEO v1 ON c1.videoID = v1.videoID
                                JOIN PLAYLIST p1 ON c1.playlistID = p1.playlistID
                            WHERE
                                p1.playlistName = '{second_param}'
                            );
                """
            elif query_type == '5':
                sql_query = f"""
                    SELECT
                        ch.channelName AS 'YouTuber Name',
                        ch.channelSubs AS 'Subscribers'
                    FROM
                        CHANNEL ch
                        JOIN CATEGORIZED_UNDER cu ON ch.channelID = cu.channelID
                        JOIN CATEGORY cat ON cu.categoryID = cat.categoryID
                    WHERE
                        cat.categoryName = '{first_param}'
                        AND ch.channelSubs > (
                            SELECT
                                AVG(ch_sub.channelSubs)
                            FROM
                                CHANNEL ch_sub
                                JOIN CATEGORIZED_UNDER cu_sub ON ch_sub.channelID = cu_sub.channelID
                                JOIN CATEGORY cat_sub ON cu_sub.categoryID = cat_sub.categoryID
                            WHERE
                                cat_sub.categoryName = '{first_param}'
                        );
                """
            elif query_type == '6':
                sql_query = f"""
                    SELECT
                        ch_sub.channelID,
                        ch_sub.channelName AS 'YouTuber Name',
                        COUNT(v_sub.videoID) AS 'Number of Videos'
                    FROM
                        CHANNEL ch_sub
                        JOIN VIDEO v_sub ON ch_sub.channelID = v_sub.channelID
                        JOIN CATEGORIZED_UNDER cu_sub ON ch_sub.channelID = cu_sub.channelID
                        JOIN CATEGORY cat_sub ON cu_sub.categoryID = cat_sub.categoryID
                    WHERE
                        cat_sub.categoryName = '{first_param}'
                    GROUP BY
                        ch_sub.channelID, ch_sub.channelName
                    HAVING
                        COUNT(v_sub.videoID) > (
                            SELECT
                                AVG(video_count)
                            FROM
                                (SELECT
                                    ch_sub_inner.channelID,
                                    COUNT(v_sub_inner.videoID) AS video_count
                                FROM
                                    CHANNEL ch_sub_inner
                                    JOIN VIDEO v_sub_inner ON ch_sub_inner.channelID = v_sub_inner.channelID
                                    JOIN CATEGORIZED_UNDER cu_sub_inner ON ch_sub_inner.channelID = cu_sub_inner.channelID
                                    JOIN CATEGORY cat_sub_inner ON cu_sub_inner.categoryID = cat_sub_inner.categoryID
                                WHERE
                                    cat_sub_inner.categoryName = '{first_param}'
                                GROUP BY
                                    ch_sub_inner.channelID) AS avg_video_count
                        );
                """

            cursor.execute(sql_query)
            results = cursor.fetchall()
            headers = [desc[0] for desc in cursor.description]

    return render_template('query.html', results=results, headers=headers, query_type=query_type)

if __name__ == '__main__':
    app.run()
