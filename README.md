# filter-lists-tools

Uses `curl` for downloading data in compressed form (if supported by server) and [`jq`](https://stedolan.github.io/jq/) for parsing JSON data.


## download-assets.json-all.sh

Queries uBO [assets.json](https://raw.githubusercontent.com/gorhill/uBlock/master/assets/assets.json) for filter list URLs and downloads them all into `assets.json_resources/` subdirectory.

This tool requires around 20MB of disk space. 


## download-filterlists.com-ubo-compatible.sh

Queries [filterlists.com](https://filterlists.com/) [API](https://filterlists.com/api/docs/index.html) for all uBO supported filter lists and downloads them all into `filterlists.com_resources/` subdirectory.

This tool will require nearly 1.5GB of disk space. 50 largest files (out of 1500+) require ~1GB.
