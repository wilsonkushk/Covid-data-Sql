SELECT *
FROM PORTFOLIO..coviddeath
--WHERE continent IS NOT NULL
ORDER BY 3,4;


--SELECT *
--FROM PORTFOLIO..covidvaccinations
--ORDER BY 3,4;

--Selecting data for use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PORTFOLIO..coviddeath
ORDER BY 1,2;

-- Total_cases vs Total_deaths
-- This shows the probability of death when one contracts covid 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentange 
FROM PORTFOLIO..coviddeath
WHERE location like '%Kenya%'
ORDER BY 1,2;


-- Total_cases vs Population
-- show what percentage population has covid
SELECT location, date, total_cases, population,  (total_cases/population)*100 AS covid_percentage
FROM PORTFOLIO..coviddeath
--WHERE location like '%Kenya%'
ORDER BY 1,2;


-- Countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) AS Highest_infection,  MAX((total_cases/population))*100 AS covid_percentage
FROM PORTFOLIO..coviddeath
GROUP BY location, population
ORDER BY covid_percentage DESC;


-- Countries with the highest death count to population
SELECT location, MAX(CAST(total_deaths AS INT)) AS Death_count 
FROM PORTFOLIO..coviddeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Death_count DESC;


-- continents with the highest_death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS Death_count 
FROM PORTFOLIO..coviddeath
WHERE continent IS NULL
GROUP BY location
ORDER BY Death_count DESC;

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Death_count 
FROM PORTFOLIO..coviddeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_count DESC;


-- GLOBAL NUMBERS 
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS death_percentange 
FROM PORTFOLIO..coviddeath
WHERE continent IS NOT NULL
ORDER BY 1,2;




---- covid_vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS people_vaccinated
FROM PORTFOLIO..coviddeath cd
JOIN PORTFOLIO..covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;



-- USE CTE

WITH populationvsvaccination(continent, location, date, population, new_vaccinations, people_vaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, 
cd.date) AS people_vaccinated
FROM PORTFOLIO..coviddeath cd
JOIN PORTFOLIO..covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *, (people_vaccinated/population)*100
FROM populationvsvaccination



-- TEMP TABLE
DROP TABLE IF EXISTS #percentpopvaccinated
CREATE TABLE #percentpopvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)

INSERT INTO #percentpopvaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, 
cd.date) AS people_vaccinated
FROM PORTFOLIO..coviddeath cd
JOIN PORTFOLIO..covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *, (people_vaccinated/population)*100
FROM #percentpopvaccinated




--CREATING VIEWS TO STORE DATA
CREATE VIEW percentpopvaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, 
cd.date) AS people_vaccinated
FROM PORTFOLIO..coviddeath cd
JOIN PORTFOLIO..covidvaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL