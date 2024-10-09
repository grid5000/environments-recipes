import { GenState, TestClustersProps, getEnabledEnvs } from '@/lib/generation';
import config, { Cluster } from '@/lib/config';

import Accordion from '@mui/material/Accordion';
import AccordionDetails from '@mui/material/AccordionDetails';
import AccordionSummary from '@mui/material/AccordionSummary';
import Box from '@mui/material/Box';
import Checkbox from '@mui/material/Checkbox';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import Grid from '@mui/material/Grid2';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import ListSubheader from '@mui/material/ListSubheader';
import Typography from '@mui/material/Typography';

function ClustersListForSite({ site, validClusters }: {
  arch: string,
  site: string,
  validClusters: Cluster[],
} & TestClustersProps) {
  const localClusters = config.clusters_per_site[site].filter(c => validClusters.indexOf(c) !== -1);
  return (
    <List
      sx={{ width: '100%' }}
      subheader={
        <ListSubheader component="div">
          {site}
        </ListSubheader>
      }
    >
      {localClusters.map(c => (
        <ListItem disablePadding key={c}>
          <ListItemButton dense role={undefined} onClick={() => {}}>
            <ListItemIcon>
              <Checkbox
                edge="start"
                checked={true}
                tabIndex={-1}
                disableRipple
              />
            </ListItemIcon>
            <ListItemText primary={c} />
          </ListItemButton>
        </ListItem>
      ))}
    </List>
  );
}

function ClustersAccordion({ arch, generations, clusters, setClusters }: {
  arch: string,
  generations: GenState,
} & TestClustersProps) {
  const id = `${arch}-header`;
  const clustersForArch = config.clusters_per_arch[arch];
  const enabled = getEnabledEnvs(generations).some(name => name.split('-')[1] === arch);
  //const enabled = false;
  return (
    <Accordion disabled={!enabled}>
      <AccordionSummary
        expandIcon={<ExpandMoreIcon />}
        id={id}
      >
        <Typography>{arch} clusters</Typography>
      </AccordionSummary>
      {enabled && (
        <AccordionDetails>
          <Grid container spacing={2}>
            {config.sites_per_arch[arch].map(s => (
              <Grid size={{ xs:12, md: 6, xl: 2 }} key={s}>
                <ClustersListForSite
                  arch={arch}
                  site={s}
                  validClusters={clustersForArch}
                  clusters={clusters}
                  setClusters={setClusters}
                />
              </Grid>
            ))}
          </Grid>
        </AccordionDetails>
      )}
    </Accordion>
  );
}

export default function TestImagesTabContent({
  clusters, setClusters, generations
}: {
  generations: GenState,
} & TestClustersProps) {
  return (
    <Box>
      {config.architectures.map(a => (
        <ClustersAccordion
          key={a}
          arch={a}
          clusters={clusters}
          setClusters={setClusters}
          generations={generations}
        />
      ))}
    </Box>
  );
}
