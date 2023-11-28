-- SQLBook: Code

CREATE TABLE CHANNEL(
    channelID char(24) NOT NULL,
    channelSubs int,
    channelAge DATE,
    CHECK(channelAge >= '2005-02-13'),
    videoCount int,
    channelName varchar(51) NOT NULL,
    channelDescription varchar(510),
    PRIMARY KEY (channelID)
);

CREATE TABLE VIDEO(
    videoID char(11) NOT NULL,
    channelID char(24) NOT NULL,
    videoName varchar(101) DEFAULT 'Untitled Video',
    videoUploadDate DATE,
    CHECK(videoUploadDate >= '2005-02-13'),
    videoLikes INT,
    CHECK(videoLikes >= 0),
    videoDuration TIME,
    CHECK(videoDuration >= 0),
    videoViews INT,
    CHECK(videoViews >= 0),
    description varchar(510),
    PRIMARY KEY (videoID),
    FOREIGN KEY (channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE
);

-- Post Triggers that check the channelAge upon insert/update
DELIMITER $$

CREATE TRIGGER check_insert_video BEFORE INSERT ON VIDEO 
FOR EACH ROW
BEGIN
    DECLARE channel_age DATE;

    -- Get the channel age from the CHANNEL table
    SET channel_age = (SELECT channelAge FROM CHANNEL WHERE channelID = NEW.channelID);

    -- Check if videoUploadDate is greater than or equal to the channelAge
    IF NEW.videoUploadDate < channel_age THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'videoUploadDate must be greater than or equal to the channelAge';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_insert_video BEFORE UPDATE ON VIDEO 
FOR EACH ROW
BEGIN
    DECLARE channel_age DATE;

    -- Get the channel age from the CHANNEL table
    SET channel_age = (SELECT channelAge FROM CHANNEL WHERE channelID = NEW.channelID);

    -- Check if videoUploadDate is greater than or equal to the channelAge
    IF NEW.videoUploadDate < channel_age THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'videoUploadDate must be greater than or equal to the channelAge';
    END IF;
END$$

DELIMITER ;

CREATE TABLE CATEGORY(
    categoryID INT NOT NULL,
    categoryName varchar(101),
    categorySubs INT,
    CHECK(categorySubs >= 0),
    PRIMARY KEY (categoryID)
);

CREATE TABLE PLAYLIST(
    playlistID INT NOT NULL,
    channelID char(24) NOT NULL,
    playlistName varchar(101) DEFAULT 'Untitled Playlist',
    numOfVideos INT,
    CHECK(numOfVideos >= 0),
    PRIMARY KEY (playlistID),
    FOREIGN KEY (channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE
); 

CREATE TABLE COMMENT(
    commentID INT NOT NULL,
    videoID char(11) NOT NULL,
    channelID char(24) NOT NULL,
    commentDescription varchar(5001),
    commentLikes INT,
    CHECK(commentLikes >= 0),
    commentDate DATE,
    CHECK(commentDate >= '2005-02-13'),
    PRIMARY KEY(commentID, videoID, channelID),
    FOREIGN KEY(videoID) REFERENCES VIDEO(videoID) ON DELETE CASCADE,
    FOREIGN KEY(channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE
);


-- Post Triggers that check the commentDate upon insert/update
DELIMITER $$

CREATE TRIGGER check_insert_video BEFORE INSERT ON COMMENT 
FOR EACH ROW
BEGIN
    DECLARE channel_age DATE;

    -- Get the channel age from the CHANNEL table
    SET channel_age = (SELECT channelAge FROM CHANNEL WHERE channelID = NEW.channelID);

    -- Check if commentDate is greater than or equal to the channelAge
    IF NEW.commentDate < channel_age THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'commentDate must be greater than or equal to channelAge';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_insert_video BEFORE UPDATE ON COMMENT 
FOR EACH ROW
BEGIN
    DECLARE channel_age DATE;

    -- Get the channel age from the CHANNEL table
    SET channel_age = (SELECT channelAge FROM CHANNEL WHERE channelID = NEW.channelID);

    -- Check if commentDate is greater than or equal to the channelAge
    IF NEW.commentDate < channel_age THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'commentDate must be greater than or equal to channelAge';
    END IF;
END$$

DELIMITER ;

CREATE TABLE SPONSOR(
    sponsorName varchar(101) NOT NULL,
    sponsorWebsite VARCHAR(255),
    PRIMARY KEY (sponsorName)
);

CREATE TABLE POST(
    postID INT NOT NULL,
    channelID char(24) NOT NULL,
    postDate DATE,
    CHECK(postDate >= '2005-02-13'),
    postDescription varchar(510),
    postLikes INT,
    CHECK(postLikes >= 0),
    PRIMARY KEY (postID),
    FOREIGN KEY (channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE
);

-- Post Triggers that check the postDate upon insert/update
DELIMITER $$

CREATE TRIGGER check_insert_video BEFORE INSERT ON POST 
FOR EACH ROW
BEGIN
    DECLARE channel_age DATE;

    -- Get the channel age from the CHANNEL table
    SET channel_age = (SELECT channelAge FROM CHANNEL WHERE channelID = NEW.channelID);

    -- Check if postDate is greater than or equal to the channelAge
    IF NEW.postDate < channel_age THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'postDate must be greater than or equal to the channelAge';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER check_insert_video BEFORE UPDATE ON POST 
FOR EACH ROW
BEGIN
    DECLARE channel_age DATE;

    -- Get the channel age from the CHANNEL table
    SET channel_age = (SELECT channelAge FROM CHANNEL WHERE channelID = NEW.channelID);

    -- Check if postDate is greater than or equal to the channelAge
    IF NEW.postDate < channel_age THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'postDate must be greater than or equal to the channelAge';
    END IF;
END$$

DELIMITER ;

CREATE TABLE PROMOTES(
    videoID char(11) NOT NULL,
    sponsorName varchar(101) NOT NULL,
    FOREIGN KEY(videoID) REFERENCES VIDEO (videoID) ON DELETE CASCADE,
    FOREIGN KEY(sponsorName) REFERENCES SPONSOR (sponsorName) ON DELETE CASCADE
);

CREATE TABLE CONTAINS(
    categoryID INT NOT NULL,
    channelID char(24) NOT NULL,
    FOREIGN KEY (categoryID) REFERENCES CATEGORY (categoryID) ON DELETE CASCADE,
    FOREIGN KEY (channelID) REFERENCES CHANNEL (channelID) ON DELETE CASCADE
);

CREATE TABLE CATEGORIZED_UNDER(
    channelID char(24) NOT NULL,
    categoryID INT NOT NULL,
    FOREIGN KEY(channelID) REFERENCES CHANNEL(channelID) ON DELETE CASCADE,
    FOREIGN KEY(categoryID) REFERENCES CATEGORY(categoryID) ON DELETE CASCADE
);
