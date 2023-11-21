-- SQLBook: Code
CREATE TABLE CHANNEL(
    channelID int NOT NULL,
    channelSubs int,
    channelAge int,
    videoCount int,
    channelName varchar(255) NOT NULL,
    channelDescription varchar(255),
    PRIMARY KEY (channelID);
);

CREATE TABLE VIDEO(
    videoID INT NOT NULL,
    videoName varchar(255) NOT NULL,
    uploadDate DATE,
    likes INT,
    dislikes INT,
    duration,
    views INT,
    description varchar(255),
    PRIMARY KEY (videoID);
);

CREATE TABLE CATEGORY(
    categoryID INT NOT NULL,
    categoryName INT NOT NULL,
    categorySubs INT,
    PRIMARY KEY (categoryID);
);

CREATE TABLE PLAYLIST(
    playlistID INT NOT NULL,
    playlistName INT,
    numOfVideos INT,
    PRIMARY KEY (playlistID);
); 
