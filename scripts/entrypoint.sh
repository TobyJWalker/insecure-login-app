#!/bin/sh

set -e # exit if errors happen anywhere

flask init-db
flask run --host=0.0.0.0 --port=5001
