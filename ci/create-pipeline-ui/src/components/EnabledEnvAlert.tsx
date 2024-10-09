import { GenState, getEnabledEnvs } from "@/lib/generation";
import Alert from "@mui/material/Alert";

export default function EnabledEnvAlert({
  generations,
} : {
  generations: GenState,
}) {
  const enabledEnvs = getEnabledEnvs(generations);
  return (
    <Alert severity="info" sx={{ mb: 2 }}>
      {enabledEnvs.length > 0 ? (
        <span>Generating the following envs: {enabledEnvs.join(', ')}</span>
      ) : (
        <span>No environments selected</span>
      )}
    </Alert>
  );
}
