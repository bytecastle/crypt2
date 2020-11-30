"""
This script fetches data updated in the google sheets and downloads it as a csv to 'crypt/data' and then copies the
data to the database.
Before connecting to google sheets you need to set up a project through the google developers console and then create a
service account then ask for crendentials for google sheets and google drive as a .json file which you then store in
'crypt/config' as 'client_secret.json'.
"""

from sqlalchemy import create_engine
from exitstatus import ExitStatus
from datetime import datetime
import pygsheets as pyg
import pandas as pd
import logging
import yaml
import sys
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

with open(root_path + r'/database.yaml') as file:
    """The FullLoader parameter handles the conversion from YAML
    scalar values to Python the dictionary format"""
    db_list = yaml.load(file, Loader=yaml.FullLoader)


def get_crypt_data_2df():
    # connection to google sheets
    gs_connection = pyg.authorize(service_file=root_path + r'/client_secret.json')
    # connect to the specific google sheet: in this case cryptdata
    main_sheet = gs_connection.open('cryptdata')
    # select the worksheets you want from the sheet cryptdata
    wk1 = main_sheet.worksheet_by_title('dplyr_dict')
    wk2 = main_sheet.worksheet_by_title('datatable_dict')
    wk3 = main_sheet.worksheet_by_title('numpy_dict')
    wk4 = main_sheet.worksheet_by_title('pandas_dict')
    wk5 = main_sheet.worksheet_by_title('postgres_dict')
    # create a pandas df and export as CSV
    crypt_data = pd.DataFrame()
    for wk in [wk1, wk2, wk3, wk4, wk5]:
        df = pd.DataFrame(wk.get_all_records())
        crypt_data = crypt_data.append(df, ignore_index=True)
    # This is to maintain a history of cryptdata. May not be needed in the future
    crypt_data.to_csv(roots + r'/data/cryptdata_{0}.csv'.format(datetime.now().strftime('%y-%m-%d')))
    # This will be copied to the app folder and is used by the app to run.
    # Maybe the date wont be required in the future
    crypt_data.to_csv(roots + r'/app/cryptdata_{0}.csv'.format(datetime.now().strftime('%y-%m-%d')), index=False)
    logging.info('Created CSV')
    return crypt_data


def main(arg):
    # ----------- setup logger ---------- #
    #files = os.path.join(logs, 'fetch_cryptdata_{}.log'.format(datetime.now().strftime('%y-%m-%d')))
    #setup_logger(files)
    #logging.info('***** Running Fetch Crypt Data Log Report *****\n')
    #logging.debug(arg)
    try:
        crypt_data = get_crypt_data_2df()
        #print(crypt_data)
        engine = create_engine('postgresql://{0}:{1}@{2}:{3}/{4}'.format(db_list['user'],
                                                                         db_list['password'],
                                                                         db_list['host'],
                                                                         db_list['port'],
                                                                         db_list['database']))
        crypt_data.to_sql(name='cryptdata', con=engine, if_exists='replace', index=False)
    except Exception as err:
        logging.error(err)
        logging.error('Error while updating database')
        return sys.exit(ExitStatus.failure)
    else:
        logging.info('Ran successfully')
        return sys.exit(ExitStatus.success)


if __name__ == '__main__':
    args = sys.argv
    main(args)
