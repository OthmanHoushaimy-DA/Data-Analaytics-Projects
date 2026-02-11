#MY DATA CLEANING PROJECT:

# 1.REMOVE DUPLICATES
# 2.STANDARIZE THE DATA
# 3.NULL VALUES AND BLANK
# 4.REMOVE ANY COLUMNS THAT ARE NOT NECESSARY


#NOTE:YOU SHOULD CREATE A TABLE TO WORK ON DONT WORK ON THE RAW DATA
CREATE TABLE layoffs_staging 
like layoffs;

insert layoffs_staging
select *
from llayoffs_stagingayoffs;


#STEP:1-REMOVING DUPLICATES:

SELECT *
FROM layoffs_staging;
######################
select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

WITH duplicate_cte AS
(
select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging
)
select * 
from duplicate_cte
where row_num > 1;

##################################
#NOW WE ARE CREATING A TABLE SINCE DELETE DOESNT WORK WITH CTES

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#NOW WE ARE GONNA INSERT INTO THE TABLE WE CREATED BY COPYING THE PARTIOTION QUERY:

INSERT INTO layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as row_num
from layoffs_staging;


select * 
from layoffs_staging2
where row_num > 1;

SET SQL_SAFE_UPDATES = 0;

delete 
from layoffs_staging2
where row_num > 1;
####so we removed duoplicates 

#STEP2- STANDARDIZING DATA:
#removing spaces:
UPDATE layoffs_staging2
set company  = trim(company);

select distinct industry #selects the industries#
from layoffs_staging2;            #NOTE:WE HAVE CRYPTO,CRYPTO CURRENCY IN INDUTRY COLUMN

#TO SEE THEM WE:

SELECT *
FROM layoffs_staging2
where industry like 'crypto%';

#TO CHANGE THEM:
UPDATE layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

##NOW AFTER LOOKING AT COMPANY AND INDUSTRY LETS SEE LOCATION:

select distinct country
from layoffs_staging2
order by 1 ;    #1 is the column number since we are only selecting location then its location and its ordered alphabetically

select country
from layoffs_staging2
where country like 'United States%' #by running this code we know what it should so we then fix it 
;
############

update layoffs_staging2
set country = trim(trailing '.' from country); #here we removed the '.' from the end

#########################################################
#the date column is text we should change it to date
select `date`
from layoffs_staging2;

select `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') ###### thats how text is transformed into date
from layoffs_staging2;

update layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); 
#now the dates are in date format but text still is the column format

#now to change the format 'text' to 'date':

ALTER table layoffs_staging2
MODIFY column `date` DATE;

#############################################################


#STEP:3- NULL VALUES AND BLANKS:

select distinct industry
from layoffs_staging2;   #we see that there are nulls and blanks 

#So

select * 
from layoffs_staging2 
where industry is null
or industry = '';                  
									 #here we see where nulls and blanks and how we can fix
									 #we have compmay airbnb and blank industry we will search
									 #for another bnb and see its industry if its there to fill it


select *
from layoffs_staging2
where company = 'airbnb';   #so there is another bnb and we found out that industry missing is travel 

#first update blank to zeroes to avoid connfusion:

update layoffs_staging2
set industry = null
where industry = '';

#now we use the join function:
#this query helps us to use it with the update:

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2 
	 ON t1.company = t2.company
where t1.industry is null
and t2.industry is not null;  

update layoffs_staging2 t1
join layoffs_staging2 t2
		ON t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

#now lets check:
select *
from layoffs_staging2
where company LIKE 'Bally%'; #we see the industry is now filled with the correct word.
#this one we don't have any other row like bally in company so we dont know how to put industry

##############
#NOW WE WANT TO DELETE THE ROWS WITH TOTAL LAID OFF AND PERCENTAGE LAID OFF WHERE THEY ARE NULL, SINCE THEY AFFECT OUR ANALYSIS

DELETE 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

#STEP:4- REMOVING COLUMNS THAT ARE NOT NECESSARY:
#WE ADDED A COLUMN 'ROW_NUM' WHEN WE WERE REMOVING DUPLICATES WE SHOULD REMOVE IT NOW:

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2

## SO THATS THE END ! WE CLEANED OUR DATASET ! ##









                                     
                                     
				



 














































