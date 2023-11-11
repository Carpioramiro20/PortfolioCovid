--Poner en uso la base de datos
USE [ProyectoPortfolio];

--Consulta de todos los datos
SELECT * 
FROM ProyectoPortfolio.dbo.ViviendasNashville;

--Inconsistencia en el campo SaleDate, en la consulta podemos verificar
SELECT SaleDate, CONVERT(date, SaleDate)
FROM ProyectoPortfolio.dbo.ViviendasNashville;

--Al ejecutar la actualizacion se llevo con exito por lo 
-- que a continuacion se procede a crear un campo auxiliar para almacenar 
-- los datos en ese campo y poder ejecutar el cambio de tipo de dato
UPDATE ViviendasNashville
SET SaleDate = CONVERT(date, SaleDate);

--Consulta para verificar que el cambio no fue realizado exitosamente
SELECT SaleDates
FROM ProyectoPortfolio.dbo.ViviendasNashville;

--Crear campo auxiliar
ALTER TABLE ViviendasNashville
ADD SaleDates Date ;

--almacenar datos 
UPDATE ViviendasNashville
SET SaleDates = CONVERT(date, SaleDate);


--consulta para verificar los registros nulos del campo PropertyAddress
SELECT *
FROM ProyectoPortfolio.dbo.ViviendasNashville
WHERE PropertyAddress IS NULL;

--Se interpetra que podemos rellenar los registros nulos 
-- gracias a la coincidencia en algunos registros
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)  
FROM ProyectoPortfolio.dbo.ViviendasNashville A
JOIN ProyectoPortfolio.dbo.ViviendasNashville B
ON A.ParcelID = B.ParcelID 
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- Se procede a actualizar los registros nulos
UPDATE A
SET  PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM ProyectoPortfolio.dbo.ViviendasNashville A
JOIN ProyectoPortfolio.dbo.ViviendasNashville B
ON A.ParcelID = B.ParcelID 
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--Consulta para verificar los cambios realizados
SELECT PropertyAddress
FROM ProyectoPortfolio.dbo.ViviendasNashville;

--Consulta para verificar que el campo PropertyAddress 
--Contiene la ciudad por lo que se procedera a colocar dichos datos 
-- en otro campo
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM ProyectoPortfolio.dbo.ViviendasNashville

/*
Crear campo PropertyAuxCity para poder almacenar alli los
 datos de las ciudades
*/
ALTER TABLE ViviendasNashville
ADD PropertyAuxCity Nvarchar(255);

/*
Crear campo PropertyAuxAddress para poder almacenar alli los
 datos de las direcciones de los propietarios
*/
ALTER TABLE ViviendasNashville
ADD PropertyAuxAddress Nvarchar(255);

--Actualizar dichos campos utilizando funciones integradas
UPDATE ViviendasNashville
SET PropertyAuxCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

UPDATE ViviendasNashville
SET PropertyAuxAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

--Consulta para verificar los datos
SELECT *
FROM ProyectoPortfolio.dbo.ViviendasNashville;

/*
Inconsistencia de datos nuevamente pero
en el campo OwnerAddress
*/
SELECT OwnerAddress
FROM ProyectoPortfolio.dbo.ViviendasNashville;

/*
Se realiza la consulta para verificar como deberia 
quedar los campos
*/
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM ProyectoPortfolio.dbo.ViviendasNashville;


--Crear campo auxiliar OwnerAuxCity
ALTER TABLE ViviendasNashville
ADD OwnerAuxCity Nvarchar(255);

--Crear campo auxiliar OwnerAuxAddress
ALTER TABLE ViviendasNashville
ADD OwnerAuxAddress Nvarchar(255);

--Crear campo auxiliar OwnerAuxState
ALTER TABLE ViviendasNashville
ADD OwnerAuxState Nvarchar(255);

--Actualizar datos usando la funcion PARSENAME()
UPDATE ViviendasNashville
SET OwnerAuxCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

UPDATE ViviendasNashville
SET OwnerAuxAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

UPDATE ViviendasNashville
SET OwnerAuxState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

--Consulta para verificar los datos actualizados
SELECT *
FROM ProyectoPortfolio.dbo.ViviendasNashville;

--Normalizado de datos
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM ProyectoPortfolio.dbo.ViviendasNashville
GROUP BY SoldAsVacant
ORDER BY 2;

--De esta manera deberian quedar los datos
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM ProyectoPortfolio.dbo.ViviendasNashville

--Se procede a actualizar los datos
UPDATE ViviendasNashville 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END



--Ver duplicados	
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM ProyectoPortfolio.dbo.ViviendasNashville
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

--Eliminacion de duplicados
 WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM ProyectoPortfolio.dbo.ViviendasNashville
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;


SELECT * 
FROM ProyectoPortfolio.dbo.ViviendasNashville;

--Eliminacion de columnas en desuso
ALTER TABLE ViviendasNashville
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress; 

ALTER TABLE ViviendasNashville
DROP COLUMN SaleDate; 
