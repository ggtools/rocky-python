{{- defineDatasource "pybranch" "env:///PY_BRANCH" -}}
{{- $pythonBranch := trim (ds "pybranch") " \n\r" -}}
{{- $versionData := (index (ds "versions") $pythonBranch) -}}
{{- $pythonVersion := $versionData.version -}}
#!/usr/bin/env bash

MY_DIR=$(dirname $0)

cd $MY_DIR

echo "Checking python version"
python --version | grep -q '^Python {{ $pythonVersion }}'

echo "Installing Pandas"
pip install Pandas

echo "Read CSV file & check shape"
python -c "import pandas as pd; df = pd.read_csv('data.csv'); assert df.shape == (3, 3), f'Bad shape: {df.shape} vs (3, 3)'"
