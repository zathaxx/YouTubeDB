CREATE TABLE CHANNEL(
    channelID int NOT NULL,
    channelSubs int NOT NULL,
    channelAge int NOT NULL,
    videoCount int NOT NULL,
    channelName varchar(255) NOT NULL,
    channelDescription varchar(255),
    PRIMARY KEY (channelID);
);
