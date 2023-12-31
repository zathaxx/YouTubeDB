-- Queries for YT project 
-- complex queries  = "utilizing more than three tables"

-- QUERY #1
--(PostDate, VideoViews, Comments)
-- List all videos that was made 5 years ago today, with at least 1 thousand views made by a channel that has over 10 thousand subscriber
SELECT 
    postDate AS 'POST_DATE:', 
    videoViews AS 'Video_Views:', 
    channelName AS 'Channel Name: ' 
FROM 
    VIDEO, 
    CHANNEL, 
    POST 
WHERE 
    SELECT 
        Count (*) subs 
    FROM 
        subs.channel = channelSubs < 10000 ON videoViews 
    SELECT 
        videoViews
    WHERE 
    videoViews > 10000 
    AND postDate = postDate.year == 2019 
    JOIN postDate = postDate.month == 12;

-- corrected vers of Q1 (returns empty set)
SELECT 
    v.videoID,
    v.videoName,
    v.videoViews,
    c.channelName,
    c.channelSubs,
    p.postDate
FROM 
    VIDEO v
JOIN 
    CHANNEL c ON v.channelID = c.channelID
JOIN 
    POST p ON v.channelID = p.channelID
WHERE 
    c.channelSubs > 10000 
    AND v.videoViews > 1000 
    AND YEAR(p.postDate) = YEAR(CURDATE()) - 5 
    AND MONTH(p.postDate) = MONTH(CURDATE()) 
    AND DAY(p.postDate) = DAY(CURDATE());

-- QUERY #2
-- List all of the video inside of Mark Robers "Glitterbomb" series playlist that have more views than
-- the average amount of views from all the videos in this series.
SELECT
    v.videoName AS 'Video Name',
    v.videoViews AS 'Video Views'
FROM
    VIDEO v
    JOIN CONTAINS co ON v.videoID = co.videoID
    JOIN PLAYLIST p ON co.playlistID = p.playlistID
    JOIN CHANNEL ch ON p.channelID = ch.channelID
WHERE
    ch.channelName = 'Mark Rober'
    AND p.playlistName = 'Glitterbomb Series'
    AND v.videoViews > (
        SELECT
            AVG(v1.videoViews)
        FROM
            CONTAINS c1
            JOIN VIDEO v1 ON c1.videoID = v1.videoID
            JOIN PLAYLIST p1 ON c1.playlistID = p1.playlistID
        WHERE
            p1.playlistName = 'Glitterbomb Series'
    );

-- QUERY #3
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

-- QUERY #3.1
-- List all the youtube videos under the "Science & Technology" category that have more views
-- than the average number of views of videos in the "Science & Technology" category
SELECT
    ch.channelName AS 'Channel Name',
    v.videoID AS 'Video ID',
    v.videoName AS 'Video Name',
    v.videoViews AS 'Views',
    cat.categoryName as 'Category'
FROM
    CHANNEL ch
    JOIN VIDEO v ON v.channelID = ch.channelID
    JOIN CATEGORY cat ON v.categoryID = cat.categoryID
WHERE
    cat.categoryName = 'Music'
    AND v.videoViews > (
        SELECT
            AVG(v1.videoViews)
        FROM
            VIDEO v1
            JOIN CATEGORY cat_sub ON v1.categoryID = cat_sub.categoryID
        WHERE
            cat_sub.categoryName = 'Music'
    );


-- QUERY #4
-- List all the youtubers under the "Science & Technology" catagory that have more videos
-- than the average number of videos that a "Science & Technology" youtuber has
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
    cat_sub.categoryName = 'Science & Technology'
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
                cat_sub_inner.categoryName = 'Science & Technology'
            GROUP BY
                ch_sub_inner.channelID) AS avg_video_count
    );

-- QUERY #4.1
-- This query retrieves details about videos in the "Science & Technology" category, 
-- filtering out videos with a comment count below the average for the category, and presenting the results 
-- in descending order of video views.

SELECT
    v.videoID,
    v.videoName,
    ch.channelName AS 'Channel Name',
    v.videoViews,
    COUNT(c.commentID) AS 'Number of Comments',
    AVG(c.commentLikes) AS 'Average Comment Likes'
FROM
    VIDEO v
    JOIN CHANNEL ch ON v.channelID = ch.channelID
    JOIN COMMENT c ON v.videoID = c.videoID
    JOIN CATEGORY cat ON v.categoryID = cat.categoryID
WHERE
    cat.categoryName = 'Science & Technology'
GROUP BY
    v.videoID, v.videoName, ch.channelName, v.videoViews
HAVING
    COUNT(c.commentID) > (
        SELECT
            AVG(comment_count)
        FROM
            (SELECT
                v_inner.videoID,
                COUNT(c_inner.commentID) AS comment_count
            FROM
                VIDEO v_inner
                JOIN COMMENT c_inner ON v_inner.videoID = c_inner.videoID
                JOIN CATEGORY cat_inner ON v_inner.categoryID = cat_inner.categoryID
            WHERE
                cat_inner.categoryName = 'Science & Technology'
            GROUP BY
                v_inner.videoID) AS avg_comment_count
    )
ORDER BY
    v.videoViews DESC;


-- QUERY #4.2
-- List all the YouTubers in the database with at least one "Science and Technology" video
-- where their most viewed video in that category is above the average views for a video in that category.
SELECT
    CHANNEL.channelName AS 'YouTuber Name',
    VIDEO.videoName AS 'Video Name',
    cat_sub.categoryName
FROM
    CHANNEL ch_sub
    JOIN VIDEO v_sub ON ch_sub.channelID = v_sub.channelID
    JOIN CATEGORY cat_sub ON v_sub.categoryID = cat_sub.categoryID
WHERE
    cat_sub.categoryName = 'Science & Technology'
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
                JOIN CATEGORY cat_sub_inner ON v_sub_inner.categoryID = cat_sub_inner.categoryID
            WHERE
                cat_sub_inner.categoryName = 'Science & Technology'
            GROUP BY
                ch_sub_inner.channelID) AS avg_video_count
    );

-- QUERY #5
-- Find the channel that has the most viewed video matching the category video and channel
SELECT
    ch.channelName AS channelName,
    v.videoName AS mostViewedVideoName,
    v.videoViews AS mostViewedVideoViews
FROM
    CHANNEL ch
    JOIN VIDEO v ON ch.channelID = v.channelID
WHERE
    (v.categoryID, v.videoViews) = (
        SELECT
            video.categoryID,
            video.videoViews AS maxViews
        FROM
            VIDEO video
        WHERE
            video.channelID = ch.channelID
        ORDER BY
            video.videoViews DESC
        LIMIT 1
    );

-- NEW QUERY #5
-- Given a channel name, find their most viewed viewed video, and join the VIDEO, CHANNEL, and CATEGORY tables to display this information.ADD



-- QUERY #6
-- List the top 3 channel within the Education category that has the most enagagement and order it by best to worst
SELECT 
    ch.channelid,
    ch.channelname,
    Avg(commentcount) AS avgCommentsPerVideo
FROM   
    channel ch
    JOIN video v ON ch.channelid = v.channelid
    JOIN (
        SELECT 
            videoid,
            Count(*) AS commentCount
        FROM   
            comment
        GROUP BY 
        videoid) 
        c ON v.videoid = c.videoid
WHERE  
    v.categoryid = (
        SELECT 
            categoryid
        FROM   
            category
        WHERE  
            categoryname = 'Education')
GROUP  BY ch.channelid, ch.channelname
ORDER  BY avgcommentspervideo DESC
LIMIT  3; 
-- QUERY #7
-- Find a channel that has a video at least one video in 3 different category and get the average video duration of all videos
SELECT
    ch.channelID,
    ch.channelName,
    AVG(v.videoDuration) AS avgVideoDuration
