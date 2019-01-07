# filter-lists-tools

Uses `curl` for downloading data in compressed form (if supported by server) and [`jq`](https://stedolan.github.io/jq/) for parsing JSON data.


## assets.json-download-all.sh

Queries uBO [assets.json](https://raw.githubusercontent.com/gorhill/uBlock/master/assets/assets.json) for filter list URLs and downloads them all into `assets.json_resources/` subdirectory.

This tool requires around 17MB of disk space. 


## filterlists.com-download-ubo-compatible.sh

Queries [filterlists.com](https://filterlists.com/) [API](https://filterlists.com/api/docs/index.html) for all uBO supported filter lists and downloads them all into `filterlists.com_resources/` subdirectory.

This tool will require nearly 800MB of disk space. 15 largest files (out of 1133) takes nearly 0.5GB.
