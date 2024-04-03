
-- Select Data that we are going to be using

SELECT location
	 , date
	 , total_cases
	 , new_cases
	 , total_deaths
	 , population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1,2;


-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country

SELECT location
	 , date
	 , total_cases
	 , total_deaths
	 , (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location LIKE '%canada%'
ORDER BY 1,2;


-- Looking at Total Cases vs. Population
-- Shows what percentage of population got COVID

SELECT location
	 , date
	 , population
	 , total_cases
	 , (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location
	 , population
	 , MAX(CAST(total_cases AS FLOAT)) AS HighestInfectionCount
	 ,(MAX(CAST(total_cases AS FLOAT)) / population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Showing countries with the Highest Death Count per Population

SELECT location
	 , MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Breaking these down by continent

SELECT location
	 , MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT date
	 , SUM(new_cases) AS total_cases
	 , SUM(new_deaths) AS total_deaths
	 , SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


SELECT SUM(new_cases) AS total_cases
	 , SUM(new_deaths) AS total_deaths
	 , SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Looking at Total Population vs. Vaccinations

SELECT dea.continent
	 , dea.location
	 , dea.date 
	 , population
	 , vac.new_vaccinations
	 , SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	   dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
	
	
-- USE CTE

WITH PopvsVac AS (
SELECT dea.continent
	 , dea.location
	 , dea.date 
	 , population
	 , vac.new_vaccinations
	 , SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	   dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac
;


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent
	 , dea.location
	 , dea.date 
	 , population
	 , vac.new_vaccinations
	 , SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	   dea.date) AS RollingPeopleVaccinated
  -- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent
	 , dea.location
	 , dea.date 
	 , population
	 , vac.new_vaccinations
	 , SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	   dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated;