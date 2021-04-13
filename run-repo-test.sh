#!/bin/bash
# v0.0.3 - 20210411 - update run-project-test.sh, and make execution recurly

function log() {
  echo "[REPO TEST] ${1}"
}

# wrap the project test script, would like individual project also able to run test
function project_test_recurly() {
  local repo_test_report="${1}" # taking from command parameter
  
  # if it is singel project
  if [[ -f "run-project-test.sh" ]]; then
    /bin/bash run-project-test.sh "${repo_test_report}"
  else
  # for multiple projects
    for d in *; do
      if [[ -d "${d}" ]]; then
        cd "${d}" || exit
        project_test_recurly "${repo_test_report}"
        cd .. || exit
      fi
    done
  fi  
}

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
echo "-------------------------------------------------------------------------------------------"
echo "  ____                ____                      _ _                     _____         _    "
echo " |  _ \ _   _ _ __   |  _ \ ___ _ __   ___  ___(_) |_ ___  _ __ _   _  |_   _|__  ___| |_  "
echo " | |_) | | | | '_ \  | |_) / _ \ '_ \ / _ \/ __| | __/ _ \| '__| | | |   | |/ _ \/ __| __| "
echo " |  _ <| |_| | | | | |  _ <  __/ |_) | (_) \__ \ | || (_) | |  | |_| |   | |  __/\__ \ |_  "
echo " |_| \_\\__,_|_| |_| |_| \_\___| .__/ \___/|___/_|\__\___/|_|   \__, |   |_|\___||___/\__| "
echo "                               |_|                              |___/                      "
echo "-------------------------------------------------------------------------------------------"
# http://patorjk.com/software/taag/#p=display&f=Standard&t=Run%20Repository%20Test
log "v0.0.3 - 20210411 - ${BASEDIR}"
log ""

# test report - to handle the test result from 'run-project-test.sh'
test_report="/tmp/repo-test-report-${BASEDIR##*/}-$(date "+%s")"
touch "${test_report}"

# for single project
if [[ -f "run-project-test.sh" ]]; then
  project_test_recurly "${test_report}"
else
  # for multiple projects
  for d in *; do
    if [[ -d "${d}" ]]; then
      cd "${d}" || exit
      project_test_recurly "${test_report}"
      cd "${BASEDIR}" || exit
    fi
  done
fi

# read lines from test report
echo "-------------------------------------------------------------------------------------------------------------------------"
NUM=0
log "TEST REPORT"
log ""
while IFS= read -r line; do
  log "${line}"
  NUM=$((NUM + 1))
done <"${test_report}"
log "----------------------------------------"
log "TOTAL PROJECTS: ${NUM}"
echo "-------------------------------------------------------------------------------------------------------------------------"
