#!/bin/bash

set -ev

# Script used to install gatling locally

if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory where to install gatling>"
  exit 1
fi

[[ ! -d $1 ]] && echo "directory $1 does not exist" && exit 1
[[ -d $1/gatling ]] && echo "directory $1/gatling already exist" && exit 1

SCRIPT_DIR=$( cd -- "$( dirname -- "${0}" )" &> /dev/null && pwd )

cd $1;
curl -LsS https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.9.0/gatling-charts-highcharts-bundle-3.9.0-bundle.zip > gatling.zip
unzip gatling.zip
mv gatling-charts-highcharts-bundle-3.9.0 gatling
rm -rf gatling/user-files/simulations gatling.zip
cp -r $SCRIPT_DIR/../containers/client/gatling/simulations gatling/user-files/
cd gatling
cat <<EOF > run.sh
#!/bin/bash

[[ \$# -ne 3 ]] && echo "Usage: \$0 <urlbase> <benchmark description> <simulation>" && exit 1
export JAVA_OPTS="-DbaseUrl=\$1 -Dincrement=128 -Dsteps=32"
./bin/gatling.sh --run-description '\$2' -s \$3 -bm --run-mode local 
EOF
chmod a+x run.sh
