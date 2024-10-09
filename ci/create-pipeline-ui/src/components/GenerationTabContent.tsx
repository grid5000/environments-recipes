import GenImageCard from "./GenImageCard";
import { GenStateProps } from "@/lib/generation";
import Grid from '@mui/material/Grid2';

import config from '@/lib/config';


export default function GenerationTabContent({
  generations, setGenerations
}: GenStateProps) {
  return (
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
  );
}
