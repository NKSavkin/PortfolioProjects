-- Select data that I going to be use
--ALTER TABLE PortfolioProject..CovidDeaths ALTER COLUMN population real

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by location, date

-- Lookin Total Cases vs Total Deaths
-- Shows likelyhood of dieing if you contract in Belarus

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Belarus'
order by location, date

-- Loocking at Total Cases vs Population
-- Shows what percentage of population got Covid in Belarus

select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfection
from PortfolioProject..CovidDeaths
where location like 'Belarus'
order by location, date

-- Lookink countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfection,  Max((total_cases/population))*100 as PercentPopulationInfection
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfection desc

-- Show countries with hieghest death count per population

select location, population, MAX(total_deaths) as HighestDeath,  Max((total_deaths/population))*100 as PercentPopulationDeath
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationDeath desc

--showing continents with highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1, 2

--Looking total vaccination vs total population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination, (RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (RollingPeopleVaccination/population)*100 as PercentPeopleVaccinationOfPopulation
FROM PopvsVac

--Creating view to store data for later vizualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
