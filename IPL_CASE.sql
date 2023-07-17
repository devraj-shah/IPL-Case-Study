create database IPL;

use IPL;

select * 
from ball;

select *
from matches;

alter table matches
add date1 date;


select date0
from matches;

select str_to_date(date0, "%Y-%m-%d")
from matches;

update matches
SET date1 = str_to_date(date0, "%Y-%m-%d");

alter table matches
rename column date to date0;

SET SQL_SAFE_UPDATES = 0;

/* Select the top 20 rows of the deliveries table. */
select *
from ball
order by id limit 20;

/* Select the top 20 rows of the matches table.*/
select *
from matches
order by id limit 20;


/* Fetch data of all the matches played on 2nd May 2013.*/
select *
from matches
where date1 = "2013-05-02";

/* Fetch data of all the matches where the margin of victory is more than
100 runs.*/
select *
from matches
where result = "runs" and result_margin > 100;

/* Fetch data of all the matches where the final scores of both teams tied
and order it in descending order of the date.*/
select *
from matches
where result = "tie"
order by date1 desc;

/* Get the count of cities that have hosted an IPL match.*/
select count(distinct(city))
from matches;

/* Create table deliveries_v02 with all the columns of deliveries and an
additional column ball_result containing value boundary, dot or other
depending on the total_run (boundary for &gt;= 4, dot for 0 and other for any
other number)*/
create table deliveries_v02 as 
select *,
case when total_runs>=4 then "Boundary"
	when total_runs = 0 then "Dot"
	else "Other"
end as Ball_result
from ball;

/* Write a query to fetch the total number of boundaries and dot balls*/
	/* Not Grouped*/
	select count(*) as NumberofBoundariesandDots
	from deliveries_v02
	where Ball_result not regexp "Other";

	/* Grouped*/
	select Ball_result, count(*) as NumberofBoundariesandDots
	from deliveries_v02
	where Ball_result not regexp "Other"
	group by (Ball_result);
    

/* Write a query to fetch the total number of boundaries scored by each
team */
select batting_team, count(*) as `Total Boundaries`
from deliveries_v02
where ball_result = "Boundary"
group by batting_team;

/* Write a query to fetch the total number of dot balls bowled by each
team */
select bowling_team, count(*) as `Total Dots`
from deliveries_v02
where ball_result = "Dot"
group by bowling_team;

/*Write a query to fetch the total number of dismissals by dismissal kinds*/
select dismissal_kind, sum(is_wicket)
from deliveries_v02
group by dismissal_kind
having dismissal_kind <> "NA";

/* Write a query to get the top 5 bowlers who conceded maximum extra
runs*/
select bowler, sum(extra_runs) as TotalExtras
from deliveries_v02
group by bowler
order by TotalExtras Desc limit 5;

/* Write a query to create a table named deliveries_v03 with all the
columns of deliveries_v02 table and two additional column (named venue
and match_date) of venue and date from table matches*/
create table deliveries_v03 as 
(select d.id, d.inning, d.over, d.ball, d.batsman, d.non_striker, d.bowler, d.batsman_runs, d.extra_runs,
d.total_runs, d.is_wicket, d.dismissal_kind, d.player_dismissed, d.fielder, d.extras_type, d.batting_team,
d.bowling_team, d.venue, d.match_date, d.ball_result, m.venue as matchvenue, m.date1 as matchdate
from deliveries_v02 d join matches m
where d.id = m.id);

/* Write a query to fetch the total runs scored for each venue and order it
in the descending order of total runs scored.*/
select matchvenue as Venue, sum(total_runs) as RunsScored
from deliveries_v03
group by matchvenue
order by RunsScored desc;

/* Write a query to fetch the year-wise total runs scored at Eden Gardens
and order it in the descending order of total runs scored.*/
select year(matchdate)
from deliveries_v03
where matchvenue regexp "Eden Gardens"
group by year(matchdate)
order by TotalRuns desc;

/* In conclusion, through the implementation of SQL, IPL teams can make data-driven decisions, 
unearth hidden talents, and fine-tune their strategies for each match scenario. 
IPL franchises can optimize player selection, create strategic team compositions, 
and analyze player performance to drive overall team success. */

/* Create a new table deliveries_v04 with the first column as ball_id
containing information of match_id, inning, over and ball separated by&#39;(For
ex. 335982-1-0-1 match_idinning-over-ball) and rest of the columns same
as deliveries_v03)*/
create table deliveries_v04 as
select * from deliveries_v03;

alter table deliveries_v04
add column ball_id char(100) FIRST;

update deliveries_v04
set ball_id = concat(id,"-",inning,"-",`over`,"-",ball);

SET SQL_SAFE_UPDATES = 0;

select *
from deliveries_v04;

/* Compare the total count of rows and total count of distinct ball_id in
deliveries_v04*/
select count(*) as TotalRows, count(distinct(ball_id)) as DistinctBallID,
CASE 
When count(*)> count(distinct(ball_id)) Then "Greater"
When count(*)< count(distinct(ball_id)) Then "Lesser"
ELSE "Equal"
END AS Comparison
from deliveries_v04;

/* Create table deliveries_v05 with all columns of deliveries_v04 and an
additional column for row number partition over ball_id. (HINT :
row_number() over (partition by ball_id) as r_num)*/
create table deliveries_v05 as
select *, row_number() over (partition by ball_id) as r_num
from deliveries_v04;

select *
from deliveries_v05;

/* Use the r_num created in deliveries_v05 to identify instances where
ball_id is repeating. (HINT : select * from deliveries_v05 WHERE
r_num=2;)*/
select *
from deliveries_v05
where r_num=2;

/* Use subqueries to fetch data of all the ball_id which are repeating.
(HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID
from deliveries_v05 WHERE r_num=2);*/
select * 
from deliveries_v05 where ball_id in 
(select ball_id
from deliveries_v05 where r_num=2);