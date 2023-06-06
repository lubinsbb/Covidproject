select *
from Covidproject..CovidDeaths
where continent is not null
order by 3,4;

select *
from Covidproject..CovidVaccinations
where continent is not null
order by 3,4;

-- select Data that we're going to be using --

select location, date, total_cases, new_cases, total_deaths, population
from Covidproject..CovidDeaths
where continent is not null
order by 1,2

--Lookin at Total Cases Vs Total Deaths--

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covidproject..CovidDeaths
where location like '%Colombia%'
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got covid

select location, date, population,total_cases, total_deaths, (total_cases/population)*100 as DeathPercentage
from Covidproject..CovidDeaths
where location like '%Colombia%'
order by 1,2

select location, date, population,total_cases, (total_cases/population)*100 as Percentofpopulationinfected
from Covidproject..CovidDeaths
--where location like '%Colombia%'
order by 1,2


--Looking at countries with highest infectation rates compared to population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as Percentofpopulationinfected
from Covidproject..CovidDeaths
--where location like '%Colombia%'
group by population, location
order by Percentofpopulationinfected desc


--showing countries with the highest death counts per population

select location, Max(Cast(total_deaths as int)) as TotalDeathsCount
from Covidproject..CovidDeaths
where continent is not null
group by location
order by TotalDeathsCount desc


--Let's break things down by continent


--Showing the continents with the highest


select location, Max(Cast(total_deaths as int)) as TotalDeathsCount
from Covidproject..CovidDeaths
where continent is null
group by location
order by TotalDeathsCount desc


--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covidproject..CovidDeaths
where continent is not null
group by date
order by 1,2


--if we remove Date, we will see the overall numbers across the world

select sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covidproject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Practicing JOIN

Select*
From Covidproject..CovidDeaths dea
join Covidproject..CovidVaccinations vac
On dea.location = vac.location
and dea.date=vac.date

--Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covidproject..CovidDeaths dea
join Covidproject..CovidVaccinations vac
On dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Use CTE

with PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covidproject..CovidDeaths dea
join Covidproject..CovidVaccinations vac
On dea.location = vac.location
and dea.date=vac.date
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopVsVac


--Use TEMP TABLE

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covidproject..CovidDeaths dea
join Covidproject..CovidVaccinations vac
On dea.location = vac.location
and dea.date=vac.date
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating a view for storage data for later visualization

Create view PeoplePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covidproject..CovidDeaths dea
join Covidproject..CovidVaccinations vac
On dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
