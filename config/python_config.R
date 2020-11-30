# This script sets the python virtual environment which will
# be used to source the python script that downloads the
# relevant google sheet(s) containing the data for the 
# translation dictionaries

Sys.setenv(LD_LIBRARY_PATH = "~/Desktop/Projects/crypt/cryptmatter/lib/python3.7/site-packages/")
Sys.getenv("LD_LIBRARY_PATH")
use_virtualenv('~/Desktop/Projects/crypt/cryptmatter',required = TRUE)

py_config() #to check if its using the right python virtual environment