'use client';

import { GenState, getEnabledEnvs } from '@/lib/generation';

import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import GenerationTabContent from './GenerationTabContent';
import PushImagesTabContent from './PushImagesTabContent';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import TestImagesTabContent from './TestImagesTabContent';
import Typography from '@mui/material/Typography';

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

function CreatePipelineButton({ generations }: { generations: GenState }) {
  const enabledEnvs = getEnabledEnvs(generations);
  return (
    <Button
      component="label"
      role={undefined}
      variant="contained"
      disabled={enabledEnvs.length === 0}
      color="success"
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

export default function CreatePipeline() {
  // TODO: we need:
  //   - the list of active branches
  //   - the list of sites for enabled arch
  const [value, setValue] = useState(0);

  const handleChange = (event: React.SyntheticEvent, newValue: number) => {
    setValue(newValue);
  };

  const [generations, setGenerations] = useState<GenState>(initialState());

  return (
    <Container maxWidth="xl">
      <Typography variant="h1">
        Environments pipeline
      </Typography>
      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 2 }}>
        <Tabs value={value} onChange={handleChange}>
          <Tab label="Generation" />
          <Tab label="Tests" />
          <Tab label="Push" />
          <CreatePipelineButton generations={generations} />
        </Tabs>
      </Box>
      <CustomTabPanel value={value} index={0}>
        <GenerationTabContent
          generations={generations}
          setGenerations={setGenerations}
        />
      </CustomTabPanel>
      <CustomTabPanel value={value} index={1}>
        <TestImagesTabContent />
      </CustomTabPanel>
      <CustomTabPanel value={value} index={2}>
        <PushImagesTabContent />
      </CustomTabPanel>
    </Container>
  );
}
