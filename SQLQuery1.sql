
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathsPercentage
From PortfolioProject..CovidDeaths
Where location = 'Argentina'
and continent is not null
order by 1,2

--Looking at TotalCases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as IllPopulation
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location = 'Argentina'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'Argentina'
Where continent is not null
Group by location, population
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Argentina'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Argentina'
Where continent is null
Group by location
order by TotalDeathCount desc


--Globar Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathsPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'Argentina'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations


-- USE CTE

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPeoplePercentage
From PopvsVac

--Temp Table
DROP TABLE if exists
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPeoplePercentage
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated