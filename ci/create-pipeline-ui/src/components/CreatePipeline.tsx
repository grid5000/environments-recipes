'use client';

import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
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
      {value === index && <Box sx={{ p: 3 }}>{children}</Box>}
    </div>
  );
}

type GenState = {
  [name: string]: boolean;
};

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
  //   - checkboxes for all envs
  //   - checkboxes for all variants
  //   - checkboxes for all arch?
  const environments = Object.keys(config.environments);
  // Idea: one card per env
  // title: env
  // content: list of variant + arch
  // List grouped by arch!
  // actions: select all, deselect all
  // below: "check all [arch]"
  // one tab "generation", one tab "tests", one tab "push"
  // state: { envname: boolean }
  const [value, setValue] = useState(0);

  const handleChange = (event: React.SyntheticEvent, newValue: number) => {
    setValue(newValue);
  };

  const [generations, setGenerations] = useState<GenState>(initialState());

  console.log(generations);

  return (
    <Container maxWidth="xl">
      <Typography variant="h1">
        Environments pipeline
      </Typography>
      All environments: {environments.join(', ')}.
      <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
        <Tabs value={value} onChange={handleChange} aria-label="basic tabs example">
          <Tab label="Generation" />
          <Tab label="Tests" />
          <Tab label="Push" />
        </Tabs>
      </Box>
      <CustomTabPanel value={value} index={0}>
        Item One
      </CustomTabPanel>
      <CustomTabPanel value={value} index={1}>
        Item Two
      </CustomTabPanel>
      <CustomTabPanel value={value} index={2}>
        Item Three
      </CustomTabPanel>
      <Button
        component="label"
        role={undefined}
        variant="contained"
        color="success"
      >
        Create the pipeline
      </Button>
    </Container>
  );
}
