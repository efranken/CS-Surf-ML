# i strongly dislike windows environments
# this has to be a batch script

SET PGPASSWORD=postgres
psql -U postgres -a -f ml_db_init.sql