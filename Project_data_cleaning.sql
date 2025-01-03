-- Data Cleaning

SELECT *
FROM layoffs;

-- Remove Duplicates <Done>
-- Standardize the Data <Done>
-- Null values or Blank values
-- Remove Any columns

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT INTO
layoffs_staging
SELECT *
FROM layoffs
;

-- Creating a table to delete duplicates which includes row_num column
CREATE TABLE layoffs_staging2
-- How exactly does this row_number() over() work?
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
    
WITH duplicates_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
	`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging
WHERE company LIKE 'wildlife studios'
;

SELECT *
FROM layoffs_staging2
;

DELETE FROM
layoffs_staging2
WHERE row_num > 1;

-- Standardizing data

SELECT company, TRIM(company)
FROM layoffs_staging2
;

-- removing whitespaces in company column
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%'
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%'
;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1
;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'united states%'
ORDER BY 1;

UPDATE layoffs_staging2
-- to remove the trailing '.' dot from united states:
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'united states%'
;

-- Lookup date formating in sql (Search) 
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Dealing with null and blank values:
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;

-- Trying to populate the missing values
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'
;

SELECT *
FROM layoffs_staging2 AS t1
INNER JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL
;

-- My attempt to update it one by one
UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE company = 'Airbnb'
;

UPDATE layoffs_staging2 AS t1
INNER JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;

-- The previous query didn't work as expected:
-- Blanks could have been the issue
-- Yes it was the issue
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = ''
;
-- We decided to delete the rows where columns total_laid_off
-- & percentage_laid_off are nulls.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;
-- Is there blank values other than nulls?
SELECT *
FROM layoffs_staging2
WHERE total_laid_off = ''
AND percentage_laid_off = ''
;
-- No there is not.

-- Getting rid off row_num column, it has finished its duty. farewell friend.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;
-- This is the final data, cleaned data.
-- Project 1 is done! 