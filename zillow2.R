library(xlsx)
library(RCurl)
library(XML)

# Make API request to Zillow

# Store your address here

addy <- readline(prompt="Enter Street Address: ")
# Example:  "3406 Halliday Ave"

# Store your City, State (2-letter code), Zip here:
# Example:  "Saint Louis, MO 63118"
csz <- readline(prompt="Enter the City, State (2-letter code), Zip: ")

# Store your zws-id (API account) here:
zws_id <- ""


reply = getForm("http://www.zillow.com/webservice/GetSearchResults.htm",
                'zws-id' = zws_id,
                address = addy,
                citystatezip = csz)

# Parse XML
doc <- xmlTreeParse(reply, useInternal=T)
# Save Zestimate value
zest <- as.numeric(xmlValue(doc[["//zestimate/amount"]]))

# Get url to comparables
url_comp <- xpathSApply(doc, "//comparables", xmlValue)

# Extract prices of comparables
# Get comparable html data
ht <- htmlTreeParse(url_comp, useInternal=T)
# Store root node
htroot <- xmlRoot(ht)

# Find div class = 'comps-price-graph-home_placeholder', extract 'data-price'
comparables <- as.numeric(xpathSApply(htroot,
    "//div[@class='comps-price-graph-home_placeholder']", 
    xmlGetAttr, 
    "data-price"))

boxplot(comparables, zest)

# Load workbook & sheet
wb <- loadWorkbook("zestimate.xlsx")
sheets <- getSheets(wb)
sheet1 <- sheets[[1]]

# Find number of data entries in the workbook
data<-readColumns(sheet=sheet1, startColumn=2,
    endColumn=2, startRow=1, header=T)
num_rows <- nrow(data)

# Add the new data
addDataFrame(zest, sheet1, col.names=F, row.names=F, 
    startRow=2+num_rows, startColumn = 2)

# Save the book
saveWorkbook(wb, "zestimate.xlsx")