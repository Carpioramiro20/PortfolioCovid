select * 
from PortfolioCovid..CovidMuertes
order by 3,4

--select * 
--from PortfolioCovid..CovidVacunas
--order by 3,4


alter table [dbo].[CovidMuertes] alter column total_deaths float;
alter table [dbo].[CovidMuertes] alter column total_cases float;

--Comparación entre la totalidad de casos vs la totalidad de muertes
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS porcentajeMuertes
from PortfolioCovid..CovidMuertes
where location like 'Argentina'
order by 1,2

alter table [dbo].[CovidMuertes] alter column population float;
--Comparación entre la totalidad de casos vs la población
select location, date, population,total_cases, (total_cases/population)*100 AS porcentajePoblacionInfectada
from PortfolioCovid..CovidMuertes
where location like 'Argentina'
order by 1,2

--Paises con mayor numeros de coontagios
select location, population, Max(total_cases) as recuentoMayorInfectados, MAX((total_cases/population))*100 AS porcentajePoblacionInfectada
from PortfolioCovid..CovidMuertes
group by location, population
order by porcentajePoblacionInfectada desc

--Paises con mayor recuento de muertes por poblacion
select location, MAX(total_deaths) as  MayorRecuentoMuertes
from PortfolioCovid..CovidMuertes
where continent is not null
group by location
order by MayorRecuentoMuertes desc

--Datos agrupados por continente
select location, MAX(total_deaths) as  MayorRecuentoMuertes
from PortfolioCovid..CovidMuertes
where continent is null
group by location
order by MayorRecuentoMuertes desc

alter table [dbo].[CovidMuertes] alter column new_cases float;
alter table [dbo].[CovidMuertes] alter column new_deaths float;
-- Numeros  gloables
select SUM(new_cases) AS totalCasos,  SUM(new_deaths) as totalMuertes,  (sum(new_deaths) / SUM(new_cases)) *100 as porcentajeMuertes
from PortfolioCovid..CovidMuertes
where continent is not null
--group  by date
order by 1,2


--Cantidad de poblacion vs vacunados
select muer.continent, muer.location, muer.date, muer.population, vac.new_vaccinations,
 SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (partition by muer.location ORDER BY muer.location, muer.date) 
 as PersonasVacunadas
from PortfolioCovid..CovidMuertes as muer
join PortfolioCovid..CovidVacunas as vac
	on muer.location = vac.location
		and muer.date  = vac.date
where muer.continent is not null
order by 2,3

--USANDO CTE
with poblacionVsVacunados (continent, location,date,population,new_vaccinations,PersonasVacunadas)
as 
(
select muer.continent, muer.location, muer.date, muer.population, vac.new_vaccinations,
 SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (partition by muer.location ORDER BY muer.location, muer.date) 
 as PersonasVacunadas
from PortfolioCovid..CovidMuertes as muer
join PortfolioCovid..CovidVacunas as vac
	on muer.location = vac.location
		and muer.date  = vac.date
where muer.continent is not null
--order by 2,3
)
select *, (PersonasVacunadas / population) * 100
from poblacionVsVacunados

--Tabla temporal
DROP Table if exists #PorcentajePoblacionVacunada
create table #PorcentajePoblacionVacunada
(
	continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	PersonasVacunadas numeric
)

insert into #PorcentajePoblacionVacunada
select muer.continent, muer.location, muer.date, muer.population, vac.new_vaccinations,
 SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (partition by muer.location ORDER BY muer.location, muer.date) 
 as PersonasVacunadas
from PortfolioCovid..CovidMuertes as muer
join PortfolioCovid..CovidVacunas as vac
	on muer.location = vac.location
		and muer.date  = vac.date
--where muer.continent is not null

select *, (PersonasVacunadas / population) * 100
from #PorcentajePoblacionVacunada

--Vista 1
create view PorcentajePoblacionVacunada as
select muer.continent, muer.location, muer.date, muer.population, vac.new_vaccinations,
 SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (partition by muer.location ORDER BY muer.location, muer.date) 
 as PersonasVacunadas
from PortfolioCovid..CovidMuertes as muer
join PortfolioCovid..CovidVacunas as vac
	on muer.location = vac.location
		and muer.date  = vac.date
where muer.continent is not null
--order by 2,3