SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2


SELECT DISTINCT location FROM CovidDeaths ORDER BY 1

-- total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, population, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as deathRate
FROM CovidDeaths
WHERE location like '%States%'
order by 1,2

-- Countries with Highest infection rate compared to it's population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Round(MAX((total_cases/population)*100),2) as InfectedPopulation
FROM CovidDeaths
GROUP BY location, population
ORDER BY InfectedPopulation desc


-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc

-- By Continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null AND location not like '%World%, %European%, %International%' 
GROUP BY location
ORDER BY TotalDeathCount desc


-- OR we can do...(but it's a little inaccurate number wise but accurate in selecting the 7 continents)
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers
SELECT date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as totaldeathspercent --, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as deathRate
FROM CovidDeaths
WHERE continent is not null
Group By date
Order by 1,2


-- Death numbers without dates
SELECT SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as totaldeathspercent --, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as deathRate
FROM CovidDeaths
WHERE continent is not null
Order by 1,2



-- Total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rollingVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3


-- Using CTE
With PopvsVac(continect, location, date, population, new_vaccinations, rollingVaccinations)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rollingVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (rollingVaccinations/population)*100 as peopleVacc
FROM PopvsVac


-- Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccinations numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rollingVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date

SELECT *, (Rolling_vaccinations/population)*100 as peopleVacc
FROM #PercentPopulationVaccinated


-- Creating view to store data for visualizations
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as rollingVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null

Select *
From PercentPopulationVaccinated