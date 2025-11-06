-- 3. Now, let’s take a closer look at the campaign table. Is it in normal form? Why not? 
--(Hint: Think about if a contributor makes several contributions either to one or to multiple candidates, what fields would be repeated for each contribution.)

The campaign table is not in 3NF because it repeats contributor and candidate details for every contribution. 
This redundancy causes update, insert, and delete anomalies due to partial and transitive dependencies, 
meaning the table mixes multiple entities and isn’t normalized.

--4. Normalize by splitting into 3 tables: candidate, contributor and contribution. The primary key of candidate is: cand_id. 
--	 The primary key of contributor would be: contbr_id, defined as SERIAL. 
--	 The primary key of contribution would be: contb_id, defined as SERIAL. 
--	 The contribution table should have foreign keys for cand_id and contbr_id.

This is done through tasks 5-7.

--5. Write and execute CREATE TABLE statements for the 3 normalized tables.

CREATE TABLE IF NOT EXISTS candidate (
  cand_id text PRIMARY KEY,
  cand_nm text
);

CREATE TABLE IF NOT EXISTS contributor (
  contbr_id SERIAL PRIMARY KEY,
  contbr_nm text,
  contbr_city text,
  contbr_st text,
  contbr_zip text,
  contbr_employer text,
  contbr_occupation text
);

CREATE TABLE IF NOT EXISTS contribution (
  contb_id SERIAL PRIMARY KEY,
  cand_id text REFERENCES candidate(cand_id),
  contbr_id integer REFERENCES contributor(contbr_id),
  contb_receipt_amt numeric(12,2),
  contb_receipt_dt date,
  receipt_desc text,
  memo_cd text,
  memo_text text,
  form_tp text,
  file_num text,
  tran_id text,
  election_tp text,
  cmte_id text
);


--6. Create an index on contributor name:
--CREATE INDEX contributor_nm ON contributor(contbr_nm);

CREATE INDEX IF NOT EXISTS contributor_nm ON contributor(contbr_nm);


--7. Steps a-c detail how to write three insert statements using INSERT INTO ... SELECT to select data from the campaign table and insert it into the normalized tables.


--a. For example, for the candidate table you would use:
--INSERT INTO candidate (cand_id, cand_nm)
--SELECT DISTINCT cand_id, cand_nm
--FROM campaign
--WHERE cand_id IS NOT NULL;

INSERT INTO candidate (cand_id, cand_nm)
SELECT DISTINCT cand_id, cand_nm
FROM campaign
WHERE cand_id IS NOT NULL;


--b. Since the contributor table's contbr_id column is defined as a SERIAL primary key and isn't present in the campaign data, when you insert rows without specifying a value for contbr_id, PostgreSQL automatically generates a unique identifier for each row using the column's default sequence.
--Important: Make sure each contributor only shows up once in this table.

INSERT INTO contributor (
  contbr_nm,
  contbr_city,
  contbr_st,
  contbr_zip,
  contbr_employer,
  contbr_occupation
)
SELECT DISTINCT
  contbr_nm,
  contbr_city,
  contbr_st,
  contbr_zip,
  contbr_employer,
  contbr_occupation
FROM campaign
WHERE contbr_nm IS NOT NULL;


--c. For the contribution table, to get the value of contbr_id field to insert, use a join between campaign and constributor. You will need to match on columns contbr_nm, contbr_city, contbr_st, contbr_zip, contbr_employer, and contbr_occupation to make sure you are matching to the correct contributor.
--You should have ~21 rows in the candidate table, ~61,043 rows in the contributor table, and ~178,865 rows in the contribution table.
--Include your 3 insert statements with your lab submission.

INSERT INTO contribution (
  cand_id,
  contbr_id,
  contb_receipt_amt,
  contb_receipt_dt,
  receipt_desc,
  memo_cd,
  memo_text,
  form_tp,
  file_num,
  tran_id,
  election_tp,
  cmte_id
)
SELECT
  c.cand_id,
  cb.contbr_id,
  c.contb_receipt_amt,
  to_date(c.contb_receipt_dt, 'DD-MON-YY'),
  c.receipt_desc,
  c.memo_cd,
  c.memo_text,
  c.form_tp,
  c.file_num,
  c.tran_id,
  c.election_tp,
  c.cmte_id
FROM campaign c
JOIN contributor cb
  ON cb.contbr_nm = c.contbr_nm
 AND cb.contbr_city = c.contbr_city
 AND cb.contbr_st = c.contbr_st
 AND cb.contbr_zip = c.contbr_zip
 AND cb.contbr_employer = c.contbr_employer
 AND cb.contbr_occupation = c.contbr_occupation;


--8. Create a view vcampaign that joins the 3 tables candidate, contributor and contribution and renames the columns as cand_name, contbr_id, contbr_name, occupation, city, zip, amount, date. 
--The view's zip column should only have the first 5 digits of the contbr_zip field. 
--(Hint: use LEFT with second argument of 5 to truncate the zip column this way.)

CREATE OR REPLACE VIEW vcampaign AS
SELECT
  cand.cand_nm AS cand_name,
  cont.contbr_id,
  cont.contbr_nm AS contbr_name,
  cont.contbr_occupation AS occupation,
  cont.contbr_city AS city,
  LEFT(cont.contbr_zip::text, 5) AS zip,
  contrib.contb_receipt_amt AS amount,
  contrib.contb_receipt_dt AS date
FROM contribution contrib
JOIN candidate cand ON cand.cand_id = contrib.cand_id
JOIN contributor cont ON cont.contbr_id = contrib.contbr_id;



--9. Using the view, perform a COUNT(*) to verify that there are ~178,865  rows.

SELECT COUNT(*) FROM vcampaign;


--10. Write a query to find the top ten occupations of contributors as well as the number of contributions and total dollar amount (per occupation). Order from highest to lowest.

SELECT
  occupation,
  COUNT(*) AS contributions,
  SUM(amount) AS total_amount
FROM vcampaign
GROUP BY occupation
ORDER BY total_amount DESC
LIMIT 10;


--11. Write a query which lists all contributors who made a contribution over $10,000. Provide the candidate name, contributor name, amount, and date. Order from highest to lowest.

SELECT
  cand_name,
  contbr_name,
  amount,
  date
FROM vcampaign
WHERE amount > 10000
ORDER BY amount DESC;


--12. How many unique donors per candidate?

SELECT
  cand_name,
  COUNT(DISTINCT contbr_id) AS unique_donors
FROM vcampaign
GROUP BY cand_name
ORDER BY unique_donors DESC;


 --13. What is the average gift amount per candidate?

SELECT
  cand_name,
  AVG(amount) AS average_gift
FROM vcampaign
GROUP BY cand_name
ORDER BY average_gift DESC;


--14. Are there any negative contributions? What might this mean?

SELECT *
FROM vcampaign
WHERE amount < 0
ORDER BY amount ASC;
