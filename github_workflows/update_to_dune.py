import os
import yaml
from dune_client.client import DuneClient
from dotenv import load_dotenv
import sys
import codecs

# Set the default encoding to UTF-8
sys.stdout = codecs.getwriter("utf-8")(sys.stdout.detach())

dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(dotenv_path)

dune = DuneClient.from_env()

# Read the queries.yml file
with open('queries.yml', 'r', encoding='utf-8') as file:
    data = yaml.safe_load(file)

# Extract the query_ids from the data
query_ids = [id for id in data['query_ids']]

for id in query_ids:
    query = dune.get_query(id)
    print('updating query {}, {}'.format(query.base.query_id, query.base.name))

    # Check if file exists
    file_path = os.path.join(os.path.dirname(__file__), '..', 'queries', f'query_{query.base.query_id}.sql')
    if os.path.exists(file_path):
        # Read the content of the file
        with open(file_path, 'r', encoding='utf-8') as file:
            text = file.read()

        # Update existing file
        dune.update_query(
            query_id, 
            # All parameters below are optional
            query_sql=text,
        )
        
    else:
        print('file not found, {}'.format(query_{query.base.query_id}.sql))
