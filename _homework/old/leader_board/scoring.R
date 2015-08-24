suppressMessages(library(rgdal))
suppressMessages(library(rgeos))
suppressMessages(library(knitr))

pp = readOGR(path.expand("/home/vis/cr173/Sta523/data/nypp/"), "nypp", stringsAsFactors=FALSE)
pp = pp[pp@data$Precinct <= 34,]

pp = spTransform(pp, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))



res = rep(0, 8)

for(i in 1:8)
{
    #if (i %in% c(3))
    #{
    #    res[i] = Inf
    #    next
    #}

    d = readOGR(paste0("data/team",i,".json"), "OGRGeoJSON", verbose=FALSE, stringsAsFactors=FALSE)
    names(d) = tolower(names(d))

    if ("violation.precinct" %in% names(d))
      names(d) = "precinct"

    d$precinct = as.integer(round(as.numeric(d$precinct)))

    for(p in pp$Precinct)
    {
        true = pp[pp$Precinct == p,]
        if (p %in% d$precinct)
        {
            pred = d[d$precinct == p,]
            res[i] = res[i] + gArea(gSymdifference(pred,true))

        } else { 
            cat("Team", i, "missing Precinct", p, "!\n")
            res[i] = res[i] + gArea(true)
        }
    }   
}

Place = c("1st","2nd","3rd","4th","5th","6th","7th","8th")

lb = data.frame( Team = paste("Team",1:8), Score = round(res * 1e8), stringsAsFactors=FALSE)

lb = cbind(Place,lb[order(lb$Score),])
rownames(lb) = NULL


header = c("---",
           "layout: page",
           "title: Leader Board - HW 3",
           "---",
           "\n")

table = c(kable(lb, output=FALSE, align=rep('l',3)), '{: class="table table-striped"}')

update = c("",
           paste("Last updated:", Sys.time()),
           "",
           "")

write(header, "index.md")
write(table,  "index.md", append=TRUE)
write(update,  "index.md", append=TRUE)
