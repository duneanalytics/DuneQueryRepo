# Dune Query Repo

A template for creating repos to manage your Dune queries. The main flow I've created this template for is to turn any dashboard you own into a repository of queries. But you can extend it however you want.

### Setup Your Repo

1. First, go to the dashboard you want to create a repo for (must be owned by you/your team). Click on the "github" icon in the top right to see your query ids.

2. Copy and paste that list into the `queries.yml` file (or any list of query ids, doesn't have to be linked to a dashboard). 

3. Then, run `pull_from_dune.py` to bring in all queries into `/query_{id}.sql` files within the `/queries` folder. Directions are below.

4. Make any changes you need to directly in the repo. Any time you push a commit `push_to_dune.py` will run and save your changes into Dune directly.

💡: We use the [Dune CRUD API](https://dune.com/docs/api/api-reference/edit-queries/) to manage queries - this does not change how your queries behave in app.

---

### Scripts

You'll need python installed to run the script commands. Install the required packages first:

```
pip install -r requirements.txt
```

| Script | Action | Command |
|---|---|---|
| `pull_from_dune.py` | updates/adds queries to your repo based on ids in `queries.yml` | `python scripts/pull_from_dune.py` |
| `push_to_dune.py` | updates queries to Dune based on files in your `/queries` folder | `python scripts/push_to_dune.py` |
| `preview_query.py` | gives you the first 20 rows of results by running a query from your `/queries` folder. Specify the id. | `python scripts/preview_query.py 3237723` |

### For Contributors

I've set up four types of issues right now:
- `bugs`: This is for data quality issues like miscalculations or broken queries.
- `chart_improvements`: This is for suggesting improvements to the visualizations.
- `query_improvements`: This is for suggesting improvements to the query itself, such as adding an extra column or table that enhances the results.
- `generic`: This is a catch all for other questions or suggestions you may have about the dashboard.

If you want to contribute, either start an issue or go directly into making a PR (using the same labels as above). Once the PR is merged, the queries will get updated in the frontend.
