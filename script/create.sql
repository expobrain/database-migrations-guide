DROP TABLE IF EXISTS weather;
DROP TABLE IF EXISTS cities;

CREATE TABLE cities (
        name     varchar(80) primary key
);

CREATE TABLE weather (
        city      varchar(80) primary key,
        temp   int,
        date      date
);

ALTER TABLE weather
    ADD CONSTRAINT weather_name_fkey FOREIGN KEY (city) REFERENCES cities(name);

INSERT INTO cities (name) VALUES (
    concat('city' , generate_series(1, 10000000))
);

INSERT INTO weather (city, temp, date) VALUES (
    concat('city' , generate_series(1, 10000000)),
    trunc(random() * 100),
    '2022-01-01'
);