FROM
    CHANNEL ch
    JOIN CATEGORIZED_UNDER cu ON ch.channelID = cu.channelID
    JOIN VIDEO v ON ch.channelID = v.channelID
GROUP BY
    ch.channelID, ch.channelName
HAVING
    COUNT(DISTINCT v.categoryID) < 3;

-- QUERY #8
-- What video under the 'Entertainment category that has the highest likes to view ratio?'
SELECT
    v.videoID,
    v.videoName,
    v.videoLikes,
    v.videoViews,
    v.videoLikes / v.videoViews AS likesToViewsRatio
FROM
    VIDEO v
JOIN
    CATEGORY c ON v.categoryID = c.categoryID
WHERE
    c.categoryName = 'Entertainment'
ORDER BY
    likesToViewsRatio DESC
LIMIT 5;

-- QUERY #8
-- Identifies all channels that have posted videos in at least 3 categories and grab the number of average likes 
SELECT
    ch.channelID,
    ch.channelName,
    AVG(po.postLikes) AS avgLikesPerPost
FROM
    CHANNEL ch
    JOIN CATEGORIZED_UNDER cu ON ch.channelID = cu.channelID
    JOIN VIDEO v ON ch.channelID = v.channelID
    JOIN POST po ON ch.channelID = po.channelID
GROUP BY
    ch.channelID, ch.channelName
HAVING
    COUNT(DISTINCT v.categoryID) < 3;

-- QUERY #10
-- Find the top 5 videos with more than 10k views, list the names, video ID, likes to view ratio as well as category name and the channel name that posted it ADD
-- and make the view from descending order based on likes to dislikes as well as limit the searches to 5.
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
    CHANNEL ch ON v.channelID = ch.channelID
JOIN
    CATEGORY c ON v.categoryID = c.categoryID
WHERE
    v.videoViews > 10000
ORDER BY
    likesToViewsRatio DESC
LIMIT 5;

-- QUERY #10 (Improved Version)
-- Find the top 5 videos from a given YouTuber with more than 10k views, list the names, video ID, likes to view ratio as well as category name and the channel name that posted it ADD
-- and make the view from descending order based on likes to dislikes as well as limit the searches to 5.
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
    CHANNEL ch ON v.channelID = ch.channelID and ch.channelID = {first_attribute}
JOIN
    CATEGORY c ON v.categoryID = c.categoryID
WHERE
    v.videoViews > 10000
ORDER BY
    likesToViewsRatio DESC
LIMIT 5;


-- Example Queries from Iteration 2
-- Query that pull the average video length for a youtuber (Max the Meat Guy)
SELECT
    c.channelName AS 'Channel Name',
    AVG(v.videoDuration) AS average_video_length
FROM
    VIDEO v
    JOIN CHANNEL c ON c.channelID = v.channelID
WHERE
    c.channelID = 'UC_pT_Iz6XjuM-eMTlXghdfw'
GROUP BY
    c.channelID, c.channelName;

-- Query that gets the engagement rates for a specific video
-- (number of likes, comments, etc for Mark Robers octopus maze vid).
SELECT
    v.videoName,
    v.videoViews,
    v.videoLikes,
    COUNT(c.commentID)
FROM
    VIDEO v
    JOIN COMMENT c ON v.videoID = c.videoID
WHERE
    v.videoID = '7__r4FVj-EI';

-- Query that gets number of average views per channel or average channel engagement rates
-- Query that gets the the average length of videos within specific genres or categories.

-- List Channels with Most Subscribers
SELECT
    channelID,
    channelName,
    channelSubs
FROM
    CHANNEL
ORDER BY
    channelSubs DESC
LIMIT 10;

-- List Videos with Highest Views
SELECT
    videoID,
    videoName,
    videoViews
FROM
    VIDEO
ORDER BY
    videoViews DESC
LIMIT 10;