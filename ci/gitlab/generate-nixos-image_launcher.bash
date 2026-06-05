#!/bin/bash
echo "Submitting batch job on distant machine..."
OAR_JOB_ID=$(oarsub -S ./generate-nixos-image_deploy-batch.bash | grep OAR_JOB_ID | sed 's/.*=//')

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

STATUS=$(oarstat -s -j $OAR_JOB_ID)
echo "Job $OAR_JOB_ID finished with status: $STATUS"

# Cleanup
rm -f generate-nixos-image_deploy-batch.bash OAR.${OAR_JOB_ID}.stdout OAR.${OAR_JOB_ID}.stderr

if [[ "$STATUS" == *"Error"* ]]; then
  echo "Job failed!"
  exit 1
fi
