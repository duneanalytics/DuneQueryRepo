# Dune Query Repo

A template for creating repos to manage your Dune queries using the CRUD API. The main flow I've created this template for is to turn any dashboard you own into a repository of queries. But you can extend it however you want.

### Setup

1. First, go to the dashboard you want to create a repo for (must be owned by you/your team). Click on the "github" icon in the top right to see your query ids.

2. Copy and paste that list into the `queries.yml` file (or any list of query ids, doesn't have to be from a dashboard). 

3. Install the python requirements and run the `pull_from_dune.py` script. You can input the following lines into a terminal/CLI:

    ```
    pip install -r requirements.txt
    python scripts/pull_from_dune.py
    ```

    This will bring in your query ids into `query_{id}.sql` files within the `queries` folder. *You can run that same python script again anytime you need to update your work from Dune into this repo.*

4. Make any changes you need to directly in the repo, and any time you push a commit `push_to_dune.py` will run and save your changes into Dune directly. *You can also do this without waiting for a commit/github action by running the script manually:*

```
python scripts/push_to_dune.py
```

NOTE: We use the [Dune CRUD API](https://dune.com/docs/api/api-reference/edit-queries/) to manage queries - this does not change how your queries behave in app.

### For Contributors

I've set up four types of issues right now:
- `bugs`: This is for data quality issues like miscalculations or broken queries.
- `chart_improvements`: This is for suggesting improvements to the visualizations.
- `query_improvements`: This is for suggesting improvements to the query itself, such as adding an extra column or table that enhances the results.
- `generic`: This is a catch all for other questions or suggestions you may have about the dashboard.

If you want to contribute, either start an issue or go directly into making a PR (using the same labels as above). Once the PR is merged, the queries will get updated in the frontend.