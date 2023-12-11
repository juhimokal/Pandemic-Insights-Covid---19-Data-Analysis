Select *
From PortfolioProject..CovidDeaths$
order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
order by 3,4

Select location , date,total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

Select location , date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%india%'
order by 1,2

Select location , date,Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location like '%india%'
order by 1,2

Select continent ,Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--where location like '%india%'
group by continent, population
order by PercentPopulationInfected desc



-- BREAK THINGS DOWN BY CONTINENT -- 

--Showing continents with highest death counts per population --

Select continent , MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent 
order by TotalDeathCount desc

-- Global Numbers-- 

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2


-- Join on two tables -- 

-- Looking at total population vs vaccinations--

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
  On dea.location =vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE -- 

With PopvsVac (Continent, Location, Date , Population , NewVaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
  On dea.location =vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--temp table--

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric ,
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
  On dea.location =vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
  On dea.location =vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
