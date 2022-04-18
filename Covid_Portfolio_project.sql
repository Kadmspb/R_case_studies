SELECT *
FROM PortfolioProject..COVIDdeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..COVIDvaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVIDdeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelyhood of dying from Covid in your contry (Plug in your country in WHERE part)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDdeaths
WHERE location='United States'
and continent is not null
order by 1,2

-- Looking at Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Infection Rate
FROM PortfolioProject..COVIDdeaths
WHERE location='Russia'
and continent is not null
order by 1,2

-- Looking at countries with Highest Infection Rate in population

SELECT Location, population, MAX(total_cases) as MaxInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercent
FROM PortfolioProject..COVIDdeaths
WHERE continent is not null
group by location, population
order by PopulationInfectedPercent DESC

-- Showing countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDdeaths
WHERE continent is not null
group by location
order by TotalDeathCount DESC

-- Breaking things down by continent
-- Continents with highest death count


SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDdeaths
WHERE continent is not null
group by continent
order by TotalDeathCount DESC

--It looks like data from above query is showing sus numbers, let's try another approach

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDdeaths
WHERE continent is null
group by location
--Grouping by location gives us correct numbers for continents
order by TotalDeathCount DESC

--Global Numbers

--Data by day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDdeaths
WHERE continent is not null
Group by date
order by 1,2


-- Total
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDdeaths
WHERE continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccinations
-- Use CTE

With PopvsVax (Continents, Location, Date, Population, new_vaccinations,  RollingVaxCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(Bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date)
as RollingVaxCount
--, (RollingVaxCount/population)*100
FROM PortfolioProject..COVIDdeaths dea
JOIN PortfolioProject..COVIDvaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaxCount/Population)*100 as VaccinationRate
FROM PopvsVax


-- Temp Table

DROP table if exists #PercentPopsVaxed
Create table #PercentPopsVaxed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaxCount numeric
)

Insert into #PercentPopsVaxed
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(Bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date)
as RollingVaxCount
--, (RollingVaxCount/population)*100
FROM PortfolioProject..COVIDdeaths dea
JOIN PortfolioProject..COVIDvaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (RollingVaxCount/Population)*100
FROM #PercentPopsVaxed

-- Creating View to store data for later visualizations

Create View TotalDeaths as
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDdeaths
WHERE continent is null
group by location

Create View PercentPopsVaxed as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(Bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date)
as RollingVaxCount
--, (RollingVaxCount/population)*100
FROM PortfolioProject..COVIDdeaths dea
JOIN PortfolioProject..COVIDvaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
FROM PercentPopsVaxed


