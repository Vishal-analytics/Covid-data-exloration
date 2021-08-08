
/* COVID dataset exploration with SQL

Skillls used joins, views, aggregartion, window functions and CTE */


select *
from [Portfolio Project]..['CovidDeaths']
order by 3,4

select *
from [Portfolio Project]..['CovidVaccinations']
order by 3,4

--Data Exploration

select Location, date,total_cases,new_cases, total_deaths, population
from [Portfolio Project]..['CovidDeaths']
order by 1,2

--Total cases Vs Total Deaths

select Location,max(total_cases) as Total_cases, max(total_deaths) as Total_deaths, (max(total_deaths)/max(total_cases))*100 as Death_Percentage
from [Portfolio Project]..['CovidDeaths']
--where location= 'India'
group by location
order by Death_Percentage desc



--Countries with highest infection rate

select Location, date, max(total_cases) as Total_cases, population as Total_poulation, (max(total_cases)/population)*100 as PopulationPercentageInfected
from [Portfolio Project]..['CovidDeaths']
--where location= 'India'
group by location,population,date
order by PopulationPercentageInfected desc


--Countries with highest death rate

select Location,max(cast(total_deaths as int)) as Total_deaths
from [Portfolio Project]..['CovidDeaths']
where continent is not null
group by location
order by Total_deaths desc


--Continents with total deaths 

select location,max(cast(total_deaths as int)) as Total_deaths
from [Portfolio Project]..['CovidDeaths']
where continent is null and location not in( 'World' , 'European Union' , 'International')
group by location
order by Total_deaths desc


--All over world

select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_percentage
from [Portfolio Project]..['CovidDeaths']
where continent is not null
--group by date
order by Death_percentage desc


--Vaccinaion table
Select * 
from [Portfolio Project]..['CovidVaccinations']

Select *
from [Portfolio Project]..['CovidVaccinations']



select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
from [Portfolio Project]..['CovidDeaths'] deaths
join [Portfolio Project]..['CovidVaccinations'] vaccination
on deaths.location =vaccination.location
and deaths.date=vaccination.date
where deaths.continent is not null
order by 2,3




select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
(sum(cast(vaccination.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date)) as CumulativeVaccinaitons
from [Portfolio Project]..['CovidDeaths'] deaths
join [Portfolio Project]..['CovidVaccinations'] vaccination
on deaths.location =vaccination.location
and deaths.date=vaccination.date
where deaths.continent is not null
order by 2,3



with popvaccinated 
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
(sum(cast(vaccination.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date)) as CumulativeVaccinaitons
from [Portfolio Project]..['CovidDeaths'] deaths
join [Portfolio Project]..['CovidVaccinations'] vaccination
on deaths.location =vaccination.location
and deaths.date=vaccination.date
where deaths.continent is not null
)
select  * ,(CumulativeVaccinaitons/population)*100 as Vaccinated_percentage
from popvaccinated 
--where location='India'

select a.continent,a.location, a.people_fully_vaccinated, a.new_vaccinations,b.population
from [Portfolio Project]..['CovidVaccinations'] as a
join [Portfolio Project]..['CovidDeaths'] as b
on a.location=b.location and a.date=b.date


--Vacination % by country

Create view [Vaccination summary] as
select a.continent,a.location, max(cast(a.people_fully_vaccinated as int)) as total_vaccinated, max(b.population) as total_population,
max(cast(a.people_fully_vaccinated as int)/b.population) *100 as percentage_vaccinated
from [Portfolio Project]..['CovidVaccinations'] as a
join [Portfolio Project]..['CovidDeaths'] as b
on a.location=b.location and a.date=b.date
where a.continent is not null and a.location not in( 'World' , 'European Union' , 'International')
group by a.continent, a.location

select * from [Vaccination summary]
