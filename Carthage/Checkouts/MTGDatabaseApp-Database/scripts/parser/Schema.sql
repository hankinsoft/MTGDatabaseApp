CREATE TABLE ability (
  abilityId integer PRIMARY KEY AUTOINCREMENT NOT NULL,
  name nvarchar(256) NOT NULL,
  cardCount integer NOT NULL DEFAULT(0)
);

CREATE UNIQUE INDEX abilityIndex ON ability (name ASC);

CREATE TABLE artist (
    artistId integer PRIMARY KEY AUTOINCREMENT NOT NULL,
    name nvarchar(64) NOT NULL DEFAULT('')
);

CREATE TABLE card (
                   multiverseId integer NOT NULL,
                   cardSetId integer NOT NULL,
                   name nvarchar(255) COLLATE NOCASE NOT NULL,
                   type varchar(16) COLLATE NOCASE NOT NULL DEFAULT(''),
                   cost nvarchar(16) NOT NULL DEFAULT(''),
                   convertedManaCost nvarchar(6),
                   color nvarchar(16) NOT NULL DEFAULT(''),
                   rarity nvarchar(16) NOT NULL DEFAULT(''),
                   power integer,
                   toughness integer,
                   "text" nvarchar(256) COLLATE NOCASE NOT NULL DEFAULT(''),
                   flavorText nvarchar(256) DEFAULT(''),
                   artistId integer NOT NULL DEFAULT(''),
                   collectorsNumber nvarchar(16),
                   FOREIGN KEY (cardSetId) REFERENCES cardSet (cardSetId),
                   FOREIGN KEY (artistId) REFERENCES artist (artistId),
                   PRIMARY KEY(multiverseId, collectorsNumber, name)
                   );

CREATE INDEX cardCollectorsNumber ON card (collectorsNumber);
CREATE INDEX cardConvertedManaCost ON card (convertedManaCost);
CREATE INDEX cardRarityIndex ON card (rarity);
CREATE INDEX cardColorIndex ON card (color);
CREATE INDEX cardCostIndex ON card (cost);
CREATE INDEX cardTypeIndex ON card (type);
CREATE INDEX cardNameIndex ON card (name);
CREATE INDEX cardSetIndex ON card (cardSetId);

CREATE TABLE cardSet (
    cardSetId integer PRIMARY KEY NOT NULL,
    name nvarchar(255) NOT NULL,
    releaseDate datetime NOT NULL,
    block char(128),
    type char(128),
    shortName char(3) NOT NULL,
    cardCount integer DEFAULT(0)
);

CREATE INDEX setNameIndex ON cardSet (name);
CREATE INDEX setIdIndex ON cardSet (cardSetId);

CREATE TABLE card_format (
                          multiverseId integer NOT NULL,
                          formatId integer NOT NULL,
                          PRIMARY KEY(multiverseId, formatId)
                          );

CREATE UNIQUE INDEX cardFormatIndex ON card_format (multiverseId ASC, formatId ASC);

CREATE TABLE format (
                     formatId integer PRIMARY KEY AUTOINCREMENT NOT NULL,
                     name nvarchar(256) NOT NULL,
                     cardCount integer DEFAULT(0)
                     );

CREATE UNIQUE INDEX formatNameIndex ON format (name ASC);
CREATE UNIQUE INDEX formatIndex ON format (formatId ASC);

CREATE TABLE settings (
                       name nvarchar(255),
                       value nvarchar(255)
                       );

INSERT INTO settings (name, value) VALUES('databaseVersion', 200);

CREATE VIEW cardAndSet AS

SELECT card.multiverseId, card.name, cardSet.name FROM card INNER JOIN cardSet ON card.cardSetId = cardSet.cardSetId
