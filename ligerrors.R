# This is a script to find Ligations that need to be re-done due to lab error


# Connect to database
library(RMySQL)
labor <- dbConnect(MySQL(), host="amphiprion.deenr.rutgers.edu", user="michelles", password="larvae168", dbname="Laboratory", port=3306)
