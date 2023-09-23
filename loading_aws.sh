 # Visualize all available buckets
 aws s3 ls 

 # Create a new  bucket for this project
 aws s3api create-bucket --bucket de-adventurework-snowflake-raw --region eu-north-1

 # Upload the files from the data folder
 aws s3 cp data s3://de-adventurework-snowflake-raw/data/ --recursive