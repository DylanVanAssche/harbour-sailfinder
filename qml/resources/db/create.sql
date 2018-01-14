-- Drop old tables if already exists
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS people;
DROP TABLE IF EXISTS messages;

-- Create tables
CREATE TABLE matches(
	id TEXT,
	name TEXT,
	createdDate TEXT,
	lastActivityDate TEXT,
	messageCount INTEGER,
	muted INTEGER,
	isSuperLike INTEGER,
	personId TEXT,
	PRIMARY KEY(id),
	FOREIGN KEY(personId) REFERENCES person(personId)
);

CREATE TABLE people(
	id TEXT,
	bio TEXT,
	birthDate TEXT,
	name TEXT,
	dead INTEGER,
	PRIMARY KEY(id)
);

CREATE TABLE messages(
	id TEXT,
	matchId TEXT,
	sendDate TEXT,
	author TEXT,
	receiver TEXT,
	message TEXT,
	PRIMARY KEY(id),
	FOREIGN KEY(matchId) REFERENCES person(matchId)
);
