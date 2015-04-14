
# Get comparable html data
ht <- htmlTreeParse("http://www.zillow.com/homes/comps/81715527_zpid/")
# Store root node
htroot <- xmlRoot(ht)

# Find div class = 'comps-price-graph-home_placeholder', extract 'data-price'
comparables <- as.numeric(xpathSApply(htroot,"//div[@class='comps-price-graph-home_placeholder']", xmlGetAttr, "data-price"))


