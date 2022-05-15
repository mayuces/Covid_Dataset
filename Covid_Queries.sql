SELECT  Location, date, total_cases, new_cases, total_deaths, population
FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths`
ORDER BY 1,2;

----Looking at Total Cases vs Total Deaths

SELECT  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths`
--WHERE location LIKE '%Turkey'
ORDER BY 1,2;

----Looking at Total Cases vs Population(What percantage of the population has covid)


SELECT  Location, date, total_cases,population, total_deaths, (total_cases/population)*100 AS population_percentage
FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths`
--WHERE location LIKE '%Turkey'
ORDER BY 1,2;

-- Looking at Countries with Highest Covid Rate compared to Population

SELECT  Location, population, MAX(total_cases) AS highest_case_count, MAX((total_cases/population))*100 AS population_percentage_covid
FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths`
GROUP BY location, population
ORDER BY population_percentage_covid DESC;

--- Looking at Countries with Highest Death Count

SELECT  Location, MAX(total_deaths) AS total_death_count
FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths`
WHERE continent is not NULL
GROUP BY location
ORDER BY total_death_count DESC;

--- Looking at Continents with Highest Death Count

SELECT  continent, MAX(total_deaths) AS total_death_count
FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths`
WHERE continent is not NULL
GROUP BY continent
ORDER BY total_death_count DESC;

----- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,  (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths`
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2;

--- Looking at Total Population vs Vaccinations

WITH PopvsVac --(continent, location , date , population, new_vaccinations, total_vaccinations )
AS 
( 
  SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.date) AS total_vaccinations
  FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths` AS death
  JOIN `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_vaccinations` AS vac
    ON death.location = vac.location
    AND death.date = vac.date
  WHERE death.continent is not NULL AND vac.new_vaccinations is not NULL
)
SELECT *, (total_vaccinations/population)*100 AS vaccinaitons_percentage
FROM PopvsVac;

--- Temp Table

DROP TABLE IF EXISTS `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.PercentPopulationVaccinated`;
CREATE TABLE `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.PercentPopulationVaccinated`
(
  continent STRING,
  location STRING,
  date DATETIME,
  population NUMERIC,
  new_vaccinations NUMERIC,
  total_vaccinations NUMERIC
);

INSERT INTO `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.PercentPopulationVaccinated`
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.date) AS total_vaccinations
  FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths` AS death
  JOIN `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_vaccinations` AS vac
    ON death.location = vac.location
    AND death.date = vac.date
  WHERE death.continent is not NULL AND vac.new_vaccinations is not NULL;


SELECT *, (total_vaccinations/population)*100 AS vaccinaitons_percentage
FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.PercentPopulationVaccinated`;

----- Creating view to store data for later visualitons

CREATE VIEW `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.PercentPopulationVaccinatedView` AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.date) AS total_vaccinations
  FROM `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_deaths` AS death
  JOIN `hands-on-activity-sql-348004.covid_deaths_SQL_05152022.covid_vaccinations` AS vac
    ON death.location = vac.location
    AND death.date = vac.date
  WHERE death.continent is not NULL AND vac.new_vaccinations is not NULL;

