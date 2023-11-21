-- SQLBook: Code
CREATE TABLE CHANNEL(
    channelID int NOT NULL,
    channelSubs int,
    channelAge int,
    videoCount int,
    channelName varchar(255) NOT NULL,
    channelDescription varchar(255),
    PRIMARY KEY (channelID)
);

CREATE TABLE VIDEO(
    videoID INT NOT NULL,
    videoName varchar(255) NOT NULL,
    videoUploadDate DATE,
    videoLikes INT,
    videoDislikes INT,
    videoDuration,
    videoViews INT,
    description varchar(255),
    PRIMARY KEY (videoID)
);

CREATE TABLE CATEGORY(
    categoryID INT NOT NULL,
    categoryName INT NOT NULL,
    categorySubs INT,
    PRIMARY KEY (categoryID)
);

CREATE TABLE PLAYLIST(
    playlistID INT NOT NULL,
    playlistName INT,
    numOfVideos INT,
    PRIMARY KEY (playlistID)
); 

CREATE TABLE COMMENT(
    
);

CREATE TABLE SPONSOR(
    sponsorName varchar(255) NOT NULL,
    sponsorWebsite VARCHAR(255) NOT NULL,
    sponsorID IN
    PRIMARY KEY (spon)orID

);

CREATE TABLE POST(
    postID INT NOT NULL,
    postDate DATE,
    postDescritption varchar(255),
    postIikes INT,
    postDislikes INT,
    PRIMARY KEY (postID)
);

CREATE TABLE PROMOTES(

);

CREATE TABLE CONTAINS(

);

CREATE TABLE CATEGORIZED_UNDER(
    
);
