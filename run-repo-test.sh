#!/bin/bash

# utilities to print with prefix
function log() {
  local message="${1}"
  echo "[REPO TEST] ${message}"
}

# execute project test if there is pom.xml
function execute_project_test() {
  local r="${1}" # repo-test-report
  local test="$(pwd)/run-project-test.sh"
  # because this script is a wrapper script, the real execution logic would be 'run-project-test.sh'
  if [[ -f "${test}" ]]; then
    /bin/bash "${test}" "${1}"
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
log "v0.0.1 - 20200321 - ${BASEDIR}"
log ""

# test report - to handle the test result from 'run-project-test.sh'
test_report="/tmp/repo-test-report-${BASEDIR##*/}-$(date "+%s")"
touch "${test_report}"

# this part can be enahnced in the future
# if it is singel project
# 'run-project-test.skip' is a file additionally indicates a overriding of not to execute as single project 
if [[ -f "run-project-test.sh" && ! -f "run-project-test.skip" ]]; then
  execute_project_test "${test_report}"
else
  # for multiple projects
  for d in *; do
    if [[ -d "${d}" ]]; then
      cd "${d}" || exit
      execute_project_test "${test_report}"
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
