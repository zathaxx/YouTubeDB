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