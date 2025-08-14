-- Create Table

Create table netflix (
show_id nvarchar(5),
type nvarchar(10),
title nvarchar(250),
director nvarchar(550),
casts nvarchar(1050),
country nvarchar(550),
date_added nvarchar(55),
release_year int,
rating  nvarchar (15),
duration nvarchar (15),
listed_in nvarchar (250),
description nvarchar (550));

Select * from netflix;

--1. Count the number of Movies vs TV Shows

Select type ,
count(*) as Total_Count 
from netflix group by type; 





--2. Find the most common rating for movies and TV shows
Select type , 
        rating from 
        (Select type, 
        rating ,
        count(*) as most_count ,
         rank() over (partition by type order by count(*) desc)  as rn from netflix
                 group by type, rating) as t where rn = 1;
				



--3. List all movies released in a specific year (e.g., 2020)

Select title as movie from netflix where type = 'Movie' and release_year = '2020';


--4. Find the top 5 countries with the most content on Netflix

Select count(show_id) as total_content,
         value as new_country  
         from netflix cross apply string_split(country,',') group by value
         order by count(show_id) desc;



--5. Identify the longest movie

Select title,
     duration from netflix 
      where type = 'movie' and duration = (Select max(duration) from netflix);

 


--6. Find content added in the last 5 years
SELECT 
    show_id, 
    title, 
    YEAR(date_added) AS year_added
FROM netflix
WHERE date_added >= DATEADD(YEAR, -5, GETDATE());

select * from netflix;

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

Select title, 
      type from
      netflix where director like '%Rajiv Chilaka%' ;

--8. List all TV shows with more than 5 seasons

Select title, 
       left(duration , CHARINDEX (' ',duration)-1) as seasons 
       from netflix  
       where type = 'TV Show' and left(duration , CHARINDEX (' ',duration)-1) > 5;


--9. Count the number of content items in each genre

Select count(show_id) as number_of_content_items , 
       value as genre 
       from netflix cross apply string_split(listed_in,',')
       group by value order by count(show_id) desc;

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

SELECT 
    release_year,
    COUNT(show_id) AS content_release,
    ROUND(
        COUNT(show_id) * 100.0 / 
        (SELECT COUNT(*) FROM netflix WHERE country = 'India'), 2
    ) AS average_content_percentage
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY 
    average_content_percentage DESC;


--11. List all movies that are documentaries

Select title,
       value as genre 
       from netflix cross apply string_split (listed_in,',')
       where type = 'movie'and value = 'Documentaries';

--12. Find all content without a director

Select show_id ,type ,director from netflix where director is null;


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

 Select * from netflix;

 EXEC sp_rename 'netflix.cast', 'casts', 'COLUMN';

Select * from netflix where casts like '%Salman Khan%' 
          and release_year >= year(getdate()) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

Select value as actors, count(*) as Movies
 from netflix cross apply string_split(casts,',') 
         where country = 'India' group by value order by count(*) desc;


--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.


with newtable as (
Select description,
CASE 
     WHEN      description like '%kill%' 
                      OR
              description like '%violence%' 
    THEN       'Bad Content'
    ELSE       'Good Content'
END category 
from netflix)
Select category, count(*) as occurence from newtable group by category;