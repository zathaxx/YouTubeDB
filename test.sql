CREATE TABLE CHANNEL(
    channelID int NOT NULL,
    channelSubs int NOT NULL,
    channelAge int NOT NULL,
    videoCount int NOT NULL,
    channelName varchar(255) NOT NULL,
    channelDescription varchar(255),
    PRIMARY KEY (channelID);
);

CREATE TABLE VIDEO(
    videoID INT NOT NULL,
    videoName varchar(255) NOT NULL,
    uploadDate DATE NOT NULL,
    likes int NOT NULL,
    dislikes int NOT NULL,
    duration int NOT NULL,
    views int NOT NULL,
    description varchar(255),
    PRIMARY KEY (videoID);
);

CREATE TABLE CATEGORY(
    categoryID INT NOT NULL,
    categoryName INT NOT NULL,
    categorySubs INT NOT NULL,
    PRIMARY KEY (categoryID);
);

CREATE TABLE PLAYLIST(
    playlistID INT NOT NULL,
    playlistName INT NOT NULL,
    numOfVideos INT NOT NULL,
    PRIMARY KEY (playlistID);
); 
