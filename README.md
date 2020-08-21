# Singular Value Decomposition Application on New York City Taxi and Limousine Commission

About data sets:
It's the New York City Taxi and Limousine Commission (TLC). It has a yellow taxi, green taxi, and For-Hire 
Vehicle (FHV) from 2009 – 2019. For this task, I used the green taxi trips records of the 2014 to 2018 
data set. You can access the data sets from this [Link](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page).

I created a database called tlcTaxi, which contains five tables. The names of the tables are called 
tlcTaxi2014 to tlcTaxi2018. Each table is loaded twelve months of data sets, has a primary key, 
and is an auto-increment. It's approximately 15 million rows and 22 features for each.

For the specific project on singular value decomposition (SVD), I used the data set of December 2014. I 
subset three variables: pickups latitude, pickups longitude, and pickups datetime. I'm interested in
a space-time format using SVD. It's a modern statistical methodology to extract relevant information
such as modes, variances, empirical orthogonal functions (EOFs), principal components (PCs), and 
understanding eigenvalues and eigenvectors.

The SVD provides the U matrix, which represents the spatial patterns, the corresponding temporal 
patterns is the V matrix, and the energy level D. We said SVD decomposes
$A = UDV^t$

I assigned each latitude and longitude coordinate to the bins of the grids. Also, eliminating
those points that are not in the NYC and substituting missing values with zero values. I transform
data into space-time data matrix format then applying SVD to obtain results.

The visualizations display the first three modes to show the correlation with the weekends at 
a specific hour. The GIF demonstrates the relationship on the NYC map for 24 hours of December 2014.

![](https://github.com/molokaicat/NYCTaxiSVD/blob/master/Plot_GIF/hours.gif)
