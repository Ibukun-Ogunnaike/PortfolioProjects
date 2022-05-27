Select *
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations;
--order 3,4
--Select the data we are using

Select location, date,total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
order by 1,2;

--Looking at total cases VS total deaths
---Shows the likehood of dying if you contract Covid in your country
Select location, date,total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
AND continent IS NOT NULL
order by 1,2;

--Looking at the total cases VS the population
--Shows what percentage of population has got Covid
Select location, date,population, total_cases, (total_cases/ population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
order by 1,2;

--Looking at Countries with highest infection rate compared to Population

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/ population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Group by location,population
Order by PercentagePopulationInfected desc

--Looking at Countries with the highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
where continent IS NOT NULL
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
where continent IS not NULL
Group by continent
Order by TotalDeathCount desc

--showing continents with the highest death count per population
 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
where continent IS not NULL
Group by continent
Order by TotalDeathCount desc



---GLOBAL NUMBERS


Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int ))as total_death, SUM(cast(new_deaths as int))/Sum(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2;

Select date,SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2;

--Total sum of deaths and percentage in the world

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
WHERE continent IS NOT NULL
--group by date
order by 1,2;



--Looking at Total Population VS Vaccinatination


Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date

 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --MAKING A ROLLING SUM OF NEW VACCINATION

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int))OVER  (Partition BY dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,SUM(Convert( int,vac.new_vaccinations))OVER (Partition by dea.location order by dea.location,dea.date) as RollingSumPeopleVaccinated
 ---RollingSumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --USE CTE

 WITH POPVCVAC( Continent,Location,Date,Population,New_vaccinations,RollingSumPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,SUM(Convert( int,vac.new_vaccinations))OVER (Partition by dea.location order by dea.location,dea.date) as RollingSumPeopleVaccinated
 ---RollingSumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --ORDER BY 2,3
 )
Select * ,RollingSumPeopleVaccinated
From POPVCVAC


--CREATE TEMP TABLE


drop table if exists  #PercentPopulationvaccinated
GO
CREATE TABLE #PercentPopulationvaccinated
(
continent nvarchar(225),
location varchar(225),
Date datetime,
population numeric,
New_vaccination numeric,
RollingSumPeopleVaccinated numeric
)


Insert into #PercentPopulationvaccinated
 SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,SUM(Convert( int,vac.new_vaccinations))OVER (Partition by dea.location order by dea.location,dea.date) as RollingSumPeopleVaccinated
 ---RollingSumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
 --ORDER BY 2,3

Select * ,(RollingSumPeopleVaccinated) *100
From #PercentPopulationvaccinated


--Creating a view to store Data for visualization later

Create view PercentPopulationvaccinated as

 SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,SUM(Convert( int,vac.new_vaccinations))OVER (Partition by dea.location order by dea.location,dea.date) as RollingSumPeopleVaccinated
 ---RollingSumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
 --ORDER BY 2,3

 SELECT *
 FROM PercentPopulationvaccinated