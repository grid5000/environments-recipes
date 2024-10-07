import { GenStateProps, getEnabledEnvs } from "@/lib/generation";

import Alert from "@mui/material/Alert";
import GenImageCard from "./GenImageCard";
import Grid from '@mui/material/Grid2';

import config from '@/lib/config';

export default function GenerationTabContent({
  generations, setGenerations
}: GenStateProps) {
  const enabledEnvs = getEnabledEnvs(generations);

  return (
    <>
      <Alert severity="info" sx={{ mb: 2 }}>
        {enabledEnvs.length > 0 ? (
          <span>Generating the following envs: {enabledEnvs.join(', ')}</span>
        ) : (
          <span>No environments selected</span>
        )}
      </Alert>
      <Grid container spacing={2}>
        {Object.keys(config.environments).map(name => (
          <Grid key={name} size={{ xs:12, md: 6, xl: 4 }}>
            <GenImageCard
              name={name}
              env={config.environments[name]}
              generations={generations}
              setGenerations={setGenerations}
            />
          </Grid>
        ))}
      </Grid>
    </>
  );
}
