'use client';

import { GenState, TestState, getEnabledElements, getValidSelectedClusters } from '@/lib/generation';

import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import EnabledEnvAlert from './EnabledEnvAlert';
import GenerationTabContent from './GenerationTabContent';
import PushImagesTabContent from './PushImagesTabContent';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import TestImagesTabContent from './TestImagesTabContent';

import config from '@/lib/config';
import { useState } from 'react';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function CustomTabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`simple-tabpanel-${index}`}
      aria-labelledby={`simple-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ mb: 2 }}>{children}</Box>}
    </div>
  );
}

function createPipelineAction(generations: GenState, clusters: TestState) {
  console.log("Create pipeline with the following variables:");
  console.log("ENVIRONMENTS_LIST", getEnabledElements(generations));
  console.log("CLUSTERS", getValidSelectedClusters(generations, clusters));
}

function CreatePipelineButton({
  generations,
  clusters,
}: {
  generations: GenState,
  clusters: TestState,
}) {
  const enabledEnvs = getEnabledElements(generations);
  return (
    <Button
      component="label"
      role={undefined}
      variant="contained"
      disabled={enabledEnvs.length === 0}
      color="success"
      onClick={() => createPipelineAction(generations, clusters)}
      sx={{ ml: 'auto' }}
    >
      Create the pipeline
    </Button>
  );
}

function initialState() {
  const allEnvNames = Object.entries(config.environments).flatMap(([name, desc]) => {
    return desc.archs.flatMap(arch => desc.variants.map(variant => `${name}-${arch}-${variant}`));
  });
  return allEnvNames.reduce((s, envName) => {
    s[envName] = false;
    return s;
  }, {} as GenState);
}

function initialTestState() {
  const allClusterNames = Object.entries(config.clusters_per_arch).flatMap(([, clusters]) => clusters);
  return allClusterNames.reduce((s, cluster) => {
    s[cluster] = false;
    return s;
  }, {} as TestState);
}

export default function CreatePipeline() {
  const [value, setValue] = useState(0);

  const handleChange = (event: React.SyntheticEvent, newValue: number) => {
    setValue(newValue);
  };

  const [generations, setGenerations] = useState<GenState>(initialState());
  const [clusters, setClusters] = useState<TestState>(initialTestState());

  return (
    <Container maxWidth="xl">
      <EnabledEnvAlert generations={generations} clusters={clusters} />
      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 2 }}>
        <Tabs value={value} onChange={handleChange}>
          <Tab label="Generation" />
          <Tab label="Tests" />
          <Tab label="Push" />
          <CreatePipelineButton
            generations={generations}
            clusters={clusters}
          />
        </Tabs>
      </Box>
      <CustomTabPanel value={value} index={0}>
        <GenerationTabContent
          generations={generations}
          setGenerations={setGenerations}
        />
      </CustomTabPanel>
      <CustomTabPanel value={value} index={1}>
        <TestImagesTabContent
          generations={generations}
          clusters={clusters}
          setClusters={setClusters}
        />
      </CustomTabPanel>
      <CustomTabPanel value={value} index={2}>
        <PushImagesTabContent />
      </CustomTabPanel>
    </Container>
  );
}
