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
FULL JOIN cte
ON t.yearid = cte.yearid AND t.w =cte.most
WHERE t.yearid>=1970 
	AND t.wswin= 'Y'
	AND t.yearid != 1981
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


SELECT
	p.namefirst||' ' ||p.namelast name
	,t.name
	,a.yearid
	,a.lgid
FROM awardsmanagers a
LEFT JOIN people p
USING(playerid)
LEFT JOIN managers m
ON a.playerid = m.playerid AND a.lgid = m.lgid AND a.yearid = m.yearid
LEFT JOIN teams t
ON m.teamid = t.teamid AND m.lgid =t.lgid AND m.yearid = t.yearid
WHERE a.awardid LIKE 'TSN%' AND (a.lgid = 'NL' OR a.lgid = 'AL')
GROUP BY p.namefirst||' ' ||p.namelast,t.name, a.yearid, a.lgid
ORDER BY a.yearid


--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH maxhr AS (
SELECT
	playerid
	,hr 
	,yearid AS years
FROM batting 
GROUP BY playerid, hr, years
ORDER BY years DESC, MAX(hr) DESC
)
SELECT
	b.playerid
	,b.hr
	--,CASE WHEN maxhr.hr = MAX(b.hr) THEN 'true'
	--ELSE 'false' END AS hr2016
FROM batting b
INNER JOIN maxhr
ON maxhr.playerid = b.playerid --AND maxhr.mhr = b.hr
WHERE maxhr.hr = b.hr
	AND yearid = 2016
	AND maxhr.hr != 0
	AND maxhr.years>=10
GROUP BY b.playerid
		,b.hr
		--,hr2016
HAVING(maxhr.hr = MAX(b.hr))

--**Open-ended questions**

--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

--12. In this question, you will explore the connection between number of wins and attendance.
    --<ol type="a">
    --  <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
    --  <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the --playoffs means either being a division winner or a wild card winner.</li>
   -- </ol>


--13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?*/
