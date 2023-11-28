# Query Repo

A template for creating repos to manage your Dune queries using the CRUD API.

### Setup

1. First, go to the dashboard you want to create a repo for (must be owned by you/your team). Click on the "github" icon in the top right to get a popup which will display all your query ids for said dashboard. 
    - Alternatively, just get the list queries you want to track if you aren't doing this for a dashboard.

2. Copy and paste that list into the `queries.yml` file. 

3. Install the python requirements and run the `update_from_dune.py` script. 

```
pip install -r requirements.txt
python scripts/update_from_dune.py
```

This will bring in your query ids into `query_{id}.sql` files within the `queries` folder. You can run that same python script again anytime you need to update your work from Dune into this repo. 

4. Make any changes you need to directly in the repo, and any time you push a commit, `update_to_dune.py` will run and save your changes into Dune directly.

### For Contributors

I've set up four types of issues right now:
- `bugs`: This is for data quality issues like miscalculations or broken queries.
- `chart_improvements`: This is for suggesting improvements to the visualizations.
- `query_improvements`: This is for suggesting improvements to the query itself, such as adding an extra column or table that enhances the results.
- `generic`: This is a catch all for other questions or suggestions you may have about the dashboard.

If you want to contribute, either start an issue or go directly into making a PR (using the same labels as above). Once the PR is merged, the queries will get updated in the frontend.