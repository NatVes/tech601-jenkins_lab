#!/bin/bash
  
set -e

if [ "$JENKINS_NODE_COOKIE" != "do_not_kill" ]; then
    echo "JENKINS_NODE_COOKIE env variable not found or value is invalid."
    echo "The only valid value is: do_not_kill"
    echo "This variable is mandatory and has to be passed before calling the script"
    echo "for the deployment to succesfully work."
    echo "Example usage: export JENKINS_NODE_COOKIE=do_not_kill $0"
    exit 1
fi

if [ "$ENV" != "DEV" ] && [ "$ENV" != "PROD" ]; then
    echo "ENV variable not found or value is invalid."
    echo "Valid values are: DEV or PROD. Got: $ENV"
    exit 1
fi

if [ "$BRANCH" != "develop" ] && [ "$BRANCH" != "master" ]; then
    echo "BRANCH variable not found or value is invalid."
    echo "Valid values are: master or develop. Got: $BRANCH"
    exit 1
fi

if pgrep $ENV; then pkill -9 $ENV; fi

echo "*** Deploying the app ..."
sleep 3 && TARGET_ENV=$ENV BRANCH="$BRANCH" nohup $JENKINS_HOME/$ENV/$ENV &
