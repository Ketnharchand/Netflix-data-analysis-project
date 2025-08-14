## Overview
This project involved solving 15 SQL queries on Netflix data to analyze content trends, genre popularity, rating patterns, and country-wise distribution. By leveraging joins, filters, and aggregate functions, I uncovered key insights into viewer behavior and production strategies. It reflects my ability to apply SQL for real-world data analysis

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
Select type ,
count(*) as Total_Count 
from netflix group by type; 

```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
Select type , 
        rating from 
        (Select type, 
        rating ,
        count(*) as most_count ,
         rank() over (partition by type order by count(*) desc)  as rn from netflix
                 group by type, rating) as t where rn = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
Select title as movie from netflix where type = 'Movie' and release_year = '2020';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
Select count(show_id) as total_content,
         value as new_country  
         from netflix cross apply string_split(country,',') group by value
         order by count(show_id) desc;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql

Select title,
     duration from netflix 
      where type = 'movie' and duration = (Select max(duration) from netflix);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
    show_id, 
    title, 
    YEAR(date_added) AS year_added
FROM netflix
WHERE date_added >= DATEADD(YEAR, -5, GETDATE());

select * from netflix;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
Select title, 
      type from
      netflix where director like '%Rajiv Chilaka%' ;
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
Select count(show_id) as number_of_content_items , 
       value as genre 
       from netflix cross apply string_split(listed_in,',')
       group by value order by count(show_id) desc;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
Select title,
       value as genre 
       from netflix cross apply string_split (listed_in,',')
       where type = 'movie'and value = 'Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
Select show_id ,type ,director from netflix where director is null;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
Select * from netflix 
         where casts like '%Salman Khan%' 
          and release_year >= year(getdate()) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
Select value as actors, count(*) as Movies
 from netflix cross apply string_split(casts,',') 
         where country = 'India' group by value order by count(*) desc;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

