CREATE DATABASE tlcTaxi;

USE tlcTaxi;

-- for 2014

CREATE TABLE tlcTaxi2014Test (
    ID                     int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    VendorID               varchar(1) NOT NULL,
    Pickup_datetime        DateTime NULL,
    Dropoff_datetime       DateTime NULL,
    Store_and_fwd_flag     varchar(1) NULL,
    RateCodeID             int NULL,
    Pickup_longitude       float NULL,
    Pickup_latitude        float NULL,
    Dropoff_longitude      float NULL,
    Dropoff_latitude       float NULL,
    Passenger_count        int NULL,
    Trip_distance          float NULL,
    Fare_amount            float NULL,
    Extra                  float NULL,
    MTA_tax                float NULL,
    Tip_amount             float NULL,
    Tolls_amount           float NULL,
    Ehail_fee              varchar(7) NULL,
    Total_amount           float NULL,
    Payment_type           int NULL,
    Trip_type              varchar(11) NULL,
    Col21                  varchar(7) NULL,
    Col22                  varchar(7) NULL
);
