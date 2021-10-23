/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY  1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'India'
	AND continent is not null 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'india'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India'
GROUP BY Location, Population
ORDER BY  PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--AND location like 'India'
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--AND location like 'India'
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as bigint)) AS total_deaths, SUM(CAST(new_deaths as bigint))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--AND location like 'India'
--GROUP BY  date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations))  OVER (
		PARTITION BY  dea.Location 
		ORDER BY  dea.location, dea.Date) AS CummulativePeopleVaccinated
--, (CummulativePeopleVaccinated)*100

FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		   AND dea.date = vac.date
WHERE dea.continent is not null 
	--AND dea.location = 'India'
ORDER BY 2,3


--OR
-- Shows Percentage of Population that has recieved  both doses of  Covid Vaccine

SELECT dea.date, dea.location, dea.continent, vac.people_fully_vaccinated,
(vac.people_fully_vaccinated/dea.population)*100 AS VaccinatedPopulationPercentage
FROM  PortfolioProject..CovidDeaths  dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.date = vac.date  AND  dea.location = vac.location

WHERE dea.continent is not null  
	  --AND dea.location = 'India'

ORDER BY 2,3,1 ASC



-- Use of  CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CummulativePeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations))  OVER (
		PARTITION BY  dea.Location 
		ORDER BY  dea.location, dea.Date) AS CummulativePeopleVaccinated
--, (CummulativePeopleVaccinated)*100

FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		   AND dea.date = vac.date
WHERE dea.continent is not null 
	--AND dea.location = 'India'
)


SELECT *
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE IF Exists #Vaccines

CREATE TABLE #Vaccines 

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_vaccinations numeric,
FullyVaccinatedPopulation FLOAT
)

INSERT INTO #Vaccines

SELECT dea.continent, dea.location,dea.date, vac.new_vaccinations, 
(vac.people_fully_vaccinated/dea.population)*100 AS FullyVaccinatedPopulation
FROM  PortfolioProject..CovidDeaths  dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.date = vac.date  AND  dea.location = vac.location

WHERE dea.continent is not null  
	--AND dea.location = 'india'
ORDER BY 2,3,1 asc
 
 SELECT * 
 FROM #Vaccines




-- Creating Views to store data 

CREATE VIEW PopulationVaccinatedPercentage  AS
SELECT dea.date, dea.location, dea.continent, vac.people_fully_vaccinated,
(vac.people_fully_vaccinated/dea.population)*100 AS VaccinatedPopulationPercentage
FROM  PortfolioProject..CovidDeaths  dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.date = vac.date  AND  dea.location = vac.location

WHERE dea.continent is not null  
--and dea.location = 'India'
