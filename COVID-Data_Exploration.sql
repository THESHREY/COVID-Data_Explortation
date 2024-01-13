select *
from [COVID-Data Exploration]..CovidDeaths
where continent is not null
order by 3,4


--select *
--from [COVID-Data Exploration]..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from [COVID-Data Exploration]..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Cases VS. Total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from [COVID-Data Exploration]..CovidDeaths
where location like '%state%'
and continent is not null
order by 1,2


-- Looking at Total Cases VS. Population
-- Shows what percentage of population got COVID

select location,date,population,total_cases,(total_cases/population)*100 as InfactionPercentage 
from [COVID-Data Exploration]..CovidDeaths
where location like '%state%' 
and continent is not null
order by 1,2

 
--Looking at Countries with Highest Infection Rate compared to Population

select location,population,max(total_cases)as HighestInfectionCount,max(total_cases/population)*100 as HighestInfactionPercentage 
from [COVID-Data Exploration]..CovidDeaths
--where location like '%state%'
where continent is not null
group by location,population
order by HighestInfactionPercentage desc

--Showing Countries with Highest Death Count per Population

select location,max(caST(total_deaths AS INT))as HighestDeathsCount
from [COVID-Data Exploration]..CovidDeaths
--where location like '%state%'
where continent is not null
group by location
order by HighestDeathsCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

select continent,max(caST(total_deaths AS INT))as HighestDeathsCount
from [COVID-Data Exploration]..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by HighestDeathsCount desc


--GLOBAL NUBERS

select sum(new_cases)as GlobalCases,SUM(cast(new_deaths as int)) as GlobalDeaths,(SUM(cast(new_deaths as int))/sum(new_cases))*100 as GlobalDeathPercentage 
from [COVID-Data Exploration]..CovidDeaths
--where location like '%state%'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population VS. Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , 
dea.date ) as TotalVaccinations
--,(TotalVaccinations/population)*100
from [COVID-Data Exploration]..CovidDeaths dea
join [COVID-Data Exploration]..CovidVaccinations vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with popvsVac(Continent,Location,Date,Population,new_vaccinations,TotalVaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , 
dea.date ) as TotalVaccinations
--,(TotalVaccinations/population)*100
from [COVID-Data Exploration]..CovidDeaths dea
join [COVID-Data Exploration]..CovidVaccinations vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(TotalVaccinations/Population)*100
from popvsVac



--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , 
dea.date ) as TotalVaccinations
--,(TotalVaccinations/population)*100
from [COVID-Data Exploration]..CovidDeaths dea
join [COVID-Data Exploration]..CovidVaccinations vac
	on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(TotalVaccinations/Population)*100
from #PercentPopulationVaccinated



-- creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , 
dea.date ) as TotalVaccinations
--,(TotalVaccinations/population)*100
from [COVID-Data Exploration]..CovidDeaths dea
join [COVID-Data Exploration]..CovidVaccinations vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *
from PercentPopulationVaccinated