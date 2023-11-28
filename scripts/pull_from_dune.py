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
        # Update existing file
        with open(file_path, 'r+', encoding='utf-8') as file:   
            #if "query repo:" is in the file, then don't add the text header again
            if '-- already part of a query repo' in query.sql:
                file.write(query.sql)
            else:
                file.write(f'-- already part of a query repo\n --query name: {query.base.name}\n-- query link: https://dune.com/queries/{query.base.query_id}\n\n\n{query.sql}')
    else:
        # Create new file and directories if they don't exist
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(f'-- already part of a query repo\n --query name: {query.base.name}\n-- query link: https://dune.com/queries/{query.base.query_id}\n\n\n{query.sql}')
            

