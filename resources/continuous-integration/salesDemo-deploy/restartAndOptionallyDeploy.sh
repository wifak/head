#!/bin/bash
set -x
set -o errexit

# JOB_NAME environment variable must be set. We count on Hudson for this.

controlScript=$WORKSPACE/resources/continuous-integration/deploy/tomcat/control.sh
lastStableWAR=$WORKSPACE/application/target/mifos-webapp.war
lastStableWAR=$WORKSPACE/../../$WAR_JOB/workspace/application/target/mifos-webapp.war
deployRoot=$HOME/deploys/mifos-$JOB_NAME-deploy
targetWARlocation=$deployRoot/tomcat6/webapps/mifos.war

if [ "$FETCH_NEW_WAR" == "true" ]
then
    $controlScript stop
    rm -f $deployRoot/tomcat6/logs/*
    rm -rf $deployRoot/tomcat6/webapps/mifos
    rm -rf $deployRoot/tomcat6/work
    cp $lastStableWAR $targetWARlocation
    $controlScript start
else
    $controlScript restart
fi

can_hit_test_server=1
while [ $can_hit_test_server -ne 0 ]
do
    # Use of short circuit || operator here allows us to still use errexit
    # (-e) so the rest of this script will fail fast.
    curl --fail http://sdemo.mifos.org/mifos/ || can_hit_test_server=$?
    sleep 1
done
