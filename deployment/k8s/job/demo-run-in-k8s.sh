#!/usr/bin/env bash
./create-job.sh
source ./create-job.vars
./describe-job.sh ${JOB_NAME}
./wait-job.sh ${JOB_NAME}
./delete-job.sh ${JOB_NAME}
