create database Grocerystore;

use Grocerystore;

select*from GroceryDataset;

/*menghapus kolom Currency*/
alter table GroceryDataset
drop column Currency;

/*mengganti isi kolom*/
update GroceryDataset
set Rating = 'No Reviews'
where Rating = 'Rated 0 out of 5 stars based on 0 reviews';

/*melihat jumlah null di kolom*/
select count(*) as Jumlah_Null
from GroceryDataset
where Product_Description is null;

/*mengganti nilai null*/
update GroceryDataset
set Product_Description = 'No Description'
where Product_Description is null;

/*mengubah nama kolom price*/
exec sp_rename 'GroceryDataset.Price', 'Price($)', 'COLUMN';

/*mengubah nama kolom Rating*/
exec sp_rename 'GroceryDataset.Rating', 'Reviews', 'COLUMN';

/*mengahpus $ di kolom price*/
update GroceryDataset
set [Price($)] = right([Price($)], len([Price($)])-1)
where [Price($)] like '$%';

/*melihat type data di kolom price*/
select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'GroceryDataset' AND COLUMN_NAME = 'Rating';

/*melihat jumlah null di kolom*/
select count(*) as Jumlah_Null
from GroceryDataset
where [Price($)] ='';

/*mengganti nilai null*/
update GroceryDataset
set [Price($)] = 'No Discount'
where [Price($)] = '';

/*mengubah kolom tersebut menjadi nilai float tanpa nilai desimal di depannya*/
update GroceryDataset
set [Price($)] = try_cast([Price($)] as float);

/*Menghitung Jumlah Baris dan Kolom*/
select count(*) as Jumlah_Barisan,
       count(COLUMN_NAME) AS Jumlah_Kolom
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'GroceryDataset';

/*Statistik Deskriptif untuk Kolom price*/
select
   sub_category,
   min([Price($)]) as Minimum,
   max([Price($)]) as Maksimum,
   avg(cast([Price($)] as float)) as Rata_rata,
   stdev(cast([Price($)] as float)) as Standar_Deviasi
from GroceryDataset
group by sub_category;

/*Distribusi Frekuensi*/
select sub_category, count(*) as Frekuensi
from GroceryDataset
group by sub_category
order by Frekuensi desc;

--pembuatan kolom rating
alter table GroceryDataset
add Rating varchar(20);

--mengisi nilai rating berdasarkan reviews yang diberikan
update GroceryDataset
set Rating = 
	case
	when Reviews = 'No Reviews' then 0
              when patindex('%Rated [0-9]% out%', Reviews) > 0 then
            cast(substring(Reviews, charindex('Rated ', Reviews) + len('Rated '), charindex(' out', Reviews) - charindex('Rated ', Reviews) - len('Rated ')) as float)
		end;