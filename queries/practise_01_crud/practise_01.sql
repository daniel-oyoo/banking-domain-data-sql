/*
Basic CRUD
view/read select attributes from relation where condition clause
create/insert  insert into relation() values() 
update/change  update relation  r insert set oldvalue to new value 
delete/remove  delete attribute from relation r where condition



*/
/*USE bank_practice;
view slect any or all attributes from a relation or relations 
where a condition is met the condion is options
*/

/*branches relation*/
/*SELECT * FROM branches;

SELECT branch_code code , branch_name name 
FROM branches
ORDER BY name ASC;

*/

/*SELECT COUNT(*) FROM branches;*/


/*
Where filter uses any condition




SELECT * FROM branches 
WHERE is_active = TRUE;




SELECT * FROM branches 
WHERE is_active > '2026-05-08';


order/limit order is sorting ascending or descending
limit is how many to show in the final results



SELECT * FROM branches 
WHERE is_active <= '2026-05-08'
ORDER BY county DESC LIMIT 4; 


/*only four */



*/

/*
Insert/update/delete
INSERT INTO branches() VALUES();
UPDATE branches SET is_active = FALSE 
WHERE branch_id = '';
DELETE FROM branches WHERE branch_id = '';
*/