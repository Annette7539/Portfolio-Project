select *
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that I am going to be using


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (Total_Deaths/Total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

select location, date, population, total_cases, (Total_cases/population)*100 as PrecentPopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Pupulation

select location, population, max (total_cases) as HighestInfectionCount,  max((Total_cases/population))*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PrecentPopulationInfected desc

--Showing Countries with Highest Death County Per Population

select Location, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
group by location
order by TotalDeathCount desc

--Breaking things down by continent

select continent, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
group by continent
order by TotalDeathCount desc

--Breaking things down by location

select location, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null 
group by location
order by TotalDeathCount desc

--showing continents with the highest death count per population

select continent, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
group by continent
order by TotalDeathCount desc

--Gobal Numbers

select  date, sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_dealths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2


select  sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_dealths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2


--Joining tables
Select *
From PortfolioProject..CovidDeaths DEA
join PortfolioProject..CovidVaccinations VAC
	on dea.location = vac.location
	and dea.date = vac.date


--Looking at Total Population vs Vaccinsations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVacinated
,(RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths DEA
join PortfolioProject..CovidVaccinations VAC
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2, 3 

--use CTE
with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths DEA
join PortfolioProject..CovidVaccinations VAC
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3 
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--temp table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
