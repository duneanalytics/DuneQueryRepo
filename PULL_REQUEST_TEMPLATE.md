**Is this linked to an existing issue**
If so, link that issue(s) here.

**Fill out the following table describing your edits:**

| Original Query | New Query | Change | Reasoning |
|---|---|---|---|
| [3237745](https://dune.com/queries/3237745) | [3237938](https://dune.com/queries/3238935) | Remove sandwich traders using dex.sandwiches | We should only care about traders who are not doing MEV |
| [3237723](https://dune.com/queries/3237745) | ... | ... | ... |

Provide any other context or screenshots that explain or justify the changes above:

"`tx_from` may not be the most accurate, we might want to use `tx_to` instead since that identifies the MEV contract being utilized. But this requires further digging"

Make sure your PR edits the original `query_id.sql` file with the new query text. If you are proposing adding a new query completely, make sure to add it to `queries.yml` and as a file in `/queries` as well.

Thanks for contributing! 🙏

