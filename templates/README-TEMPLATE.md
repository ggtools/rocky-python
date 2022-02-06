# Rocky Python Template Generation

Generates the subdirectory hierarchy for a single Python version/branch. The heavy lifting is done by [gomplate](https://docs.gomplate.ca) and the version data uses the official Python image [`versions.json`](https://github.com/docker-library/python/blob/master/versions.json)

## Examples

Generate version 3.10 from a locally downloaded ``versions.json`` 

```bash
echo '3.10' | gomplate -d pybranch=stdin: -d versions.json -t ./templates/support.t --input-dir=templates --output-dir=3.10
```

Generate version 3.9 from the git file directly

```bash
echo '3.9' | gomplate -d pybranch=stdin: -d versions=https://raw.githubusercontent.com/docker-library/python/master/versions.json?type=application/json -t ./templates/support.t --input-dir=templates --output-dir=3.9
```
