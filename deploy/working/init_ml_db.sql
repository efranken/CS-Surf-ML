CREATE DATABASE ml;

\c ml

CREATE TABLE IF NOT EXISTS playerloc (
    id         SMALLINT     NOT NULL,
    x          SMALLINT     NOT NULL,
    y          SMALLINT     NOT NULL,
    z          SMALLINT     NOT NULL,
    angle      SMALLINT     NOT NULL,
    speed      SMALLINT     NOT NULL,
    ticknum    INT          NOT NULL,
    writenum   INT          NOT NULL,
    episode    INT          NOT NULL
);

-- Add indexes to the table
CREATE INDEX idx_id ON playerloc (id);
CREATE INDEX idx_writenum ON playerloc (writenum);

-- Show tables and rows of playerloc for sanity check
\dt
\d+ playerloc