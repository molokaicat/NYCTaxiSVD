# Plot the contours on the NYC map using space-time data matrix.
library(pacman)
p_load(tidyverse, matrixStats, ggmap, yaml)

dec_space_time <- read.csv("dec_space_time.csv", header = FALSE)

h <- c()
for (i in 1:24) {
    h <- c(h, seq(i, 744, 24))
    hour <- matrix(h, nrow = 31)  # 31x24
}

dh19 <- dec_space_time[, 3:746]

for (i in 1:24) {
    gh19 <- dh19[, hour[, i]]
    freMh19 <- rowMeans(gh19)
    fresdh19 <- rowSds(matrix(unlist(gh19), ncol = 31, byrow = FALSE))
    
    # Standardized anomalies
    anomh19 <- c()
    for (j in 1:31) {
        anomh19 <- cbind(anomh19, ifelse(fresdh19 == 0, 0, (gh19[, j] - freMh19)/fresdh19))
    }
    
    # Area weighted anomalies
    anomh19AW <- sqrt(cos(dec_space_time[, 1] * pi/180)) * anomh19
    
    # Obtain SVD
    svdh19 <- svd(anomh19AW)
    
    nyc_map <- get_map(location = "New York", zoom = 10)
    
    modemat <- matrix(svdh19$u[, 1]/sqrt(cos(dec_space_time[, 1] * pi/180)), nrow = 99)
    modemat_df <- data.frame(lat = dec_space_time$V1, lon = dec_space_time$V2, mat = matrix(modemat, ncol = 1, byrow = FALSE))
    modemat_df <- modemat_df %>% filter(lat > 40.502559 & lon > -74.109903)
    
    if (sum(modemat_df$mat > 0) < sum(modemat_df$mat < 0)) {
        modemat_df$mat = -modemat_df$mat
    }
    
    png(paste("Mode1_", toString(i), ".png", sep = ""), width = 7, height = 5, units = "in", res = 200)
    print(ggmap(nyc_map, extent = "device") + stat_contour(data = modemat_df, aes(x = lon, y = lat, z = mat, fill = ..level.., alpha = ..level..), geom = "polygon") + scale_fill_gradient(name = paste("hour ", 
        i, sep = ""), low = "blue", high = "green", limits = c(-0.06, 0.06)) + labs(title = "\nNYC Green Taxi Pickups Locations for 12-2014", subtitle = "The first mode of the SVD", 
        caption = "The bright green areas are coorelated to the weekends for that hour\n") + guides(alpha = FALSE))
    dev.off()
}
