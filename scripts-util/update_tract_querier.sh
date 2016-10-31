#!/bin/bash -eu

SCRIPTDIR=$( cd $(dirname "$0") ; pwd -P )

targetdir="$SCRIPTDIR/../scripts-pipeline/wmql/tract_querier"
srcdir=/tmp/tract_querier
builddir=/tmp/tract_querier-build
bkupdir=/tmp/tract_querier.bkup

if [ -d "$srcdir" ]; then
    cd $srcdir && git pull origin
else
    git clone https://github.com/demianw/tract_querier.git $srcdir && cd $srcdir
fi

python setup.py build --build-base=$builddir
mv $targetdir $bkupdir || true
mv $builddir $targetdir
cp -r $srcdir/tract_querier/data  $targetdir/lib/tract_querier/
