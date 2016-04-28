base=$(readlink -m ${BASH_SOURCE[0]})
base=${base%/*}
source SetUpData_config.sh
base=$(readlink -m ${BASH_SOURCE[0]})
base=${base%/*}
caselist=$base/caselist.txt
source SetUpData_pipeline.sh
