$VERSIONS_URL = "https://raw.githubusercontent.com/docker-library/python/master/versions.json"

$VERSIONS_JSON = $(New-TemporaryFile).fullname

curl -L -s -o $VERSIONS_JSON $VERSIONS_URL

jq -r 'keys[]' $VERSIONS_JSON | ForEach-Object {
    $version = $_
    If (Test-Path -PathType Container -Path $version) {
        Write-Output "Generating templates for $version"
        Write-Output $version | gomplate  -d pybranch=stdin: -d versions=${VERSIONS_JSON}?type=application/json -t ./templates/support.t --input-dir=templates --output-dir=$version
    }
    Else {
        Write-Debug "Skipping $version"
    }
}

Remove-Item $VERSIONS_JSON
