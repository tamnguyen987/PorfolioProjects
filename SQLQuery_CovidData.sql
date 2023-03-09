
Select *
From PorfolioProject..CovidDeaths
Where continent is not NULL
Order by 3,4 

--Select *
--From PorfolioProject..CovidVaccinations
--Order by 3,4 

--NOTE: Select the data that will be using

/*
START WORKING ON CovidDeaths: 
*/
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
ORDER BY 1,2 

--NOTE: Firstly, looking at Total Cases vs. Total Deaths, Calculate  % of Death
-- Using likelihooh to discover deathPercentage in the U.S: Where location like '%states%'
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2 

--NOTE: Secondly, looking at Total Cases vs. Population 
-- Show what Percentage of population got COVID 
SELECT location, date, population, total_cases, (total_cases/ population)*100 AS PercentagePopulationInfected
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2 

--NOTE: Thirdly, looking at which Countries with HIGHEST Infection Rate compared to Population 
-- Need to use GROUP BY function to make sure data is categorized by Location and Population
-- Order By "PercentagePopulationInfected" descending
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ population))*100 AS PercentagePopulationInfected
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

--NOTE: Fourthly, looking at which Countries with HIGHEST Death Count per Population
-- Using "Where continent is not NULL" to eliminate NULL data in the whole Continent
SELECT location, MAX(Cast(total_deaths as Int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- NOW, break things down by Location
SELECT location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- NOW, break things down by Continent
SELECT continent, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--NOW, look at Global Number: 2 cases (group by date and no using group by function)
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not NULL
--GROUP BY date
ORDER BY 1,2

/*
NOW: WORKING ON CovidVaccinations by JOIN 2 tables: 
*/

Select *
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--NOTE: Look at Total Population vs Vaccinations
-- Using: Partition by to store Sum of New Vaccinations, then the data will automatically adding up the following lines.
-- REMEMBER: using BIGINT instead of INT when convert data that sum value is too BIG (Ex:now has exceeded 2,147,483,647)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) *100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
Order by 2,3

-- USING: CTE for common table expresion)
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) *100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Next, using TEMP TABLE:to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) *100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not NULL
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


/*
CREATING VIEW TO STORE DATA FOR VISUALIZATIONS LAATER (TABLEAU): 
*/

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated