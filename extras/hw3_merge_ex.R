library(dplyr)
library(stringr)
library(rgdal)
library(rgeos)

base = '/home/vis/cr173/Sta523/data/parking'

park = tbl_df(read.csv(paste0(base,"/NYParkingViolations_small.csv"), stringsAsFactors=FALSE))

addr = filter(park, Violation.Precinct <= 34) %>%
       mutate(House.Number = str_trim(House.Number), Street.Name = str_trim(Street.Name)) %>%
       filter(House.Number != "" & Street.Name != "") %>%
       filter(str_detect(House.Number,"[0-9]+")) %>%
       transmute(Violation.Precinct = Violation.Precinct, addr = paste(House.Number, Street.Name)) %>%
       mutate(addr = tolower(addr))


pl = readOGR(paste0(base,"/pluto/Manhattan/"),"MNMapPLUTO")

pt = gCentroid(pl,byid=TRUE)
tax = cbind(data.frame(pt@coords), tolower(as.character(pl@data$Address)))
names(tax)[3] = "addr"

z = inner_join(addr, tax)