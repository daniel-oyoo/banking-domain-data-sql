/*
wheres
*/

/*
return a scalar value
*/

SELECT  branch_code bd
FROM (
    SELECT * FROM branches 
    WHERE county = LOWER('NAkuru')
);