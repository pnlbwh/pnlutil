#!/bin/bash -eu

git clone https://github.com/demianw/tract_querier.git /tmp/tract_querier
cd /tmp/tract_querier
python setup.py build --build-base=/tmp/tq/
mv ../scripts-pipeline/wmql/tract_querier/ /tmp/tract_querier-old
mv /tmp/tq ../scripts-pipeline/wmql/tract_querier
