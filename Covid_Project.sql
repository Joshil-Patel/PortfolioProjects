
SELECT *
FROM CovidDeaths
order by 3,4




-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you get covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS DeathPercentage
	FROM CovidDeaths
	Where location like '%states%'
	order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as percentagepopulationinfected
	FROM CovidDeaths
	Group by location, population
	order by percentagepopulationinfected desc


-- Showing Countries with Highest Death Count per Population 

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
	FROM CovidDeaths
	WHERE continent is NOT NULL
	Group by location
	order by TotalDeathCount desc


-- Let's Break Things Down By Continent 

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
	FROM CovidDeaths
	WHERE continent is NULL
	Group by location
	order by TotalDeathCount desc


-- Showing Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
	FROM CovidDeaths
	WHERE continent is not NULL
	Group by continent
	order by TotalDeathCount desc


-- Global Numbers

SELECT  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(New_deaths)/SUM(New_cases)*100 as DeathPercentage
	FROM CovidDeaths
	Where new_cases > 0 -- To avoid devided by zero error
	-- Group By date
	order by 1,2


-- Looking at Total Populatin vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From CovidDeaths dea 
Join CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
-- ,(RollingPeopleVaccinated/population)*100
From CovidDeaths dea 
Join CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TAble

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From CovidDeaths dea 
Join CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From CovidDeaths dea 
Join CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3