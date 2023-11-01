/***Initial Questions**

1. What range of years for baseball games played does the provided database cover? */

SELECT
	MAX(yearid)
	,MIN(yearid)
FROM allstarfull

--It covers from 1933 to 2016

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT *
FROM people

SELECT
	MIN(height)
FROM people

SELECT
	namefirst
	,namelast
	,playerid 
FROM people
WHERE height = 43 -- Eddie Gaedel, gaedeed01

SELECT
	t.teamid
	,t.name
	,a.playerid
	,g_all
FROM appearances a
INNER JOIN people p
ON a.playerid = p.playerid
INNER JOIN teams t
ON a.teamid = t.teamid
WHERE height = 43
GROUP BY t.teamid
	,t.name
	,a.playerid
	,g_all

--Eddie Gaedel was 43 inches tall. He played 1 game for the St.Louis Browns.

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
	
SELECT
	*
FROM schools
WHERE schoolname like '%Vanderbilt%' --schoolid "vandy"

SELECT
	p.namefirst
	,p.namelast
	,SUM(s.salary)
FROM people p
INNER JOIN collegeplaying c
ON p.playerid = c.playerid
INNER JOIN salaries s
ON p.playerid = s.playerid
WHERE c.schoolid = 'vandy'
GROUP BY p.namefirst, p.namelast
ORDER BY SUM(salary) DESC

--David Price who made $245,553,888 in the major leagues after playing for Vanderbilt 

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
 
--SELECT *
--FROM fielding

SELECT
	CASE WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'P' OR pos = 'C' THEN 'Battery' END AS pos_clean
	,SUM(po)
FROM fielding
WHERE yearid = 2016
GROUP BY pos_clean
ORDER BY sum(po) DESC

--Infield had 58934 putouts, Battery had 41424 putouts, and Outfield had 29560 putouts

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT
	FLOOR((yearid/10)*10) AS decades
	,ROUND(AVG(so/g),2) AS strikeouts
	,ROUND(AVG(hr/g),2) AS homeruns
FROM teams t
WHERE FLOOR((yearid/10)*10)>= 1920
GROUP BY decades
ORDER BY decades

--The number of strikeouts and homeruns have been increasing since the 1920's. There was a small decrease in both strikeouts and homeruns during the 1960s to 1980s.

--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
	
/*SELECT
	--playerid,
	SUM(sb + cs) totalattempts
FROM batting
WHERE yearid = 2016
GROUP BY playerid
ORDER BY totalattempts DESC*/

WITH cte AS 
(
	SELECT
	playerid
	,yearid
	,sb
	,cs
	,SUM(sb+cs) AS totalattempts
FROM batting
	GROUP BY playerid
			,yearid
			,sb
			,cs
)
SELECT
	p.namefirst
	,p.namelast
	,(sb * 100)/totalattempts as percentstolen
FROM cte
LEFT JOIN people p
USING (playerid)
WHERE yearid = 2016 AND sb>20
GROUP BY
	p.namefirst
	,p.namelast
	,percentstolen
ORDER BY percentstolen DESC

--Chris Owings had the highest percentage of base theft with 91%
	
--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT
	name
	,W
	,yearid
FROM teams
WHERE yearid>=1970 AND wswin= 'N'
ORDER BY w DESC

--Seattle Mariners won 116 games in the 2001 series but did not win the World Series

SELECT
	name
	,W
	,yearid
FROM teams
WHERE yearid>=1970 AND wswin= 'Y'
ORDER BY w

--looking at over all games played
SELECT
	yearid
	,SUM(g)
FROM teams
WHERE yearid>= 1970
GROUP BY yearid
ORDER BY SUM(g)

--The Dodgers won a World Series with 63 wins in 1981. There was a playerstrike occuring this year and they split the season somehow. There were fewer games played that year over all as well.

SELECT
	name
	,W
	,yearid
FROM teams
WHERE yearid>=1970 AND wswin= 'Y'AND yearid != 1981
ORDER BY w

--St. Louis Cardinals in 2006 had the next smallest


WITH cte AS (
SELECT
	MAX(w) most
	,yearid
FROM teams
WHERE yearid>=1970
GROUP BY yearid
ORDER BY yearid, MAX(w)
)
SELECT
	name
	,w
	,t.yearid
	,SUM(CASE WHEN t.w = cte.most THEN 1
	ELSE 0 END) OVER ()
FROM teams t
LEFT JOIN cte
ON t.yearid = cte.yearid AND t.w =cte.most
WHERE t.yearid BETWEEN 1970 AND 2016
	AND t.wswin= 'Y'
	AND t.yearid <> 1981
ORDER BY yearid, w

