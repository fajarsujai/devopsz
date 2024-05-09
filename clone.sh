#!/usr/bin/env bash
BRANCH="main"
OWNER="fajarsujai"
ORG="pt-zen-multimedia-indonesia"
REPO_NAME=${2}
REPO_GROUP="services"
REPO_PROJECT=${1}
GIT_REMOTE="gitlabzmi.my.id"
GIT_TOKEN="glpat-mgJBbis2H7cfRLPj6LSy"
GIT_USER_TOKEN="devopskey"

####mengambil credential dari auth.json
#eval "$(jq -r '. | to_entries | .[] | .key + "=\"" + .value + "\""' < ~/.devops/auth.json)"
#OWNER=$bitbucket_USER
#GIT_PASSWORD=$bitbucket_APPPASSWORD

ORIGIN="https://${GIT_USER_TOKEN}:${GIT_TOKEN}@${GIT_REMOTE}/${ORG}/${REPO_PROJECT}/${REPO_GROUP}/${REPO_NAME}.git"

if [ ! -z "$3" ]; then
    BRANCH=$3
    rm -rf ${REPO_NAME}
    git clone $ORIGIN -b ${BRANCH}
else
    rm -rf ${REPO_NAME}
    git clone $ORIGIN
fi



