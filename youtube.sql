-- SQLBook: Code
-- SQLBook: Code
CREATE TABLE CHANNEL(
    channelID int NOT NULL,
    channelSubs int,
    channelAge DATE,
    CHECK(channnelAge >= '2005-02-13'),
    videoCount int,
    channelName varchar(51) NOT NULL,
    channelDescription varchar(510),
    PRIMARY KEY (channelID)
);

CREATE TABLE VIDEO(
    videoID INT NOT NULL,
    channelID int NOT NULL,
    videoName varchar(101) DEFAULT 'Untitled Video',
    videoUploadDate DATE, -- video date must be a date that is either on the same day or after the channel age.
    CHECK(videoUploadDate >= '2005-02-13'),
    videoLikes INT,
    CHECK(videoLikes >= 0),
    
    videoDislike
    CHECK(videoDislikes >= 0),
    
    videoDuration TIME,
    CHECK(videoDuration >= 0),
    videoViews INT,
    CHECK(videoViews >= 0),
    description varchar(510),
    PRIMARY KEY (videoID),
    FOREIGN KEY (channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE
);

CREATE TABLE CATEGORY(
    categoryID INT NOT NULL,
    categoryvarchar(101),
    categorySubs INT,
    CHECK(categorySubs >= 0),
    PRIMARY KEY (categoryID)
);

CREATE TABLE PLAYLIST(
    playlistID INT NOT NULL,
    channelID INT NOT NULL,
    playlistName varchar(101) DEFAULT 'Untitled Playlist',
    numOfVideos INT,
    CHECK(numOfVideos >= 0),
    PRIMARY KEY (playlistID),
    FOREIGN KEY (channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE
); 

CREATE TABLE COMMENT(
    commentID INT NOT NULL,
    videoID INT NOT NULL,
    channelID int NOT NULL,
    commentDescription varchar(5001),
    commentLikes INT,
    CHECK(commentLikes >= 0),
    commentDate DATE,
    CHECK(commentDate >= '2005-02-13'), -- comment date must be a date that is either on the same day or after the video upload date.
    PRIMARY KEY(commentID, videoID, channelID),
    FOREIGN KEY(videoID) REFERENCES VIDEO(videoID) ON DELETE CASCADE,
    FOREIGN KEY(channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE
);

CREATE TABLE SPONSOR(
    sponsorID INT NOT NULL,
    sponsorName varchar(101) NOT NULL,
    sponsorWebsite VARCHAR(255),
    --Check for https:// and domain name
    PRIMARY KEY (sponsorID)
);

CREATE TABLE POST(
    postID INT NOT NULL,
    channelID INT NOT NULL,
    postDate DATE,
    CHECK(postDate >= '2005-02-13'), -- post date must be a date that is either on the same day or after the channel age.
    postDescritption varchar(510),
    postLikes INT,
    CHECK(postLikes >= 0),
    postDislikes INT,
    CHECK(postDislikes >= 0),
    PRIMARY KEY (postID)
    FOREIGN KEY (channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE
);

CREATE TABLE PROMOTES(
    videoID INT NOT NULL,
    sponsorID INT NOT NULL,
    FOREIGN KEY(videoID) REFERENCES VIDEO (videoID) ON DELETE CASCADE,
    FOREIGN KEY(sponsor) REFERENCES SPONSOR (sponsorID) ON DELETE CASCADE
);

CREATE TABLE CONTAINS(
    categoryID INT NOT NULL,
    channelID INT NOT NULL
    FOREIGN KEY (category) REFERENCES CATEGORY (categoryID) ON DELETE CASCADE,
    FOREIGN KEY (channel) REFERENCES CHANNEL (channelID) ON DELETE CASCADE
);

CREATE TABLE CATEGORIZED_UNDER(
    channelID INT NOT NULL,
    categoryID INT NOT NULL,
    FOREIGN KEY(channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE,
    FOREIGN KEY(categoryID) REFERENCES CATEGORY(categoryID) ON DELETE CASCADE
);
