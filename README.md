# Bookmarklet Generator For Glasto Groups

Make sure the `.sh` files are executable then if you need CSV to json:

```sh
./convert_to_json.sh ./input.csv
```

Then

```sh
./generate_bookmarklets.sh ./glastonbury_groups.json > index.html
```

You can just do the second one if you already have the JSON in the right format (check the ones in the repo).

Then just publish the HTML somewhere, the CSS makes it look nice too.
