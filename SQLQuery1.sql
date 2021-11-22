select * from [Project Portfolio].. ['Covid death$']
order by 3,4

select * from [Project Portfolio].. ['owid-covid-data$']
order by 3,4 

----select data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from [Project Portfolio].. ['Covid death$']
order by 1,2

----looking at total cases vs total deaths
----Shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from [Project Portfolio].. ['Covid death$']
where location like '%states%'
order by 1,2


----Looking at Total cases vs Population
---- shows what perventage of population got covid
select Location, date, total_cases, Population, (Total_deaths/population)*100 as DeathPercentage
from [Project Portfolio].. ['Covid death$']
where location like '%states%'
order by 1,2

----Looking at countries with highest infection rate compared to population

select Location, Population, MAX(total_cases)as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from [Project Portfolio]..['Covid death$']
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc;




--Showing Countries with Highest Death Count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Project Portfolio]..['Covid death$']
--where location like '%states%'
where continent is not null
Group by Location
Order by TotalDeathCount desc;

--LET'S BREAK THINGS DOWN BY CONTINENT

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Project Portfolio]..['Covid death$']
--where location like '%states%'
where continent is null
Group by location
Order by TotalDeathCount desc;


--showing the continents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Project Portfolio]..['Covid death$']
--where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers
select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, (Total_deaths/total_cases)*100 as DeathPercentage
from [Project Portfolio].. ['Covid death$']
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2



--Looking at Total Populations vs Vaccinations

--USE CTE

with  PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated-- (RollingPeopleVaccinated/population)*100
From [Project Portfolio]..['Covid death$'] dea
Join [Project Portfolio]..['owid-covid-data$'] vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--PARTITION BYclause is to specify the column on which we need to perform aggregation. The two queries below come out with the same result. 
--SELECT Customercity, CustomerName ,OrderAmount,
--       AVG(Orderamount) AS AvgOrderAmount, 
--       MIN(OrderAmount) AS MinOrderAmount, 
--       SUM(Orderamount) TotalOrderAmount
--FROM [dbo].[Orders]
--GROUP BY Customercity;
--SELECT Customercity, 
--       AVG(Orderamount) OVER(PARTITION BY Customercity) AS AvgOrderAmount, 
--       MIN(OrderAmount) OVER(PARTITION BY Customercity) AS MinOrderAmount, 
--       SUM(Orderamount) OVER(PARTITION BY Customercity) TotalOrderAmount
--FROM [dbo].[Orders];


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continen nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From [Project Portfolio]..['Covid death$'] dea
Join [Project Portfolio]..['owid-covid-data$'] vac
on dea.location=vac.location
and dea.date= vac.date
------where dea.continent is not null
--------order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

 

 --Creating view to store data for later visualization

 Create View PercentPopulationVaccinated as
 select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From [Project Portfolio]..['Covid death$'] dea
Join [Project Portfolio]..['owid-covid-data$'] vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select *
From PercentPopulationVaccinated
