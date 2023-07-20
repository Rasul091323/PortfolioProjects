delete from CovidDeaths
where location like '%income%'


select * from CovidDeaths
--where continent is not null
order by 3,4


--Looking at Total Cases vs Total Deaths
--Showing likelihood of dying if you contract covid in your country 

select location, date, total_cases, new_cases, total_deaths,  
round(TRY_CONVERT(decimal(15,3), total_deaths)/TRY_CONVERT(decimal(15,3), total_cases) *100, 5) as DeathPercentage
from CovidDeaths
where  location like '%states%'                        
and TRY_CONVERT(decimal(15,3), total_deaths)/TRY_CONVERT(decimal(15,3), total_cases) *100 is not null 
order by 1, 2

--Looking at Total Cases vs Population
--Showing what percentage of population got Covid

select location, date, total_cases, new_cases, Population,  
round(TRY_CONVERT(decimal(15,3), total_cases)/TRY_CONVERT(decimal(15,3), population) *100, 5) as PercentPopulationInfected
from CovidDeaths
where  location like '%states%'                         
TRY_CONVERT(decimal(15,3), total_deaths)/TRY_CONVERT(decimal(15,3), total_cases) *100 is not null 
order by 1, 2


--Looking at Countries with Highest Infection Rate compared to Population

select location, 
       population, 
	   max(total_cases) as HigestInfectionCount,  
       max(TRY_CONVERT(decimal(15,3), total_deaths)/TRY_CONVERT(decimal(15,3), total_cases) *100) as PrecentPopulationInfected
from CovidDeaths
--where location like '%states%'
group by location, population
order by PrecentPopulationInfected desc

--Showing Countries with Highest Death per Population

select location, 
       max(try_convert(int, total_deaths)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Let's break things doen by continent
--Showing continents with highest death count per population

select continent,  
       max(try_convert(int, total_deaths)) as TotalDeathCount
from CovidDeaths
where continent is  not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select  --try_convert(date, date) as date, 
        sum(cast(new_cases as int)) as newcases, 
		sum(cast(new_deaths as int)) as newdeaths,
        (sum(cast (new_deaths as int))/sum(cast( new_cases as int))) *100 as DeathPercentage
from CovidDeaths
where continent is not null 
--and new_cases is not null
--and new_deaths is not null
-- group by date
order by 1


---------------------------------------------------------------------------------------------------------------------------------
 
--Looking at Total Population vs  Vaccinations 

select dea.continent, 
       dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as country_case 

 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 --and vac.new_vaccinations is not null 
 order by  2, 3


 --with cte 
 with Pop_Vac  ( Continent, Location, Date, Population, New_vaccinations, country_case)
 as (
 select dea.continent, 
       dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as country_case

 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 --and vac.new_vaccinations is not null 
 )
 select a.*, a.country_case/convert(int, a.Population)*100 as vac_people from Pop_Vac a 
 where a.country_case/a.Population <> '0'



 --#Temp_table
 drop table if exists #PrecentPopulationVaccinated
 create table #PrecentPopulationVaccinated
 (Continent nvarchar(255), 
 Location nvarchar(255), 
 Date datetime, 
 Population numeric, 
 New_vaccinations numeric, 
 Country_case numeric
 )
 insert into #PrecentPopulationVaccinated
 select dea.continent, 
       dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as country_case 

 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null 
 --and vac.new_vaccinations is not null 
 --order by  2, 3

select a.*, a.country_case/convert(bigint, a.Population)*100 as vac_people from #PrecentPopulationVaccinated a


--View
--Creatng view to store data for later visualizations

create view PrecentPopulationVaccinated as 
select dea.continent, 
       dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as country_case 

 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 










