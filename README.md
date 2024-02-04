# Dune Query Repo

A template for creating repos to [manage your Dune queries](https://dune.mintlify.app/api-reference/crud/endpoint/create) and any [CSVs as Dune tables](https://dune.mintlify.app/api-reference/upload/endpoint/upload).

### Setup Your Repo

1. Generate an API key from your Dune account and put that in both your `.env` file and [github action secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) (name it `DUNE_API_KEY`). You can create a key under your Dune team settings. *The api key must be from a plus plan for this repo to work.*

2. Type your intended query ids into the `queries.yml` file. The id can be found from the link `https://dune.com/queries/<query_id>/...`. If you're creating this for a dashboard, go to the dashboard you want to create a repo and click on the "github" button in the top right of your dashboard to see the query ids.

3. Then, run `pull_from_dune.py` to bring in all queries into `/query_{id}.sql` files within the `/queries` folder. Directions to setup and run this python script are below.

### Updating Queries or CSV Tables

1. Make any changes you need to directly in the repo. Any time you push a commit to MAIN branch, `push_to_dune.py` will save your changes into Dune directly. You can run this manually too if you want.

2. For CSVs, update the files in the `/uploads` folder. `upload_to_dune.py` will run on commit, or can be run manually. The table name in Dune will be `dune.team_name.dataset_<filename>`.

---

### Query Management Scripts

You'll need python and pip installed to run the script commands. If you don't have a package manager set up, then use either [conda](https://www.anaconda.com/download) or [poetry](https://python-poetry.org/) . Then install the required packages:

```
pip install -r requirements.txt
```

| Script | Action                                                                                                                                                    | Command |
|---|-----------------------------------------------------------------------------------------------------------------------------------------------------------|---|
| `pull_from_dune.py` | updates/adds queries to your repo based on ids in `queries.yml`                                                                                           | `python scripts/pull_from_dune.py` |
| `push_to_dune.py` | updates queries to Dune based on files in your `/queries` folder                                                                                          | `python scripts/push_to_dune.py` |
| `preview_query.py` | gives you the first 20 rows of results by running a query from your `/queries` folder. Specify the id. This uses Dune API credits | `python scripts/preview_query.py 2615782` |
| `upload_to_dune.py` | uploads/updates any tables from your `/uploads` folder. Must be in CSV format, and under 200MB. | `python scripts/upload_to_dune.py` |

---

### Things to be aware of

💡: Names of queries are pulled into the file name the first time `pull_from_dune.py` is run. Changing the file name in app or in folder will not affect each other (they aren't synced). **Make sure you leave the `___id.sql` at the end of the file, otherwise the scripts will break!**

🟧: Make sure to leave in the comment `-- already part of a query repo` at the top of your file. This will hopefully help prevent others from using it in more than one repo.

🔒: Queries must be owned by the team the API key was created under - otherwise you won't be able to update them from the repo.

➕: If you want to add a query, add it in Dune app first then pull the query id (from URL `dune.com/queries/{id}/other_stuff`) into `queries.yml`

🛑: If you accidently merge a PR or push a commit that messes up your query in Dune, you can roll back any changes using [query version history](https://dune.com/docs/app/query-editor/version-history).

---

### For Contributors

I've set up four types of issues right now:
- `bugs`: This is for data quality issues like miscalculations or broken queries.
- `chart improvements`: This is for suggesting improvements to the visualizations.
- `query improvements`: This is for suggesting improvements to the query itself, such as adding an extra column or table that enhances the results.
- `generic questions`: This is a catch all for other questions or suggestions you may have about the dashboard.

If you want to contribute, either start an issue or go directly into making a PR (using the same labels as above). Once the PR is merged, the queries will get updated in the frontend.
