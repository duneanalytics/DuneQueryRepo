
import yaml

# Read the queries.yml file
with open('queries.yml', 'r') as file:
    data = yaml.safe_load(file)

print(data)

# Extract the query_ids from the data
query_ids = [id for id in data['query_ids']]

# Print the query_ids
print(query_ids)
