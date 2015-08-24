file = commandArgs(trailingOnly = TRUE)[1]

suppressMessages(library(rgdal))
suppressMessages(library(rgeos))
suppressMessages(library(knitr))

cat("Load truth ...\n")

pp = readOGR(path.expand("/home/vis/cr173/Sta523/data/nypp/"), "nypp", stringsAsFactors=FALSE, verbose=FALSE)
pp = pp[pp@data$Precinct <= 34,]

pp = spTransform(pp, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))


cat("Load",file,"...\n")


d = readOGR(file, "OGRGeoJSON", verbose=FALSE, stringsAsFactors=FALSE)
names(d) = tolower(names(d))

if ("violation.precinct" %in% names(d))
  names(d) = "precinct"

d$precinct = as.integer(round(as.numeric(d$precinct)))


res = 0

for(p in pp$Precinct)
{
    true = pp[pp$Precinct == p,]
    if (p %in% d$precinct)
    {
        pred = d[d$precinct == p,]
        res = res + gArea(gSymdifference(pred,true))

    } else { 
        cat("Missing Precinct", p, "!\n")
        res = res + gArea(true)
    }
}

cat("Score: ",round(res * 1e8),"\n")