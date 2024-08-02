select * from covid_project..CovidDeaths$
where continent is not null
order by 3,4

select * from covid_project..CovidVaccinations$
order by 3,4

----- select the data we want------

select location,date,total_deaths,new_cases,total_cases,population
from covid_project..CovidDeaths$
order by 1,2

---------------- looking at total_death vs total_cases ---------------------

select location,date,population,total_deaths,new_cases,round((total_deaths/total_cases)*100,2) as Death_Percentage
from covid_project..CovidDeaths$
where location like 'India%'
and  continent is not null
order by 1,2


------- total cases vs population-----------
------ what percentage of  population got covid-----------

select location,date,population,new_cases,round((total_cases/population)*100,2) as Percentage_Population_infected
from covid_project..CovidDeaths$
where location like 'India%'
order by 1,2

------ looking at country with highest population-------------

select location, max(total_cases) as highest_population_cases
from covid_project..CovidDeaths$
group by location
order by highest_population_cases desc

------- showing country with highest death count per population--------------

select location, max(cast(total_deaths as int)) as total_death_count
from covid_project..CovidDeaths$
where continent is not null
group by location
order by total_death_count desc

-------- let break things down by contients --------------




--------- show continent with the highest death count per population ----------------
select continent, max(cast(total_deaths as int)) as total_death_count
from covid_project..CovidDeaths$
where continent is not  null
group by continent
order by total_death_count desc


--------- Global number ------------
select  sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death ,
round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as death_percentage
from covid_project..CovidDeaths$
where continent is not  null


-

 ---- looking at  total population vs vaccination ------

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  covid_project..CovidDeaths$ dea
Join covid_project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From   covid_project..CovidDeaths$ dea
Join covid_project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_project..CovidDeaths$ dea
Join covid_project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_project..CovidDeaths$ dea
Join covid_project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
