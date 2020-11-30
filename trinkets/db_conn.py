"""
This script loads the database parameters and then connects to the database to execute the query
"""

import psycopg2
import logging
import yaml
import os


roots = os.path.realpath(os.path.dirname(os.getcwd()))
path = r'/config'
root_path = roots + path
if not os.path.exists(root_path):
    logging.info('Creating path')
    os.makedirs(root_path)
else:
    if os.path.exists(root_path + r'/database.yaml'):
        logging.info('File exists')
    else:
        logging.info('Creating file. Please fill in details')
        open(root_path + r'/database.yaml', 'w')


def executeQuery(query):
    with open(root_path + r'/database.yaml') as file:
        # The FullLoader parameter handles the conversion from YAML
        # scalar values to Python the dictionary format
        db_list = yaml.load(file, Loader=yaml.FullLoader)
    try:
        conn = psycopg2.connect(user=db_list['user'],
                                password=db_list['password'],
                                host=db_list['host'],
                                port=db_list['port'],
                                database=db_list['database'])
        logging.info('Connection established')
        cursor = conn.cursor()
        cursor.execute(query)
        results = cursor.fetchall()
        logging.info('Query executed')
    except (Exception, psycopg2.Error) as err:
        logging.error(err)
    else:
        cursor.close()
        conn.close()
        logging.info("PostgreSQL connection is closed")
        return results



