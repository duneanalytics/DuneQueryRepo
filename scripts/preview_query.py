import os
from dune_client.client import DuneClient
from dotenv import load_dotenv
import sys
import pandas as pd

dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(dotenv_path)

dune = DuneClient.from_env()

#get id passed in python script invoke
id = sys.argv[1]

queries_path = os.path.join(os.path.dirname(__file__), '..', 'queries')
files = os.listdir(queries_path)
found_files = [file for file in files if str(id) == file.split('___')[-1].split('.')[0]]

if len(found_files) != 0:
    query_file = os.path.join(os.path.dirname(__file__), '..', 'queries', found_files[0])

    print('getting 20 line preview for query {}...'.format(id))

    with open(query_file, 'r', encoding='utf-8') as file:
        query_text = file.read()

    print('select * from (\n' + query_text + '\n) limit 20')

    results = dune.run_sql('select * from (\n' + query_text + '\n) limit 20')
    # print(results.result.rows)
    results = pd.DataFrame(data=results.result.rows)
    print('\n')
    print(results)
    print('\n')
    print(results.describe())
    print('\n')
    print(results.info())
else:
    print('query id file not found, try again')
