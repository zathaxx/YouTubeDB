-- Queries for YT project 
-- complex queries  = "utilizing more than three tables"

-- Question #1
--(PostDate, VideoViews, Comments)
-- List all videos that was made 5 years ago today, with at least 1 thousand views made by a channel that has over 10 thousand subscriber

SELECT postDate AS 'POST_DATE:', videoViews AS 'Video_Views:', channelName AS 
'Channel Name: ' 
FROM VIDEO, CHANNEL, POST 
WHERE 
SELECT Count (*) subs 
FROM subs.channel = channelSubs < 10000 ON videoViews 
SELECT videoViews
WHERE videoViews > 10000 AND postDate = postDate.year == 2019 JOIN postDate = postDate.month == 12



-- Question #2
-- List all channels that have over 20k subscribers, that were created last year, including their most popular video with the playlist if the video is in one.

-- Question #3
-- List all of the video inside of Mark Robers "Glitterbomb" series playlist that have more views than
-- the average amount of views from all the videos in this series.
SELECT
    video.videoName AS 'Video Name',
    video.videoViews AS 'Video Views'
FROM
    VIDEO video
    JOIN CONTAINS contains ON video.videoID = contains.videoID
    JOIN PLAYLIST playlist ON contains.playlistID = playlist.playlistID
    JOIN CHANNEL channel ON playlist.channelID = channel.channelID
WHERE
    channel.channelName = 'Mark Rober'
    AND playlist.playlistID = 'PLgeXOVaJo_gnexNopBzUKdl3QKoADJlS8'
    AND video.videoViews > (
        SELECT
            AVG(v.videoViews)
        FROM
            CONTAINS c
            JOIN VIDEO v ON c.videoID = v.videoID
        WHERE
            playlistID = 'PLgeXOVaJo_gnexNopBzUKdl3QKoADJlS8'
    );

-- Question #4
-- 

-- Question #5
-- 

-- Example Queries from Iteration 2
-- Query that pull the average video length for a youtuber (Max the Meat Guy)
SELECT
    channelName AS 'Channel Name',
    AVG(videoDuration) AS average_video_length
FROM
    VIDEO
WHERE
    channelID = 'UC_pT_Iz6XjuM-eMTlXghdfw';
-- Query that gets the engagement rates (number of likes, comments, etc).
-- Query that gets number of average views per channel or average channel engagement rates. 
-- Query that gets the the average length of videos within specific genres or categories.
