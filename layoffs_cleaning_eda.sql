SELECT * FROM world_layoffs;
SELECT COUNT(*) FROM world_layoffs;
-- Good ,now I know there are 2361 rows of data to be worked on.

-- Next step is to clean the dataset.
-- Before even thinking of cleaning, we cannot work on the original file, so we have to create a staged file or rather duplicate the file, so that the original file is not affected
CREATE TABLE world_layoffs_staging LIKE world_layoffs;
-- This creates a table with the same schema as world_layoffs but not the same data
-- Now, we will insert into that data the data that is in the original file.
INSERT INTO world_layoffs_staging
SELECT * FROM world_layoffs;

-- Now, we will check if all the data has been inserted
select * from world_layoffs_staging;
-- Correct, it has been inserted completely

-- Now it is time to deal with duplicate rows
-- Steps in Cleaning a Dataset: Remove duplicates, Standardize columns, Remove Null Values

-- To make our first step of removing duplicates, we must identify our duplicates and since there is no unique identifier, we must make use of artificial ones.
-- In this effect, we will create a new row called row-num that will show duplicates using the ROWNUMBER function, OVER & PARTITION BY attibute.
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging;
    
-- Now, we will make use of artificial query table(cte) to find those rows that are duplicates.
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM world_layoffs_staging
)
SELECT COUNT(*)
FROM duplicate_cte
WHERE row_num > 1;

SELECT distinct(location) FROM world_layoffs_staging_2 order by 1;

SELECT * FROM world_layoffs_staging_2 WHERE company  = 'Uber';

-- change the nanming convention of this city to Dusseldorf
UPDATE world_layoffs_staging_2
SET location = 'Dusseldorf'
WHERE location  = 'DÃ¼sseldorf';

-- change the naming of this city to the correct spellign florianopolis
UPDATE world_layoffs_staging_2
SET location = 'Florianopolis'
WHERE location LIKE '%florian%';

-- change the naming of this city to the correct spellign florianopolis
UPDATE world_layoffs_staging_2
SET location = 'Frederiction'
WHERE location = 'Ferdericton';

-- change the naming of this city to the correct spellign florianopolis
UPDATE world_layoffs_staging_2
SET location = 'Malmo'
WHERE location LIKE 'Malm%';

SELECT distinct(location) FROM world_layoffs_staging_2 order by 1;

-- check for the rows that are redundant in the dataset
SELECT *
FROM world_layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- delete the rows that are redundant in the dataset
DELETE FROM world_layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

 -- check how many rows remain
 SELECT * FROM world_layoffs_staging_2;
 
 -- check for redundant columns
 DESCRIBE world_layoffs_staging_2;
 
-- Now, data cleaning is complete. I have: 
--  1. Removed Duplicates
--  2. Standardized data
--  3. Handled Nulls and blanks
--  4. Removed unnecessary columns

-- Next up, EDA (Exploratory Data Analysis)
-- Let's view the scale of our data first
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs_staging_2;

-- Some companies had a percentage_laid_off of 1; meaning some of them actually went under.
SELECT *
FROM world_layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- to see if the stage is dominated by a group
SELECT stage, COUNT(*) AS num_companies
FROM world_layoffs_staging_2
WHERE percentage_laid_off = 1
GROUP BY stage
ORDER BY num_companies DESC;

-- To see the total laid off by company; the highest 10 companies that laid off staff and their numbers
SELECT company, SUM(total_laid_off) AS total
FROM world_layoffs_staging_2
GROUP BY company
ORDER BY total DESC
LIMIT 10;

-- now to chack on the ranking by industry
SELECT industry, SUM(total_laid_off) AS total
FROM world_layoffs_staging_2
GROUP BY industry
ORDER BY total DESC;

-- now, let us look at layoffs, year by year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total
FROM world_layoffs_staging_2
GROUP BY YEAR(date)
ORDER BY year ASC;

-- to see when the data actually started and ended
SELECT MIN(date), MAX(date)
FROM world_layoffs_staging_2;

-- now we aregoing to analsye the biggest companies that laid off and in what ear they ladi off
SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total
FROM world_layoffs_staging_2
GROUP BY company, YEAR(date)
ORDER BY total DESC
LIMIT 10;

WITH Rolling_total AS
(
SELECT SUBSTRING(date,1,7) AS month, SUM(total_laid_off) AS total_off
FROM world_layoffs_staging_2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY month
ORDER BY month ASC
)
SELECT month, total_off, SUM(total_off) OVER(ORDER BY month) AS rolling_total
FROM Rolling_Total;

WITH Company_Year AS
(
SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs_staging_2
GROUP BY company, YEAR(date)
),
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5
ORDER BY years ASC, ranking ASC;

select * from world_layoffs_staging_2 where company = 'dell';
