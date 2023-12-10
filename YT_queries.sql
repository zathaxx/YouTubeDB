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
    JOIN CONTAIN contains ON video.videoID = contains.videoID
    JOIN PLAYLIST playlist ON contains.playlistID = playlist.playlistID
    JOIN CHANNEL channel ON playlist.channelID = channel.channelID
WHERE
    channel.channelName = 'Mark Rober'
    AND playlist.playlistID = 'PLgeXOVaJo_gnexNopBzUKdl3QKoADJlS8'
    AND video.videoViews > (
        SELECT
            AVG(v.videoViews)
        FROM
            CONTAIN c
            JOIN VIDEO v ON c.videoID = v.videoID
        WHERE
            playlistID = 'PLgeXOVaJo_gnexNopBzUKdl3QKoADJlS8'
    );

-- Question #4
-- List all the youtubers under the "Science & Technology" catagory that have more subscribers
-- than the average number of subscribers that a "Science & Technology" youtuber has
SELECT
    ch.channelName AS 'YouTuber Name',
    ch.channelSubs AS 'Subscribers'
FROM
    CHANNEL ch
    JOIN CATEGORIZED_UNDER cu ON ch.channelID = cu.channelID
    JOIN CATEGORY cat ON cu.categoryID = cat.categoryID
WHERE
    cat.categoryName = 'Science & Technology'
    AND ch.channelSubs > (
        SELECT
            AVG(ch_sub.channelSubs)
        FROM
            CHANNEL ch_sub
            JOIN CATEGORIZED_UNDER cu_sub ON ch_sub.channelID = cu_sub.channelID
            JOIN CATEGORY cat_sub ON cu_sub.categoryID = cat_sub.categoryID
        WHERE
            cat_sub.categoryName = 'Science & Technology'
    );

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
