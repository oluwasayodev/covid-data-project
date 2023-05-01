DROP DATABASE IF EXISTS covid19_db;

CREATE DATABASE covid19_db;

\c covid19_db;

CREATE TABLE IF NOT EXISTS covid_19_data (
    serialNumber INT,
    observationDate DATE,
    state VARCHAR(255),
    country VARCHAR(255),
    lastUpdated TIMESTAMP,
    confirmed INT,
    deaths INT,
    recovered INT
);

-- Question 1
-- Retrieve the total confirmed, death, and recovered cases.
SELECT
    SUM(confirmed) as total_confirmed, 
    SUM(deaths) as total_deaths, 
    SUM(recovered) as total_recovered
FROM covid_19_data;


-- Question 2
-- Retrieve the total confirmed, deaths and recovered cases for the first quarter
-- of each year of observation.
SELECT
	EXTRACT('year' FROM "observationDate") as year,
	SUM(confirmed) as total_confirmed, 
    SUM(deaths) as total_deaths, 
    SUM(recovered) as total_recovered
FROM covid_19_data
WHERE EXTRACT('month' FROM "observationDate") BETWEEN 1 AND 3
GROUP BY year;


-- Question 3
-- Retrieve a summary of all the records. This should include the following
-- information for each country:
-- ● The total number of confirmed cases
-- ● The total number of deaths
-- ● The total number of recoveries
SELECT
	country,
	SUM(confirmed) as total_confirmed, 
    SUM(deaths) as total_deaths, 
    SUM(recovered) as total_recovered
FROM covid_19_data
GROUP BY country
ORDER BY country;

-- Question 4
-- Retrieve the percentage increase in the number of death cases from 2019 to
-- 2020.
SELECT round(((total_deaths_2020 - total_deaths_2019) / total_deaths_2019 ) * 100, 2) AS "percentage_increase(%)"
FROM (
	SELECT 
	    SUM(CASE WHEN EXTRACT('year' FROM "observationDate") = 2019 THEN deaths ELSE 0 END) AS total_deaths_2019,
  	    SUM(CASE WHEN EXTRACT('year' FROM "observationDate") = 2020 THEN deaths ELSE 0 END) AS total_deaths_2020
  	FROM covid_19_data
) subq;


-- Question 5
-- Retrieve information for the top 5 countries with the highest confirmed cases.
SELECT
	country,
	SUM(confirmed) as totalConfirmed
FROM covid_19_data
GROUP BY country
ORDER BY totalConfirmed DESC
LIMIT 5;


-- Question 6
-- Compute the total number of drop (decrease) or increase in the confirmed
-- cases from month to month in the 2 years of observation.
SELECT 
	year,
    month, 
    total_confirmed, 
    total_confirmed - LAG(total_confirmed, 1) OVER () as total_confirmed_month_change FROM (
    SELECT 
        EXTRACT('year' FROM "observationDate") as year, 
        EXTRACT('month' FROM "observationDate") as month, 
        SUM(confirmed) as total_confirmed
    FROM covid_19_data
    GROUP BY year, month
    ORDER BY year, month
) subq;