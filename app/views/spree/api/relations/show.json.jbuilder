json.(@relation, *Spree::Relation.column_names)
# if above fails, try the next line
# json.extract! @relation, *Spree::Relation.column_names