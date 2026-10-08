SELECT * FROM branches b
INNER JOIN customers c
ON  b.county = c.county
LIMIT 10;

/*
inner join takes all rows where both values for counties is same
resulting able is a merge of the two
it can be querrird as one
*/

SELECT * FROM branches b
LEFT JOIN customers c
ON  b.county = c.county
LIMIT 10;

/*
all on left ony matching on right
*/

SELECT * FROM branches b
RIGHT JOIN customers c
ON  b.county = c.county
LIMIT 10;


/*
all on right ony matching on left
*/
SELECT * FROM branches b
JOIN customers c
LIMIT 10;



/*
the two tables are merged
doesnt need on becuase it merges everything
*/



SELECT county c FROM
(
SELECT * FROM branches b
JOIN customers c
LIMIT 10
) AS  pre
WHERE pre.last_name = 'Oyoo';

/*
duplicate country--how
*/


SELECT county c FROM
(
SELECT * FROM branches b
UNION customers c
LIMIT 10
) AS  pre
WHERE pre.last_name = 'Oyoo';