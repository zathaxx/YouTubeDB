-- Queries for YT project 
-- complex queries  = "utilizing more than three tables"

-- Question #1
--(PostDate, VideoViews, Comments)
-- List all videos that was made 5 years ago today, with at least 1 thousand views and has over 5 comments.  

Select Post_Date AS 'POST_DATE:', Video_views As 'Video_Views:', Comment 


-- Question #2
-- List all channels that have over 20k subscribers, that were created last year, including their most popular video with the playlist if the video is in one. 