export PATH=SCRIPTDIR:$PATH
base=$(readlink -m ${BASH_SOURCE[0]})
base=${base%/*}
caselist=$base/caselist
source SetUpData_config.sh
source SetUpData_pipeline.sh
