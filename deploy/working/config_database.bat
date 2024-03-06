# i strongly dislike windows environments
# this has to be a batch script

SET PGPASSWORD=postgres
psql -U postgres -a -f init_ml_db.sql