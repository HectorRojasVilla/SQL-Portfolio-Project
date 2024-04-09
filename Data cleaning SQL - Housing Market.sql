select * from nashville_housing1

-- Populate prperty address data --

select * from nashville_housing1
--where propertyaddress is null 
order by parcelid 

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress, coalesce (a.propertyaddress,b.propertyaddress)
from nashville_housing1 a
inner join nashville_housing1 b 
on a.parcelid = b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null

-- Breaking address into individual columns 

select propertyaddress from nashville_housing1
--where propertyaddress is null 
--order by parcelid 

select 
substring (propertyaddress,1, position(','IN propertyaddress)-1) as Direccion,
substring (propertyaddress, position(','IN propertyaddress)+1, length(propertyaddress)) as Direccion

from nashville_housing1

alter table nashville_housing1
add propertySplitAddress varchar (230);

update nashville_housing1
set propertySplitAddress = substring (propertyaddress,1, position(','IN propertyaddress)-1)

alter table nashville_housing1
add propertySplitCity varchar (230);

update nashville_housing1
set propertySplitCity = substring (propertyaddress, position(','IN propertyaddress)+1, length(propertyaddress))

select * 
from nashville_housing1


-- Now we break the owners address with a diferent aproach 

select 
split_part (owneraddress,',',1) direcion
,split_part (owneraddress,',',2) city
,split_part (owneraddress,',',3) state
from nashville_housing1

alter table nashville_housing1
add OwnerSplitAddress varchar (230);

update nashville_housing1
set OwnerSplitAddress = split_part (owneraddress,',',1)

alter table nashville_housing1
add OwnerSplitCity varchar (230);

update nashville_housing1
set OwnerSplitCity = split_part (owneraddress,',',2)

alter table nashville_housing1
add OwnerSplitState varchar (230);

update nashville_housing1
set OwnerSplitState = split_part (owneraddress,',',3)

-- checking that everything workout 
select * 
from nashville_housing1

-----------------------------------------------------------------------------

-- Change False or True in "sold as vacant "

select distinct (soldasvacant), count (soldasvacant)
from nashville_housing1
group by soldasvacant
order by 2

select soldasvacant,
case 
when soldasvacant = 'true' then 'yes'
when soldasvacant = 'false' then 'no'
else soldasvacant
end
from nashville_housing1
-- uptade the column with the new type of data
update nashville_housing1
SET soldasvacant = case 
when soldasvacant = 'true' then 'yes'
when soldasvacant = 'false' then 'no'
else soldasvacant
end
-- we need to change the Data type from boolean to varchar 
alter table nashville_housing1
alter column soldasvacant type varchar (230) 

select * from nashville_housing1


---------------------------------------------------------

-- Remove duplicates --
-- With se next subquery and the partition by we can identify all the columns that 
-- have duplicate data 
with rownumcte as (
select *,
row_number() over (
partition by parcelid,
	propertyaddress,
	saleprice,
	saledate,
	legalreference
	order by uniqueid
) row_nums
from nashville_housing1
--delete from nashville_housing1
--where row_nums = '2'
--order by parcelid
	)
select *  from rownumcte
where row_nums > 1
order by propertyaddress

-- we use de DELETE statment with subquery to delete all the duplicate 


DELETE FROM nashville_housing1
WHERE parcelid IN
    (SELECT parcelid
    FROM 
        (SELECT parcelid,
         ROW_NUMBER() OVER( PARTITION BY propertyaddress,
	saleprice,
	saledate,
	legalreference
        ORDER BY  parcelid ) AS row_num
        FROM nashville_housing1 ) t
        WHERE t.row_num > 1 );
-- we check that everything are ok in the Database 

select * from nashville_housing1

-------------------------------------------------------------------------

-- Delete unuse columns -- 

select * from nashville_housing1
where ownername is not null

-- we use the next drop statement in order to eliminate all de columns that 
-- we want, because we alredy have the same info in other columns but splited 

Alter table nashville_housing1 
drop column owneraddress,
drop column taxdistrict,
drop column propertyaddress

