DROP DATABASE ipl_analysis;
CREATE DATABASE ipl_analysis;
USE ipl_analysis;
CREATE TABLE teams(
team_id INT PRIMARY KEY,
team_name VARCHAR(50) NOT NULL,
coach VARCHAR(50) NOT NULL,
home_ground VARCHAR(50)
);

CREATE TABLE players(
player_id INT PRIMARY KEY,
player_name VARCHAR(50) NOT NULL,
team_id INT,
FOREIGN KEY (team_id) references teams(team_id),
position VARCHAR(50),
nationality VARCHAR(50) NOT NULL
);

CREATE TABLE matches(
match_id INT PRIMARY KEY,
team1_id INT,
FOREIGN KEY (team1_id) references teams(team_id),
team2_id INT,
FOREIGN KEY (team2_id) references teams(team_id),
venue VARCHAR(50) NOT NULL,
winner_team_id INT,
FOREIGN KEY (winner_team_id) references teams(team_id),
match_date DATE 
);

CREATE TABLE batting_scorecard(
batting_id INT PRIMARY KEY,
match_id INT ,
FOREIGN KEY (match_id) references matches(match_id),
player_id INT,
FOREIGN KEY (player_id) references players(player_id),
runs INT,
balls INT,
fours INT,
sixes INT,
strike_rate FLOAT
);

CREATE TABLE bowling_scorecard(
bowling_id INT,
match_id INT,
FOREIGN KEY (match_id) references matches(match_id),
player_id INT,
FOREIGN KEY (player_id) references players(player_id),
wickets INT,
overs FLOAT,
economy FLOAT
);

INSERT INTO teams VALUES
(1, 'Mumbai Indians', 'Mark Boucher', 'Wankhede Stadium'),
(2, 'Chennai Super Kings', 'Stephen Fleming', 'Chepauk Stadium'),
(3, 'Royal Challengers Bangalore', 'Andy Flower', 'Chinnaswamy Stadium'),
(4, 'Kolkata Knight Riders', 'Chandrakant Pandit', 'Eden Gardens'),
(5, 'Rajasthan Royals', 'Kumar Sangakkara', 'Sawai Mansingh Stadium');

INSERT INTO players VALUES
(101, 'Rohit Sharma', 1, 'Batsman', 'India'),
(102, 'Jasprit Bumrah', 1, 'Bowler', 'India'),
(103, 'MS Dhoni', 2, 'Wicketkeeper', 'India'),
(104, 'Ravindra Jadeja', 2, 'All-Rounder', 'India'),
(105, 'Virat Kohli', 3, 'Batsman', 'India'),
(106, 'Mohammed Siraj', 3, 'Bowler', 'India'),
(107, 'Andre Russell', 4, 'All-Rounder', 'West Indies'),
(108, 'Sunil Narine', 4, 'Bowler', 'West Indies'),
(109, 'Sanju Samson', 5, 'Wicketkeeper', 'India'),
(110, 'Yuzvendra Chahal', 5, 'Bowler', 'India');

INSERT INTO matches VALUES
(1001, 1, 2, 'Mumbai', 1, '2025-03-20'),
(1002, 3, 4, 'Bangalore', 4, '2025-03-22'),
(1003, 2, 5, 'Chennai', 2, '2025-03-24'),
(1004, 1, 3, 'Mumbai', 3, '2025-03-26'),
(1005, 4, 5, 'Kolkata', 4, '2025-03-28');

INSERT INTO batting_scorecard VALUES
(1, 1001, 101, 78, 52, 8, 3, 150.00),
(2, 1001, 103, 45, 30, 4, 2, 150.00),
(3, 1002, 105, 92, 58, 10, 4, 158.62),
(4, 1002, 107, 65, 28, 5, 6, 232.14),
(5, 1003, 104, 40, 25, 3, 2, 160.00),
(6, 1003, 109, 70, 48, 7, 2, 145.83),
(7, 1004, 101, 55, 40, 5, 2, 137.50),
(8, 1004, 105, 88, 54, 9, 3, 162.96),
(9, 1005, 107, 72, 35, 6, 5, 205.71),
(10, 1005, 109, 60, 44, 5, 2, 136.36);

INSERT INTO bowling_scorecard VALUES
(1, 1001, 102, 3, 4, 6.50),
(2, 1001, 104, 2, 4, 7.00),
(3, 1002, 106, 1, 4, 9.20),
(4, 1002, 108, 4, 4, 5.75),
(5, 1003, 110, 3, 4, 6.00),
(6, 1003, 104, 1, 4, 7.50),
(7, 1004, 102, 2, 4, 8.00),
(8, 1004, 106, 3, 4, 6.80),
(9, 1005, 108, 2, 4, 5.50),
(10, 1005, 110, 4, 4, 6.20);

SELECT COUNT(match_id)
FROM matches;
SELECT COUNT(player_id)
FROM players;
SELECT MAX(runs)
FROM batting_scorecard;
SELECT SUM(wickets)
FROM bowling_scorecard;

SELECT 
players.player_name, SUM(runs)
FROM batting_scorecard
LEFT JOIN players
ON players.player_id=batting_scorecard.player_id
GROUP BY player_name
ORDER BY SUM(runs) DESC;

SELECT 
	players.player_name, 
	SUM(wickets) as total_wicket
FROM bowling_scorecard
LEFT JOIN players
ON players.player_id=bowling_scorecard.player_id
GROUP BY players.player_name
ORDER BY total_wicket DESC;

SELECT 
teams.team_name, 
count(winner_team_id) as total_win
FROM teams
LEFT JOIN matches
ON teams.team_id=matches.winner_team_id
GROUP BY team_name
ORDER BY COUNT(winner_team_id) DESC;

SELECT
	players.player_name,
    teams.team_name
FROM players
LEFT JOIN teams
ON players.team_id=teams.team_id;

SELECT
	teams.team_name,
    matches.venue
FROM teams
LEFT JOIN matches
ON teams.team_id=matches.winner_team_id;

SELECT player.team_id,players.player_name, SUM(runs)
FROM batting_scorecard
LEFT JOIN players
ON players.player_id=batting_scorecard.player_id
GROUP BY player_name,team_id
ORDER BY SUM(runs) DESC;

SELECT players.player_name, SUM(runs)
FROM batting_scorecard
LEFT JOIN players
ON players.player_id=batting_scorecard.player_id
GROUP BY player_name
ORDER BY SUM(runs) DESC
LIMIT 5;

SELECT players.player_name, AVG(runs) as average 
FROM batting_scorecard
LEFT JOIN players
ON players.player_id=batting_scorecard.player_id
GROUP BY player_name
HAVING average>(SELECT AVG(runs) FROM batting_scorecard)
ORDER BY AVG(runs) DESC;

SELECT 
    player_name,
    total_runs,

    DENSE_RANK() OVER(ORDER BY total_runs DESC) AS run_rank

FROM (
        SELECT 
            players.player_name,
            SUM(runs) AS total_runs

        FROM batting_scorecard

        LEFT JOIN players
        ON players.player_id = batting_scorecard.player_id

        GROUP BY players.player_name

     ) AS players_total

LIMIT 5;