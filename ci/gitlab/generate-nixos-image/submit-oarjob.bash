#!/bin/bash

set -euo pipefail

echo "Submitting batch job on distant machine..."
OAR_JOB_ID=$(oarsub -S ./oarjob-launcher.bash | grep OAR_JOB_ID | sed 's/.*=//')

if [ -z "$OAR_JOB_ID" ]; then
  echo "Failed to submit job."
  exit 1
fi

echo "Job $OAR_JOB_ID submitted successfully. Waiting for it to finish..."

tail -F "OAR.${OAR_JOB_ID}.stdout" "OAR.${OAR_JOB_ID}.stderr" &
TAIL_PID=$!

while ! oarstat -s -j $OAR_JOB_ID | grep -q 'Terminated\|Error'; do
  sleep 10
done

kill $TAIL_PID 2>/dev/null || true

EXIT_CODE=$(oarstat -Jj $OAR_JOB_ID | jq -r '.[].exit_code')

# Cleanup
rm -f OAR.${OAR_JOB_ID}.stdout OAR.${OAR_JOB_ID}.stderr

if [[ "$EXIT_CODE" != "0" ]]; then
  echo "ERROR: Job $OAR_JOB_ID finished with status: $EXIT_CODE"
  exit 1
else
  echo "Job $OAR_JOB_ID finished successfully."
fi
