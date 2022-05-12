Select *
from PortfolioProject .. CovidDeath
where continent is not null
order by 3,4

--Select *
--from PortfolioProject .. CovidVaccination$
--order by 3,4
-- Select Data that we are going to be using


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2


-- Show likelihood of dying if you contract Covid 19 in a specific Country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%state%'
and continent is not null
order by 1,2

-- Looking at the Total Cases vs Population
-- Show what percentatge of population that got Covid

select Location, Date, Population, Total_Cases, (total_cases*100)/population as CasePercentage
from PortfolioProject..CovidDeath
-- where location like '%state%'
where continent is not null
order by 1,2

-- Looking at contries with highest Infection Rate compare to population

select Location, Population, MAX(Total_Cases) as HighestInfectionCount, MAX(total_cases*100)/population as PercentPopInfected
from PortfolioProject..CovidDeath
--where location like '%state%'
where continent is not null
group by Location, Population 
order by PercentPopInfected desc


-- Contries with the Highest death count per Population
--Total_death has a VARCHAR data type, we need then to cast it in order to be able to perform calculation on it
select Location, MAX(cast (Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%state%'
where continent is not null
group by Location, Population 
order by TotalDeathCount desc

-- Let's break it down by Continent

select continent, MAX(cast (Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc


select location, MAX(cast (Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is null
group by location
order by TotalDeathCount desc


-- Continent with the highest death count per population

select continent, MAX(cast (Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers
--total_deaths has VARCHAR as data type and we will need to change it into INT in order to make a calculation on it

select date, SUM(new_cases) as TotalNewCase, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeath
-- where location like '%state%'
where continent is not null
group by date
order by 1,2

--Total Cases and Deaths
select SUM(new_cases) as TotalNewCase, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeath
-- where location like '%state%'
where continent is not null
--group by date
order by 1,2



select *
from PortfolioProject .. CovidVaccination


--Let joint Covid tables CovidDeaths, and CovidVaccination together
and 

select * 
from PortfolioProject..CovidDeath dea
join PortfolioProject ..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date


--Total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject ..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject ..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
 
--where location = 'Albania'
--order by location

Select *, (RollingPeopleVaccinated/population)*100 as PercOfPeopleVaccinated
from PopvsVac


-- TEMP TABLE
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject ..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercOfPeopleVaccinated
from #PercentagePopulationVaccinated
 as 
--Creating Views to store data for later visualizations

Create View PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject ..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentagePopulationVaccinated


create view PopulationInfected as
select Location, Date, Population, Total_Cases, (total_cases*100)/population as CasePercentage
from PortfolioProject..CovidDeath
-- where location like '%state%'
where continent is not null

select * from PopulationInfected
