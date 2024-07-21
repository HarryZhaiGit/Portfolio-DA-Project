select * 
from PortfolioProject..CovidDeaths$
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
order by 3,4

--select data that we are going to be using
select location,date,total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
where Location = '%States%'
order by 1,2


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location = 'China' 
order by 1,2

-- looking at total cases vs population
--shows what percentage of population got Covid
select location,date,total_cases,population,(total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths$
where location = 'United States'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,max(total_cases) as max_total_case,population,(max(total_cases)/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths$
group by location,population
order by 4 desc

--let's break things down by continent


--showing countries with hightest death count per population
select location,max(total_deaths) as totaldeathcount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by 2 desc

--showing continents with the highest death count per population
select location,max(total_deaths) as totaldeathcount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by 2 desc

-- global numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations
select dea.date,dea.continent,dea.location, dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 3,2,1

--use cte
with popvsvac--(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) 
as (
select dea.date,dea.continent,dea.location, dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 3,2,1
)

select *,(RollingPeopleVaccinated/population)*100
from popvsvac


--temp table
drop table if exists #PopulationPercentVaccinated
create table #PopulationPercentVaccinated
(date datetime,
continent nvarchar(255),
location nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PopulationPercentVaccinated
select dea.date,dea.continent,dea.location, dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	and dea.continent = vac.continent
--where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #PopulationPercentVaccinated
order by 3,2,1

--Create view for later visualization

Create View PercentPopulationVaccinatedView as
select 
dea.date,
dea.continent,
dea.location, 
dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from PercentPopulationVaccinatedView