--(12/45)*100 = 26.67% of the time the teams that won the most games also won the World Series

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT *
FROM(
SELECT
	'Top 5' type
	,t.name
	,SUM(h.attendance)/SUM(h.games) AS avg_att
	,p.park_name
FROM homegames h
LEFT JOIN teams t
ON h.team = t.teamid AND h.year=t.yearid
LEFT JOIN parks p
ON h.park = p.park
WHERE h.year = 2016 AND h.games>=10
GROUP BY t.name
	,p.park_name
ORDER BY avg_att DESC
LIMIT 5)

UNION

SELECT*
FROM(
SELECT
	'Bottom 5' type
	,t.name
	,SUM(h.attendance)/SUM(h.games) AS avg_att
	,p.park_name
FROM homegames h
LEFT JOIN teams t
ON h.team = t.teamid AND h.year=t.yearid
LEFT JOIN parks p
ON h.park = p.park
WHERE h.year = 2016 AND h.games>=10
GROUP BY t.name
	,p.park_name
ORDER BY avg_att
LIMIT 5)
ORDER BY 1 DESC,3
--Bottom 5

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH cte AS (
SELECT 
	playerid
	,yearid
	,lgid
FROM awardsmanagers
WHERE awardid LIKE 'TSN Manager of the Year' 
		AND lgid='NL'
		AND playerid IN (SELECT
	playerid
FROM awardsmanagers
WHERE awardid LIKE 'TSN Manager of the Year' AND lgid='AL')
UNION
SELECT
	playerid
	,yearid
	,lgid
FROM awardsmanagers
WHERE awardid LIKE 'TSN Manager of the Year' 
	AND lgid='AL'
	AND playerid IN (SELECT 
	playerid
FROM awardsmanagers
WHERE awardid LIKE 'TSN Manager of the Year' 
		AND lgid='NL')
	ORDER BY yearid
)
SELECT
	p.namefirst|| ' ' ||p.namelast AS name
	,t.name
	--*
FROM cte
INNER JOIN managers m
USING (playerid, yearid, lgid)
INNER JOIN teams t
USING (teamid,lgid,yearid)
INNER JOIN people p
USING (playerid)


--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
WITH  cte AS(
	SELECT
	playerid
	,MAX(hr) max
FROM batting
WHERE yearid = 2016
	AND playerid IN
			(SELECT
			playerid
			FROM batting
			GROUP BY playerid)
			--HAVING (COUNT(DISTINCT yearid)>9))  
GROUP BY playerid
)

SELECT
	p.namefirst|| ' ' || p.namelast AS name
	,cte.max AS max
FROM batting AS b
INNER JOIN cte
USING (playerid)
INNER JOIN people p
USING (playerid)
WHERE cte.max > 0 AND EXTRACT(YEARS FROM AGE(p.finalgame::DATE, p.debut::DATE)) >= 10
GROUP BY cte.playerid,p.namefirst|| ' ' || p.namelast, cte.max
HAVING (cte.max=MAX(hr))

--**Open-ended questions**

--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

SELECT
	s.yearid
	,t.name
	,SUM(s.salary)
	,t.w
	,LAG(SUM(s.salary)) OVER (PARTITION BY t.name ORDER BY s.yearid) AS previousyearsalary
	,LAG(t.w) OVER (PARTITION BY t.name ORDER BY s.yearid) AS previousyearwins
FROM salaries s
LEFT JOIN teams t
ON s.yearid = t.yearid AND s.teamid = t.teamid
WHERE s.yearid >= 2000 --AND t.name LIKE 'Detroit%'
GROUP BY t.name
	,s.yearid
	,t.w
ORDER BY s.yearid, SUM(s.salary) 

--There seems to be a very loose correlation between wins and salaries. While there are some instances where salary increase seems to reflect on previous year performance, there are other instances where there is a signifcant salary increase despite a drop in performance. 


--12. In this question, you will explore the connection between number of wins and attendance.
    -- Does there appear to be any correlation between attendance at home games and number of wins?
    -- Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

SELECT
	yearid
	,name
	,w
	,ghome
	,attendance
	,CASE WHEN divwin = 'Y' OR wcwin = 'Y' THEN 'true' ELSE 'false' END AS in_playoffs
	,lead(attendance) OVER (PARTITION BY name ORDER BY yearid) AS followingyearattendance
FROM teams
ORDER BY yearid DESC

--Doing calculations with window functions

WITH cte AS (
SELECT
	yearid
	,name
	,w
	,ghome
	,attendance
	,CASE WHEN divwin = 'Y' OR wcwin = 'Y' THEN 'true' ELSE 'false' END AS in_playoffs
	,lead(attendance) OVER (PARTITION BY name ORDER BY yearid) AS followingyearattendance
FROM teams
ORDER BY yearid DESC)

