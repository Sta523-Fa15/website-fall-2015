check_packages = function(names)
{
    for(name in names)
    {
        if (!(name %in% installed.packages()))
            install.package(name)
    
        library(name, character.only=TRUE)
    }
}

check_packages(c("httr","XML","stringr"))


lq_url = "http://www.lq.com"
list_url = "/en/findandbook/hotel-listings.html"

root = xmlRoot(htmlTreeParse(paste0(lq_url,list_url),
                             error=function(...){}))

links = getNodeSet(root[["body"]], "//a[contains(@href,'/en/findandbook/hotel-details')]")

d = data.frame(t(sapply(links, function(x) c(xmlValue(x), xmlAttrs(x)[["href"]]))), 
               stringsAsFactors = FALSE)

names(d) = c("name","url")

d$address = ""
d$phone = ""
d$fax = ""


for(i in 1:5)#nrow(d))
{
    cat("Downloading -", d$name[i], "...")
    hotel_root = xmlRoot(htmlTreeParse(paste0(lq_url, d$url[i]), 
                                       error=function(...){}))

    addr_cont = getNodeSet(hotel_root[["body"]], 
                           "//div[contains(@class,'propProfileContent')]")
    stopifnot(length(addr_cont) == 1)

    addr_p = addr_cont[[1]][["p"]]
    stopifnot(length(addr_p) == 8)

    d$address[i] = paste(xmlValue(addr_p[[1]]), xmlValue(addr_p[[3]]))
    d$phone[i] = str_replace(xmlValue(addr_p[[5]]),"Phone: ","")
    d$fax[i]   = str_replace(xmlValue(addr_p[[7]]),"Fax: ","")  

    w = round(runif(1,0,7),1)
    Sys.sleep(w)
    cat(" (Waiting ",w,"s)\n",sep="")
}



# Geocoding w/ Google - https://developers.google.com/maps/documentation/geocoding/

# api console - https://code.google.com/apis/console/
api_key = "AIzaSyC6d3FVQT-SSnvESDQI6ra1nbFSVvxrn3s"
geocode_url = "https://maps.googleapis.com/maps/api/geocode/json"


for(i in 1:5)#nrow(d))
{
    addr = d$address[i]

    url = paste0(geocode_url,
                 "?address=",str_replace_all(addr," ","+"),
                 "&key=",api_key)

    json = content(GET(url), as="parsed")
    stopifnot(json$status == "OK")
    stopifnot(length(json$results) == 1)

    r = json$results[[1]]

    d$lat[i]  = r$geometry$location$lat
    d$long[i] = r$geometry$location$long
}
