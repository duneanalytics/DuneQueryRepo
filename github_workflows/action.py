print('test action hello wrld')

import yaml
from dune_client.client import DuneClient

dune = DuneClient.from_env() 

# Read the queries.yml file
with open('queries.yml', 'r') as file:
    data = yaml.safe_load(file)

# Extract the query_ids from the data
query_ids = [id for id in data['query_ids']]

for id in query_ids:
    query = dune.get_query(id)
    print(query)