SELECT
	*
	,CASE WHEN attendance < followingyearattendance THEN 'increase'
	WHEN attendance > followingyearattendance THEN 'decrease' END AS inc_OR_dec
FROM cte

--13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?*/

SELECT
	COUNT(DISTINCT playerid)
	,SUM(COUNT(DISTINCT playerid)) OVER () number_of_pitchers
	,COUNT(DISTINCT playerid)*100/SUM(COUNT(DISTINCT playerid)) OVER() percent_of_total_pitchers
	,throws
FROM people p
INNER JOIN appearances a
USING (playerid)
WHERE a.g_p>0
GROUP BY throws


-- 26% left handed
-- 71% right handed


--Investigating why 324 pitchers had no listed throw but still played games as pitchers.
/*SELECT
	DISTINCT p.playerid
	,a.g_p --where they appeared as a pitcher
FROM people p
INNER JOIN appearances a
USING (playerid)
WHERE p.throws IS NULL AND a.g_p >0*/

SELECT
	--pe.throws
	--DISTINCT playerid
	pi.so/pi.g AS so_per_game
	,AVG(pi.so/pi.g) OVER() AS strikeoutspergame
	--,((COUNT(pe.playerid)/(SELECT COUNT(playerid) FROM people)) *100) OVER() AS percent
FROM people pe
INNER JOIN pitching pi
USING(playerid)
WHERE throws = 'L'
GROUP BY --pe.throws
		--playerid, 
		so_per_game
UNION
SELECT
	--pe.throws
	--DISTINCT playerid
	pi.so/pi.g AS so_per_game
	,AVG(pi.so/pi.g) OVER() AS strikeoutspergame
	--,((COUNT(playerid)/44624) *100) OVER() AS percent
FROM people pe
INNER JOIN pitching pi
USING(playerid)
WHERE throws = 'R'
GROUP BY --pe.throws
		--playerid, 
		so_per_game

--Left Handed pitchers have an average strikeout of 1.57 per game while Right handed pitchers have a 1.54 rate. There is a difference but only over .03 which seems pretty negligible. This might also be realted to the distribution of the handed pitchers as well, the smaller data set will display larger differences than the larger data set. Of all pitchers 26.6% are left handed and 71.0% are right handed. 


SELECT
	p.throws
	--DISTINCT playerid
	,COUNT(DISTINCT playerid)*100/SUM(COUNT(DISTINCT playerid)) OVER () AS award_winners
FROM appearances a
INNER JOIN people p
USING(playerid)
WHERE a.g_p >0 
	--AND p.throws = 'L'
	AND playerid IN (
			SELECT playerid
			FROM awardsplayers
			WHERE awardid LIKE 'Cy%')
GROUP BY --DISTINCT playerid
p.throws

--Left handed pitchers win the Cy Young Award 31% of the time. While right handed pitchers win it 69% of the time. Comparing that to the overall distribution, it seems like left handed pitchers tend to win it slightly more often than right handed pitchers

SELECT
	p.throws
	,COUNT(DISTINCT playerid)*100/SUM(COUNT(DISTINCT playerid)) OVER () AS hall_of_fame
FROM appearances a
INNER JOIN people p
USING(playerid)
WHERE a.g_p >0 
	AND playerid IN (
					SELECT playerid
					FROM halloffame)
GROUP BY p.throws
-- They are also more likely to be inducted into the Hall of Fame than righty's 


WITH cte AS(
SELECT
	p.throws
	,COUNT(DISTINCT playerid)*100/SUM(COUNT(DISTINCT playerid)) OVER () AS award_winners
FROM appearances a
INNER JOIN people p
USING(playerid)
WHERE a.g_p >0 
	AND playerid 
	IN (SELECT playerid
		FROM awardsplayers
		WHERE awardid LIKE 'Cy%')
GROUP BY
p.throws
),
cte2 AS(
SELECT
	p.throws
	,COUNT(DISTINCT playerid)*100/SUM(COUNT(DISTINCT playerid)) OVER () AS hall_of_fame
FROM appearances a
INNER JOIN people p
USING(playerid)
WHERE a.g_p >0 
	AND playerid 
	IN (SELECT playerid
		FROM halloffame
	    WHERE inducted = 'Y')
GROUP BY p.throws
)
SELECT
	COUNT(DISTINCT playerid)
	,cte.award_winners
	,cte2.hall_of_fame
	,COUNT(DISTINCT playerid)*100/SUM(COUNT(DISTINCT playerid)) OVER() percent_of_total_pitchers
	,p.throws
FROM people p
INNER JOIN appearances a
USING (playerid)
INNER JOIN cte
USING(throws)
INNER JOIN cte2
USING(throws)
WHERE a.g_p>0
GROUP BY p.throws
		,cte.award_winners
		,cte2.hall_of_fame


