

Select * from PortfolioProject..CovidDeaths
order by 3,4

--Select * from PortfolioProject..CovidVaccinations 
--order by 3,4

-- Select the Data we are going to be using

Select location,date,total_cases,new_cases, total_deaths,population from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location,date,total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' 
order by 1,2

-- Looking at the Total Cases vs Population
-- What percentage of the population got Covid

Select location,date,population, total_cases,  (cast(total_cases as int)/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location,population, max(cast(total_cases as int)) as HightestInfectionCount,  Max((total_cases)/(population))*100 as PopulationInfectedPerecent
From PortfolioProject..CovidDeaths
Group by location, population
order by 4 desc

 -- Showing countries with the Highest Death Count vs Population 

Select location, MAX(CAST(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location
order by 2 desc


-- LET'S BREAK THINGS DOWN BY CONTINENT: 

Select continent, MAX(CAST(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by 2 desc

-- Another way of doing it

Select location, MAX(CAST(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is null
Group by location
order by 2 desc

	
--  Death Percentage of Covid Cases globally per day

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and new_cases != 0
--group by date
order by 1,2

-- Death Percentage of Covid Cases globally summed up

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and new_cases != 0
order by 1,2

-- Looking at Total Population vs Total Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date =  vac.date
where dea.continent is not null and dea.location = 'Albania'
Order by 2,3

-- Looking at Total Population vs Total Vaccinations using CTE (Common Table Expressions)

with PopvsVac(Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date =  vac.date
where dea.continent is not null and dea.location = 'Albania'
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVacPercentage From PopvsVac

-- Looking at Total Population vs Total Vaccinations using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date =  vac.date
where dea.continent is not null and dea.location = 'Albania'
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVacPercentage From #PercentPopulationVaccinated


--Creating View to store data for later visualisation

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date =  vac.date
where dea.continent is not null and dea.location = 'Albania'
--Order by 2,3