# space_time_data_matrix.jl
"""
Step 1: Import data for the month of December 2014.
Step 2: Create a squared grid that contains New York City's pickup latitude and longitude coordinates.
Step 3: A function that assigns latitude and longitude coordinates to the grid.
Step 4: Assigns the coordinates to each bin of the grid.
Step 5: Compute the bin frequency for each space-time location.
Step 6: Transforms the information to space-time format.
"""

using JuliaDB, JuliaDBMeta, Dates, IndexedTables, CSV, DelimitedFiles

import DataFrames

# Load data of December 2014
green_trip = loadtable("green_tripdata_2014-12.csv", header_exists=true);  # (1)

length(rows(green_trip))
length(columns(green_trip))

# There are total 22 features, but I only show relevant features for this project.
colnames(green_trip)[[2, 6, 7]]

# Pick 2 points on the Google maps
LAT1 = 40.916169;
LAT2 = 40.474422;
latdel = LAT1 - LAT2;
LON2 = -74.259254;
LON1 = -74.259254 + latdel;
N = 100;

lon_grid = range(LON2, LON1, length=N)
lat_grid = range(LAT2, LAT1, length=N)

# Create an approximate squared grid of New York City.     # (2)
green_trip_sq = filter(i -> (i.Pickup_longitude > LON2 && i.Pickup_longitude < LON1) &&
       (i.Pickup_latitude > LAT2 && i.Pickup_latitude < LAT1), green_trip);

length(rows(green_trip_sq))
length(columns(green_trip_sq))

# Got rid of 24,280 coordinates that are not in New York City. It might belong to different states.
length(rows(green_trip)) - length(rows(green_trip_sq))

# A function that assigns latitude and longitude coordinates to the grid.   # (3)
function coor_indx(lon, lat)
    for i in 1:N-1
        for j in 1:N-1
            if lat_grid[i] < lat < lat_grid[i + 1] &&
                lon_grid[j] < lon < lon_grid[j + 1]
                # latitude i longitude j
                return i, j
            end
        end
    end
end

# Extract Date and hour
pickup_lonlat = @apply green_trip_sq begin
    @select (:lpep_pickup_datetime, Dates.Date(:lpep_pickup_datetime),
             Dates.hour(:lpep_pickup_datetime),
             :Pickup_longitude, :Pickup_latitude)
end

# Rename the column variables for easy access.
pickup_lonlat = table(columns(pickup_lonlat)...,
                      names=[:pickup_dt, :date, :hour, :pickup_lon, :pickup_lat]);

colnames(pickup_lonlat)

first(pickup_lonlat)

# Converts latitude and longitude coordinates to grid indexes.    # (4)
@time for i in 1:length(pickup_lonlat)
    y, x = coor_indx(pickup_lonlat.columns.pickup_lon[i], pickup_lonlat.columns.pickup_lat[i])
    global pickup_lonlat.columns.pickup_lat[i] = y
    global pickup_lonlat.columns.pickup_lon[i] = x
end

tbdh = @select pickup_lonlat (:date, :hour, :pickup_lat, :pickup_lon);

# Convert i,j indexes in the grid from float64 to Int64
tbdh = IndexedTables.transform(tbdh, :pickup_lat => map(x -> convert(Int, x), tbdh.columns.pickup_lat));
tbdh = IndexedTables.transform(tbdh, :pickup_lon => map(x -> convert(Int, x), tbdh.columns.pickup_lon));
tbdh = @select tbdh (:date, :hour, :pickup_lat, :pickup_lon);

# Obtain the frequency of each space-time location.    # (5)
tbdh = JuliaDB.groupby(length, tbdh, (:date, :hour, :pickup_lat, :pickup_lon);
                     select = (:date, :hour, :pickup_lat, :pickup_lon));
length(rows(tbdh))
length(columns(tbdh))

# Concatenate date and hour variables.
date_hour = map(i -> "D" * (replace(string.(i.date), "-" => "_")) * "H" * string.(i.hour), tbdh);
t = IndexedTables.insertcolsbefore(tbdh, :length, date_hour => date_hour);
t = table(columns(t)..., names=(:date, :hour, :pickup_lat, :pickup_lon, :date_hour, :length));
t = @select t (:pickup_lat, :date_hour, :length, :pickup_lon);

# Transform back to latitude & longitude coordinates.
t = IndexedTables.transform(t, :pickup_lat => [lat_grid[i] for i in first.(t)]);
t = IndexedTables.transform(t, :pickup_lon => [lon_grid[j] for j in last.(t)]);
t = @select t (:pickup_lat, :pickup_lon, :date_hour, :length);

# Transforms the information to space-time format.    # (6)
@time t = JuliaDB.unstack(t, (:pickup_lat, :pickup_lon); variable=:date_hour, value=:length);

df = t |> DataFrames.DataFrame;

# Replace missing values with 0 for space-time data.
@time for i in 3:746
    global df[:,i] = replace(df[:,i], missing => 0)
end
