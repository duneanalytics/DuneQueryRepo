import os
from dune_client.client import DuneClient
from dotenv import load_dotenv
import sys
import codecs
import os

# Set the default encoding to UTF-8
sys.stdout = codecs.getwriter("utf-8")(sys.stdout.detach())

dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(dotenv_path)

dune = DuneClient.from_env()

uploads_path = os.path.join(os.path.dirname(__file__), '..', 'uploads')
files = os.listdir(uploads_path)

for file in files:
    if not file.endswith(".csv"):
        continue
    file_name = file.split(".")[0].lower().replace(' ', '_')
    with open(os.path.join(uploads_path, file), 'r') as file:
        try:
            table = dune.upload_csv(
                data=str(file.read()),
                table_name=file_name,
                is_private=False
            )
            print(f'uploaded table "{file_name}"')
        except Exception as e:
            print(e)

