select * 
from Covid..CovidDeaths where continent is not null;


select location,date,total_cases,new_cases,total_deaths,population 
from Covid..CovidDeaths
order by 1, 2;

--Looking at Total Cases vs Total Deaths
select location,date,total_cases,total_deaths , (total_deaths / total_cases ) * 100 as DeathPercentange
from Covid..CovidDeaths
where location like 'Ind%'
order by 1, 2;

--Looking at Total Cases vs Population
select location,date, population,total_cases , (total_cases / population) * 100 as PopulationGotCovid
from Covid..CovidDeaths
--where location like '%states%'
order by 1, 2;

--Looking at countries with highest infection rate compared to Population
select location, population,max(total_cases) as HighestInfectionCount, max((total_cases / population)) * 100 as PercentPopulationInfected
from Covid..CovidDeaths
--where location like '%states%'
where continent is not null 
group by location, population
order by  PercentPopulationInfected desc;


--Looking at countries with highest death rate per population

select location,max(cast (total_deaths as int)) as HighestDeathCount
from Covid..CovidDeaths
--where location like '%states%'
where continent is not null 
--and location like '%korea%'
group by location
order by  HighestDeathCount desc;

-- highest death rate by continents 

select location,max(cast (total_deaths as int)) as HighestDeathCount
from Covid..CovidDeaths
--where location like '%states%'
where continent is  null 
--and location like '%korea%'
group by location
order by  HighestDeathCount desc;


-- global numbers

select date,sum(new_cases)  --,total_deaths , (total_deaths / total_cases ) * 100 as DeathPercentange
from Covid..CovidDeaths
where continent is not null
group by date , total_cases,total_deaths
order by 1, 2;

-- looking at total population vs vaccinations

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as sumofvaccinations
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2, 3;

--use cte
with PopvsVac (continent , location ,date, population , vaccination , sumofvaccinations)
as (select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as sumofvaccinations
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
)
select * , (sumofvaccinations / population ) * 100 as Percentange from PopvsVac;

--temp table
--drop table if exists #PercetnPopulationVaccinate ;
create table #PercetnPopulationVaccinate (

continent nvarchar(255) ,
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric, 
sumofvaccinations numeric)

insert into #PercetnPopulationVaccinate
select 
dea.continent , 
dea.location , 
dea.date , 
dea.population , 
vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as sumofvaccinations
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null ;

select * from #PercetnPopulationVaccinate;

create view PercentPopulationVaccinated as 
select 
dea.continent , 
dea.location , 
dea.date , 
dea.population , 
vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as sumofvaccinations
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated;