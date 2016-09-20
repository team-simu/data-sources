setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(readr)

# zip code with lat and long from https://gist.github.com/erichurst/7882666 
zip_coords <- read_delim('./data-sources/zipcode_lat_long.txt', delim =  ',')
zip_coords$LNG <- as.numeric(zip_coords$LNG)

# 3-digit prefix from http://pe.usps.com/Archive/HTML/DMMArchive20050106/print/L002.htm
zip_states <- read_delim('./data-sources/zipcode_prefix.txt', delim =  '\n', skip = 26)
colnames(zip_states) <- 'zip_str'
zip_states <- zip_states[!grepl('^[0-9]{3}.*', zip_states$zip_str) &
                           grepl('[0-9]{3}', zip_states$zip_str) & 
                           !grepl('SCF', zip_states$zip_str), ]
zip_states <- zip_states[!duplicated(zip_states),]

zip_states$zip_prefix <- unlist(sapply(1:nrow(zip_states), simplify = T, function(zip_index) {
  regmatches(zip_states[zip_index,1], regexpr('[0-9]{3}', zip_states[zip_index,1], perl=TRUE))
}))

zip_states$state_abb <- unlist(sapply(1:nrow(zip_states), function(zip_index) {
  gsub(' ',
      '',
       regmatches(zip_states[zip_index,1], regexpr(' [A-Z]{2} ', zip_states[zip_index, 1], perl=TRUE))
  )
}))


zip_states$city <- unlist(sapply(1:nrow(zip_states), function(zip_index) {
     regmatches(zip_states[zip_index,1], regexpr('.+?(?= [A-Z]{2} )', zip_states[zip_index, 1], perl=TRUE))
}))

zip_states_unique <- zip_states[!duplicated(paste(zip_states$zip_prefix, zip_states$city)),]
zip_states_unique$state_full <- tolower(state.name[match(zip_states_unique$state_abb, state.abb)])

zip_combined <- cbind(zip_coords, zip_states[match(substr(zip_coords$ZIP, 1, 3), zip_states$zip_prefix), ])

write_csv(zip_combined[, c(1:3,5:7)], './data-sources/zipcode_info_table.csv', na = 'NA')
