# Dune Query Repo

A template for creating repos to manage your Dune queries (using the [Dune CRUD API](https://dune.com/docs/api/api-reference/edit-queries/)). The main flow I've created this template for is to turn any dashboard you own into a repository of queries. But you can extend it however you want.

### Setup Your Repo

1. Generate an API key from your Dune account and put that in both your `.env` file and github repo secrets (in settings). You can create a key under your Dune team settings. *The key must be from a premium plan for this repo to work.*

2. Then, go to the dashboard you want to create a repo for (must be owned by you/your team). Click on the "github" icon in the top right to see your query ids.

3. Copy and paste that list into the `queries.yml` file (or any list of query ids, doesn't have to be linked to a dashboard). 

4. Then, run `pull_from_dune.py` to bring in all queries into `/query_{id}.sql` files within the `/queries` folder. Directions to setup and run this script are below.

5. Make any changes you need to directly in the repo. Any time you push a commit to MAIN branch, `push_to_dune.py` will save your changes into Dune directly.

💡: Names of queries are pulled into the file name the first time `pull_from_dune.py` is run. Changing the file name in app or in folder will not affect each other (they aren't synced). **Make sure you leave the `___id.sql` at the end of the file, otherwise the scripts will break!**

🟧: Make sure to leave in the comment `-- already part of a query repo` at the top of your file. This will help make sure repo comments don't get duplicated, and also save you some headache in the case someone else from your team decides to include the query in another repo.

🛑: If you accidently merge a PR or push a commit that messes up your query in Dune, you can roll back any changes using [query version history](https://dune.com/docs/app/query-editor/version-history).

---

### Query Management Scripts

You'll need python installed to run the script commands. Install the required packages first:

```
pip install -r requirements.txt
```

| Script | Action | Command |
|---|---|---|
| `pull_from_dune.py` | updates/adds queries to your repo based on ids in `queries.yml` | `python scripts/pull_from_dune.py` |
| `push_to_dune.py` | updates queries to Dune based on files in your `/queries` folder | `python scripts/push_to_dune.py` |
| `preview_query.py` | gives you the first 20 rows of results by running a query from your `/queries` folder. Specify the id. | `python scripts/preview_query.py 3237723` |

---

### For Contributors

I've set up four types of issues right now:
- `bugs`: This is for data quality issues like miscalculations or broken queries.
- `chart_improvements`: This is for suggesting improvements to the visualizations.
- `query_improvements`: This is for suggesting improvements to the query itself, such as adding an extra column or table that enhances the results.
- `generic`: This is a catch all for other questions or suggestions you may have about the dashboard.

If you want to contribute, either start an issue or go directly into making a PR (using the same labels as above). Once the PR is merged, the queries will get updated in the frontend.
