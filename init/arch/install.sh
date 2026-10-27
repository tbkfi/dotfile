#!/bin/bash
set -euo pipefail

archinstall \
	--config user_configuration.json \
	--creds user_credentials.json

#./post.sh

echo "Finished Process"
