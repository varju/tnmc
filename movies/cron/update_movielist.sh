#!/bin/sh

# Among other things:
# - Automatically sets statusShowing to 0 for all movies
# - Finds all known movies playing in our theatres, and sets statusShowing=1
/tnmc/movies/cron/get_movies_cinemaclock.cgi

# Sets the movie's rating and description
/tnmc/movies/cron/get_movies_mybc.cgi
