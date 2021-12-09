SELECT *
FROM CovidDeaths

SELECT *
FROM CovidVaccination
SELECT location,date,population,total_cases,new_cases,total_deaths
FROM CovidDeaths
ORDER BY 1,2

-- Total case VS Total Death

SELECT location,date,population,total_cases,total_deaths,(total_deaths/total_cases)*100AS DeathPercentage
FROM CovidDeaths
WHERE location = 'India' AND continent is NOT NULL
ORDER BY 1,2 

-- Total cases VS Population
SELECT location,date,population,total_cases,(total_cases/population)*100AS Percent_population_infected
FROM CovidDeaths
WHERE location = 'India' AND continent is NOT NULLthe 
ORDER BY 1,2 


--countries with Highest infection 

SELECT location,population,MAX(total_cases)As highestinfectioncount,MAX((total_cases/population))*100AS Percent_population_infected
FROM CovidDeaths
WHERE continent IS NOT NULL
group by location,population
ORDER BYthe  4 DESC

--Countries with Highest Death count

SELECT location,population,MAX(cast(total_deaths as int))As highestdeathcount,MAX((total_cases/population))*100AS Percent_population_infected
FROM CovidDeaths
WHERE continent IS NOT NULL
group by location,population
ORDER BY 3 DESC

--By Continent
SELECT continent,MAX(cast(total_deaths as int))As highestdeathcount
FROM CovidDeaths
WHERE continent Is not null
group by continent
ORDER BY 2 DESC

-- Global Number


SELECT Sum(new_cases) As total_cases,SUM(CAST(new_deaths as int)) AS totaldeath,SUM(CAST(new_deaths as int))/Sum(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE  continent is NOT NULL
ORDER BY 1,2

-- Joining two tables (CovidDeaths and CovidVaccination)

SELECT*
FROM CovidDeaths AS CD
join CovidVaccination AS CV
on CD.location =CV.location
and CD.date = CV.date

-- Total Population VS Total Vaccination

SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
sum(CAST(CV.new_vaccinations AS bigint)) over (partition by CD.location order by CD.location,CD.date) AS peoplevaccinated
FROM CovidDeaths AS CD
join CovidVaccination AS CV
on CD.location =CV.location
and CD.date = CV.date
WHERE CD.continent is not null
ORDER  BY 2,3


-- Creating TEMP Table

with popvsvac ( continent,date,location,population,new_vaccinations,peoplevaccinated)
as
(
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
sum(CAST(CV.new_vaccinations AS bigint)) over (partition by CD.location order by CD.location,CD.date) AS peoplevaccinated
FROM CovidDeaths AS CD
join CovidVaccination AS CV
on CD.location =CV.location
and CD.date = CV.date
WHERE CD.continent is not null
)
Select*,(peoplevaccinated/population)*100 AS Vaccination_pecerntage
From popvsvac

--Temp Table1
DROP Table if exists #presentpopulationvaccinated
CREATE TABLE #presentpopulationvaccinated
(
continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccination numeric,
peoplevaccinated numeric
)
INSERT INTO #presentpopulationvaccinated

SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(bigint,CV.new_vaccinations)) over (partition by CD.location order by CD.location,CD.date) AS peoplevaccinated
FROM CovidDeaths AS CD
join CovidVaccination AS CV
on CD.location =CV.location
and CD.date = CV.date
--WHERE CD.continent is not null

Select*,(peoplevaccinated/population)*100 AS Vaccination_pecerntage
From #presentpopulationvaccinated



-- Creating view to store data for visualization

create view presentpopulationvaccinated as
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(bigint,CV.new_vaccinations)) over (partition by CD.location order by CD.location,CD.date) AS peoplevaccinated
FROM CovidDeaths AS CD
join CovidVaccination AS CV
on CD.location =CV.location
and CD.date = CV.date
WHERE CD.continent is not null

SELECT*
FROM presentpopulationvaccinated





