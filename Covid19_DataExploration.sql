-- The imported data is dated upto 09/02/22 Accessed via: https://ourworldindata.org/covid-deaths
-- First ever SQL Project (< 1 week into using SQL)
-- Data exploration of COVID-19

---------------------EXPLORATION OF CovidDeaths DATA--------------------

-- Looking at Total Cases vs Total Deaths in the UK

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1, 2

-- Looking at Total Cases vs Population in the UK

Select Location, date, total_cases,  population, total_deaths, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where location = 'United Kingdom'
order by 1, 2

-- Exploring which countries have greatest infection rate

Select location, continent, population, MAX(total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, continent, population 
order by 4 desc

-- Exploring which countries have highest death count

Select location, continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by location, continent
order by TotalDeathCount desc

-- Exploring death count for each continent (besides Antartica due to no data)

Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths 
where location IN ('Europe', 'Asia', 'Africa', 'Oceania', 'North America', 'South America') 
group by location
order by TotalDeathCount desc


------------------------ EXPLORING GLOBAL NUMBERS-----------------------------

-- Global Death Rate

Select SUM(new_cases) as Global_Cases, SUM(Cast(new_deaths as int)) as Global_Deaths, (SUM(Cast(new_deaths as int))/SUM(new_cases))*100 as DeathRate
from PortfolioProject..CovidDeaths
where continent is not null

-- Highest-lowest global daily new cases

Select date, SUM(new_cases) WorldDailyCases
from PortfolioProject..CovidDeaths
group by date
order by WorldDailyCases desc

-- Highest-lowest global daily deaths

Select date, SUM(Cast(new_deaths as int)) as GlobalDailyDeaths
from PortfolioProject..CovidDeaths
group by date
order by GlobalDailyDeaths desc

-- Calculating global death rate percentage

Select date, SUM(total_cases) as Global_cases
,SUM(Cast(total_deaths as INT)) as Gloabl_deaths
,(SUM(Cast(total_deaths as INT))/(SUM(total_cases)))*100 as GlobalDeathRate
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by date desc	

---------------------EXPLORATION OF CovidVaccinations DATA--------------------

-- Exploring Countries vs Vaccinations overtime
-- 1) Using a CTE

With CountryPopVsVac (continent, location, date, population, new_people_vaccinated_smoothed, VaccineCount)
as
(
Select d.continent, d.location, d.date, d.population, v.new_people_vaccinated_smoothed
,SUM(Cast(v.new_people_vaccinated_smoothed as bigint)) OVER (Partition by d.location order by d.date) as VaccineCount
from PortfolioProject..CovidDeaths as d
Join PortfolioProject..CovidVaccinations as v
	on d.location = v.location 
	and d.date = v.date
where d.continent is not null
)
Select *, (VaccineCount/population)*100 as VaccinatedPercentage
from CountryPopVsVac

-- 2) Using a TEMP TABLE

Drop table if exists #PercentPopVaccinated
Create table #PercentPopVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_people_vaccinated_smoothed numeric,
VaccineCount numeric
)

Insert into #PercentPopVaccinated
Select d.continent, d.location, d.date, d.population, v.new_people_vaccinated_smoothed
,SUM(Cast(v.new_people_vaccinated_smoothed as bigint)) OVER (Partition by d.location order by d.date) as VaccineCount
from PortfolioProject..CovidDeaths as d
Join PortfolioProject..CovidVaccinations as v
	on d.location = v.location 
	and d.date = v.date
where d.continent is not null

Select *, (VaccineCount/population)*100 as VaccinatedPercentage
from #PercentPopVaccinated

-- Breaking down the percentage of population vaccinated by continent (as of 09/02/22)

Drop table if exists #ContPeopleVaccinated
Create table #ContPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_people_vaccinated_smoothed numeric,
ContVaccineCount numeric,
)
Insert into #ContPeopleVaccinated
Select d.continent, d.location, d.date, d.population, v.new_people_vaccinated_smoothed
,SUM(Cast(v.new_people_vaccinated_smoothed as bigint)) OVER (Partition by d.location order by d.date) as ContVaccineCount
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is null

Select location as Continent, (ContVaccineCount/population)*100 as PercentVaccinated
from #ContPeopleVaccinated
where date = '2022-02-09 00:00:00.000'	
and location IN ('Europe', 'Asia', 'Africa', 'Oceania', 'North America', 'South America')	


---------------- CREATING VIEWS THAT WILL BE USED FOR TABLEAU VISUALISATION -----------

--1) View containing breakdown of UK death rate overtime
Go
Create view UKCasesVsDeaths as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%kingdom%'

--2) View containing breakdown of UK infected rate overtime
Go
Create view UK_CasesVsPop as
Select Location, date, total_cases,  population, total_deaths, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where location = 'United Kingdom'

--3) View containing breakdown of each countries percent of population vaccinated (minimum of 1 time)
Go
Create view CountryVacPercent as
With CountryPopVsVac (continent, location, date, population, new_people_vaccinated_smoothed, VaccineCount)
as
(
Select d.continent, d.location, d.date, d.population, v.new_people_vaccinated_smoothed
,SUM(Cast(v.new_people_vaccinated_smoothed as bigint)) OVER (Partition by d.location order by d.date) as VaccineCount
from PortfolioProject..CovidDeaths as d
Join PortfolioProject..CovidVaccinations as v
	on d.location = v.location 
	and d.date = v.date
where d.continent is not null
)
Select *, (VaccineCount/population)*100 as VaccinatedPercentage
from CountryPopVsVac




