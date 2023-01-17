SELECT * FROM [SQL Portfolio Project].dbo.CovidDeaths 
where continent is not null
order by 3,4;

--SELECT * FROM [SQL Portfolio Project].dbo.CovidVaccination order by 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population FROM [SQL Portfolio Project].dbo.CovidDeaths order by 1,2;

--looking at total  cases vs total  deaths
--looking

SELECT location, date, total_cases, total_deaths, 
(Total_deaths/total_cases)*100 AS DeathPercentage 
FROM [SQL Portfolio Project].dbo.CovidDeaths 
where location like '%states%' 
order by 1,2;

--Looking at total cases vs Population
-- shows what percentage of population got the virus

SELECT location, date, Population, total_cases,
(Total_cases/population)*100 AS DeathPercentage 
FROM [SQL Portfolio Project].dbo.CovidDeaths 
where location like '%states%' order by 1,2;


-- Looking at countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount,
MAX((Total_cases/population))*100 AS PercentpopulationInfected 
FROM [SQL Portfolio Project].dbo.CovidDeaths 
where location like '%states%' 
group by Location,population 
order by PercentPopulationInfected desc;

--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM [SQL Portfolio Project].dbo.CovidDeaths 
--where location like '%states%' 
where continent is not null
group by continent
order by Totaldeathcount desc;

SELECT location, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM [SQL Portfolio Project].dbo.CovidDeaths 
--where location like '%states%' 
where continent is null
group by location
order by Totaldeathcount desc;

-- showing continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM [SQL Portfolio Project].dbo.CovidDeaths 
--where location like '%states%' 
where continent is not null
group by continent
order by Totaldeathcount desc;

-- showing the countries with the Highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM [SQL Portfolio Project].dbo.CovidDeaths 
--where location like '%states%' 
where continent is not null
group by Location
order by Totaldeathcount desc;

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, 
SUM(Cast(new_deaths as int)) as total_deaths, 
SUM(Cast(new_deaths as int))/SUM(New_Cases)*100
as DeathPercentage From [SQL Portfolio Project].DBO.CovidDeaths
Where continent is not null
group by date
order by 1,2;

Select SUM(new_cases) as total_cases, 
SUM(Cast(new_deaths as int)) as total_deaths, 
SUM(Cast(new_deaths as int))/SUM(New_Cases)*100
as DeathPercentage From [SQL Portfolio Project].DBO.CovidDeaths
Where continent is not null
--group by date
order by 1,2;


SELECT * FROM [SQL Portfolio Project]..CovidVaccinations$

SELECT * FROM [SQL Portfolio Project]..CovidDeaths CVD
Join [SQL Portfolio Project]..CovidVaccinations$ CVV
ON CVD.location = CVV.location
AND CVD.date = CVV.date


--Looking at total population vs vaccination (total amount of people in the world that have been vaccinated

SELECT CVD.continent, CVD.location, CVD.date,CVD.population, 
CVV.new_vaccinations FROM [SQL Portfolio Project]..CovidDeaths CVD
Join [SQL Portfolio Project]..CovidVaccinations$ CVV
ON CVD.location = CVV.location
AND CVD.date = CVV.date
where CVD.continent is not null
ORDER BY 2,3

--CREATE A ROLLING NUMBER COLUMN

SELECT CVD.continent, CVD.location, CVD.date,CVD.population, 
CVV.new_vaccinations, SUM(CONVERT(int, CVV.new_vaccinations)) 
OVER(Partition by CVD.location)
FROM [SQL Portfolio Project]..CovidDeaths CVD
Join [SQL Portfolio Project]..CovidVaccinations$ CVV
ON CVD.location = CVV.location
AND CVD.date = CVV.date
where CVD.continent is not null
ORDER BY 2,3

SELECT CVD.continent, CVD.location, CVD.date,CVD.population, 
CVV.new_vaccinations, SUM(CONVERT(int, CVV.new_vaccinations)) 
OVER(Partition by CVD.location order by CVD.location, CVD.date) AS RollingPeopleVaccinated
FROM [SQL Portfolio Project]..CovidDeaths CVD
Join [SQL Portfolio Project]..CovidVaccinations$ CVV
ON CVD.location = CVV.location
AND CVD.date = CVV.date
where CVD.continent is not null
ORDER BY 2,3

SELECT CVD.continent, CVD.location, CVD.date,CVD.population, 
CVV.new_vaccinations, SUM(CONVERT(int, CVV.new_vaccinations)) 
OVER(Partition by CVD.location order by CVD.location, CVD.date) 
AS RollingPeopleVaccinated
FROM [SQL Portfolio Project]..CovidDeaths CVD
Join [SQL Portfolio Project]..CovidVaccinations$ CVV
ON CVD.location = CVV.location
AND CVD.date = CVV.date
where CVD.continent is not null
ORDER BY 2,3

--USING CTE TO GET TOTAL NUMBER VACCINATED

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, 
RollingPeopleVaccinated) as 
(
SELECT CVD.continent, CVD.location, CVD.date,CVD.population, 
CVV.new_vaccinations, SUM(CONVERT(int, CVV.new_vaccinations)) 
OVER(Partition by CVD.location order by CVD.location, CVD.date) 
AS RollingPeopleVaccinated
FROM [SQL Portfolio Project]..CovidDeaths CVD
Join [SQL Portfolio Project]..CovidVaccinations$ CVV
ON CVD.location = CVV.location
AND CVD.date = CVV.date
where CVD.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac


-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT CVD.continent, CVD.location, CVD.date,CVD.population, 
CVV.new_vaccinations, SUM(CONVERT(int, CVV.new_vaccinations)) 
OVER(Partition by CVD.location order by CVD.location, CVD.date) 
AS RollingPeopleVaccinated
FROM [SQL Portfolio Project]..CovidDeaths CVD
Join [SQL Portfolio Project]..CovidVaccinations$ CVV
ON CVD.location = CVV.location
AND CVD.date = CVV.date
where CVD.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- creating view to store data for future visualizations

Create View PercentPopulationVaccinated as
SELECT CVD.continent, CVD.location, CVD.date,CVD.population, 
CVV.new_vaccinations, SUM(CONVERT(int, CVV.new_vaccinations)) 
OVER(Partition by CVD.location order by CVD.location, CVD.date) 
AS RollingPeopleVaccinated
FROM [SQL Portfolio Project]..CovidDeaths CVD
Join [SQL Portfolio Project]..CovidVaccinations$ CVV
ON CVD.location = CVV.location
AND CVD.date = CVV.date
where CVD.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated