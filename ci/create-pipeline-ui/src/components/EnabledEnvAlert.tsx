import { GenState, TestState, getEnabledElements, getValidSelectedClusters } from "@/lib/generation";
import Alert from "@mui/material/Alert";
import Box from "@mui/material/Box";

export default function EnabledEnvAlert({
  generations,
  clusters,
} : {
  generations: GenState,
  clusters: TestState,
}) {
  const enabledEnvs = getEnabledElements(generations);
  const enabledClusters = getValidSelectedClusters(generations, clusters);
  return (
    <Alert severity="info" sx={{ mb: 2 }}>
      {enabledEnvs.length > 0 ? (
        <>
          <Box sx={{ mb: 1 }}>Generating the following envs: {enabledEnvs.join(',')}</Box>
          <span>Testing on the following clusters: {enabledClusters.join(',')}</span>
        </>
      ) : (
        <span>No environments selected</span>
      )}
    </Alert>
  );
}
