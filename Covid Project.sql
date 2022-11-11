Select *
FROM PortfolioProject1.dbo.[CovidDeaths]
Where continent is not null
order by 3,4

Select *
From PortfolioProject1.dbo.[CovidVaccinations]
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1.dbo.[CovidDeaths]
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1.dbo.[CovidDeaths]
Where location like '%states%'
order by 1,2


--looking at total cases vs the Population
-- shows what percentage of population got covid
Select Location, date,Population, total_cases, (total_cases/Population)*100 as PercentofPopulationInfected
From PortfolioProject1.dbo.[CovidDeaths]
--Where location like '%states%'
order by 1,2


--Looking at Countries with Highest infection rate compared to population
Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulatedInfected
From PortfolioProject1.dbo.[CovidDeaths]
--Where location like '%states%'
Group by Location, Population
order by PercentPopulatedInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1.dbo.[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
-- This is the correct way but hes using the one below this one in the video
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1.dbo.[CovidDeaths]
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc


--Showing the continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1.dbo.[CovidDeaths]
--Where location like '%states%'       can add this in if looking at the United States
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers
-- By day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1.dbo.[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2

--Total Cases
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1.dbo.[CovidDeaths]
--Where location like '%states%'
Where continent is not null
order by 1,2



--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
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
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Create View to store data for later visaulizations

Create View PercentPopulationVacinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3