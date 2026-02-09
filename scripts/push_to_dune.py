import codecs
import os
import sys

import yaml
from dotenv import load_dotenv
from dune_client.client import DuneClient

# Set the default encoding to UTF-8
sys.stdout = codecs.getwriter("utf-8")(sys.stdout.detach())


def is_truthy(value):
    return str(value).strip().lower() in {"1", "true", "yes", "y", "on"}


def extract_query_id_from_filename(file_name):
    if not file_name.endswith(".sql") or "___" not in file_name:
        return None

    query_id_text = file_name.rsplit("___", 1)[-1].rsplit(".", 1)[0]
    if not query_id_text.isdigit():
        return None

    return int(query_id_text)


def parse_changed_query_ids(changed_query_files_raw):
    if not changed_query_files_raw:
        return set()

    query_ids = set()
    for rel_path in changed_query_files_raw.split(","):
        rel_path = rel_path.strip()
        if not rel_path:
            continue

        query_id = extract_query_id_from_filename(os.path.basename(rel_path))
        if query_id is None:
            print(f'WARNING: could not parse query id from changed file "{rel_path}"')
            continue

        query_ids.add(query_id)

    return query_ids


dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(dotenv_path)

dune = DuneClient.from_env()

# Read the queries.yml file
queries_yml = os.path.join(os.path.dirname(__file__), '..', 'queries.yml')
with open(queries_yml, 'r', encoding='utf-8') as file:
    data = yaml.safe_load(file) or {}

# Extract the query_ids from the data
query_ids = []
for query_id in data.get('query_ids', []):
    try:
        query_ids.append(int(query_id))
    except (TypeError, ValueError):
        print(f'WARNING: skipping non-numeric query id in queries.yml: "{query_id}"')

if len(query_ids) == 0:
    print('INFO: no query_ids configured in queries.yml')
    sys.exit(0)

full_sync_requested = is_truthy(os.getenv('FULL_SYNC', 'false'))
changed_query_files_raw = os.getenv('CHANGED_QUERY_FILES', '').strip()
changed_query_ids = parse_changed_query_ids(changed_query_files_raw)

if full_sync_requested:
    target_query_ids = query_ids
    print('SYNC MODE: full (FULL_SYNC=true)')
elif len(changed_query_ids) != 0:
    tracked_query_ids = set(query_ids)
    untracked_changed_ids = sorted(changed_query_ids - tracked_query_ids)
    if len(untracked_changed_ids) != 0:
        print(f'WARNING: changed files include query ids not present in queries.yml: {untracked_changed_ids}')

    target_query_ids = [query_id for query_id in query_ids if query_id in changed_query_ids]
    if len(target_query_ids) == 0:
        print('INFO: changed SQL files do not match any query id in queries.yml. Nothing to update.')
        sys.exit(0)
    print(f'SYNC MODE: changed-only ({len(target_query_ids)} of {len(query_ids)} query ids from queries.yml)')
else:
    if changed_query_files_raw:
        print('WARNING: CHANGED_QUERY_FILES was provided but no query ids were parsed; falling back to full sync.')
    target_query_ids = query_ids
    print('SYNC MODE: full (default)')

queries_path = os.path.join(os.path.dirname(__file__), '..', 'queries')
query_file_by_id = {}
for file_name in os.listdir(queries_path):
    query_id = extract_query_id_from_filename(file_name)
    if query_id is not None:
        query_file_by_id[query_id] = file_name

for query_id in target_query_ids:
    query = dune.get_query(query_id)
    print('PROCESSING: query {}, {}'.format(query.base.query_id, query.base.name))

    # Check if query file exists in /queries folder
    query_file_name = query_file_by_id.get(query_id)
    
    if query_file_name is not None:
        file_path = os.path.join(queries_path, query_file_name)
        # Read the content of the file
        with open(file_path, 'r', encoding='utf-8') as file:
            text = file.read()

            # Update existing file
            dune.update_query(
                query.base.query_id, 
                query_sql=text,
            )
            print('SUCCESS: updated query {} to dune'.format(query.base.query_id))
    else:
        print('ERROR: file not found, query id {}'.format(query.base.query_id))
