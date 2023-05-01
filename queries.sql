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

SELECT
    SUM(confirmed) as total_confirmed, 
    SUM(deaths) as total_deaths, 
    SUM(recovered) as total_recovered
FROM covid_19_data;


SELECT
	EXTRACT('year' FROM "observationDate") as year,
	SUM(confirmed) as total_confirmed, 
    SUM(deaths) as total_deaths, 
    SUM(recovered) as total_recovered
FROM covid_19_data
WHERE EXTRACT('month' FROM "observationDate") BETWEEN 1 AND 3
GROUP BY year;


SELECT
	country,
	SUM(confirmed) as total_confirmed, 
    SUM(deaths) as total_deaths, 
    SUM(recovered) as total_recovered
FROM covid_19_data
GROUP BY country
ORDER BY country;


SELECT round(((total_deaths_2020 - total_deaths_2019) / total_deaths_2019 ) * 100, 2) AS "percentage_increase(%)"
FROM (
	SELECT 
	    SUM(CASE WHEN EXTRACT('year' FROM "observationDate") = 2019 THEN deaths ELSE 0 END) AS total_deaths_2019,
  	    SUM(CASE WHEN EXTRACT('year' FROM "observationDate") = 2020 THEN deaths ELSE 0 END) AS total_deaths_2020
  	FROM covid_19_data
) subq;


SELECT
	country,
	SUM(confirmed) as totalConfirmed
FROM covid_19_data
GROUP BY country
ORDER BY totalConfirmed DESC
LIMIT 5;

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