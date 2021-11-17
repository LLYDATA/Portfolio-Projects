SELECT *
From `first-discovery-311518.PortfolioProject.CovidDeaths`
Order by 3,4

-- SELECT  *
-- From `first-discovery-311518.PortfolioProject.CovidVaccinations`
-- ORDER BY 3,4


-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths,population
From `first-discovery-311518.PortfolioProject.CovidDeaths`
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Showing likehood of dying if you contact Covid in Canada
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From `first-discovery-311518.PortfolioProject.CovidDeaths`
Where location = 'Canada'
Order By 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From `first-discovery-311518.PortfolioProject.CovidDeaths`
--Where location = 'Canada'
Order By 1,2


-- Looking at Countries with Highest Infection Rates compared to Population

SELECT Location, Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/Population)*100 as PercentPopulationInfected
From `first-discovery-311518.PortfolioProject.CovidDeaths`
--Where location = 'Canada'
GROUP BY Location, Population
Order By PercentPopulationInfected desc


-- Showing Countries with Highrst Death Count per Population

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
From `first-discovery-311518.PortfolioProject.CovidDeaths`
--Where location = 'Canada'
Where continent is not NULL
GROUP BY Location
Order By TotalDeathCount desc



-- Let's break things down by continent


-- Showing continents with the highest death count per population

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
From `first-discovery-311518.PortfolioProject.CovidDeaths`
--Where location = 'Canada'
Where continent is not NULL
GROUP BY continent
Order By TotalDeathCount desc



-- Global Numbers

-- The Death Percentage by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From `first-discovery-311518.PortfolioProject.CovidDeaths`
--Where location = 'Canada'
Where continent is not NULL
Group By date
Order By 1,2


-- The Death Percentage
SELECT SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From `first-discovery-311518.PortfolioProject.CovidDeaths`
--Where location = 'Canada'
Where continent is not NULL
--Group By date
Order By 1,2


-- Looking at Total Population vs Vaccinatoins

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From `first-discovery-311518.PortfolioProject.CovidDeaths` dea
Join `first-discovery-311518.PortfolioProject.CovidVaccinations`vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
Order by 2,3


-- Use CTE

With PopvsVac
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From `first-discovery-311518.PortfolioProject.CovidDeaths` dea
Join `first-discovery-311518.PortfolioProject.CovidVaccinations`vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



 -- TEMP Table

DROP TABLE IF EXISTS PercentPopulationVanccinated

Create TEMP table PercentPopulationVanccinated
(
Continent STRING,
Location STRING,
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVanccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From `first-discovery-311518.PortfolioProject.CovidDeaths` dea
Join `first-discovery-311518.PortfolioProject.CovidVaccinations`vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL;
--Order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVanccinated;


-- Create View to store data for later visualizations

Create View first-discovery-311518.PortfolioProject.PercentPopulationVanccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinated
From `first-discovery-311518.PortfolioProject.CovidDeaths` dea
Join `first-discovery-311518.PortfolioProject.CovidVaccinations`vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL;
--Order by 2,3
