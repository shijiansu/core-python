#!/bin/bash

# utilities to print with prefix
function log() {
  local message="${1}"
  echo "[PROJECT TEST] ${message}"
}

# execute maven clean test if there is pom.xml
function execute_maven() {
  local d="${1}"
  # use "pom.xml" to tell if maven project
  if [[ -f pom.xml ]]; then
    printf "[PROJECT TEST] %s: " "${d}" # printf not to printing a line seperator
    # choose the maven exector, use maven wrapper or maven installed in local
    if [[ -f mvnw ]]; then local response=$(./mvnw clean test); else local response=$(mvn clean test); fi
    # use "BUILD SUCCESS" as successful indicator
    if [[ "$(echo "${response}" | grep "BUILD SUCCESS")" != "" ]]; then # success
      echo "Test successfully... ..."
      succ=$((succ + 1))
    else
      echo "Test failed!!!"
      failed=$((failed + 1))
    fi
  fi
}

repo_test_report="${1}" # taking from command parameter
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
echo "--------------------------------------------------------------------------------"
log "v0.0.2 - 20200321 - ${BASEDIR}"
log ""

# execute all maven project(s) in this folder
succ=0
failed=0

# if it is singel project
if [[ -d "src" ]]; then
  project_name="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
  project_name=${project_name##*/}  # current folder without full path, for print out only
  execute_maven "${project_name}"
else
# for multiple projects
  for d in *; do
    if [[ -d "${d}" ]]; then
      cd "${d}" || exit
      execute_maven "${d}"
      cd "${BASEDIR}" || exit
    fi
  done
fi

echo ""
log "Total success: ${succ}; Total failed: ${failed}"
echo ""

# append the project test result into repo rest report with formatted by tab
if [[ -f "${repo_test_report}" ]]; then
  # with format and placeholder
  ## %-80s: append 80 spaces on the right, if not reach to 80
  ## ${BASEDIR##*/}: only take sub string after the last /
  printf "%-80s   SUCCESS: %2d   FAILED: %2d\n" "${BASEDIR##*/}" ${succ} ${failed} >> "${repo_test_report}"
fi
