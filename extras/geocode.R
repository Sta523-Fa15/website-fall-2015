library(httr)

# Sample Data
d = data.frame(address = "1600 Pennsylvania Ave., Washington DC", stringsAsFactors=FALSE)

d$lat = NA
d$long = NA

# Geocoding w/ Google - https://developers.google.com/maps/documentation/geocoding/

# Use google's api console - https://code.google.com/apis/console/ to get your own api key
api_key = ""
geocode_url = "https://maps.googleapis.com/maps/api/geocode/json"

for(i in 1:nrow(d))
{
    addr = d$address[i]

    url = paste0(geocode_url,
                 address=addr,
                 key=api_key)

    json = content(GET(url), as="parsed")
    stopifnot(json$status == "OK")
    stopifnot(length(json$results) == 1)

    r = json$results[[1]]

    d$lat[i]  = r$geometry$location$lat
    d$long[i] = r$geometry$location$long

    Sys.sleep(1) # Respect the API don't request too often
}


# Geocoding w/ OpenStreetMap's nominatim

geocode_url = "http://nominatim.openstreetmap.org/search.php?format=json"

d$lat = NA
d$long = NA

for(i in 1:nrow(d))
{
    addr = d$address[i]

    url = paste0(geocode_url,
                 "&q=",addr)

    s = GET(url, format="json", q=addr)
    stopifnot(s$status_code == 200)

    json = content(s, as="parsed")
    stopifnot(length(json) == 1)

    d$lat[i]  = json[[1]]$lat
    d$long[i] = json[[1]]$long

    Sys.sleep(1) # Respect the API don't request too often
}
