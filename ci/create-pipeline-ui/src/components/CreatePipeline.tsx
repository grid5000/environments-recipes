'use client';

import { Dispatch, SetStateAction, useState } from 'react';
import { GenState, TestState, getEnabledElements, getValidSelectedClusters } from '@/lib/generation';

import Autocomplete from '@mui/material/Autocomplete';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Container from '@mui/material/Container';
import EnabledEnvAlert from './EnabledEnvAlert';
import GenerationTabContent from './GenerationTabContent';
import PushImagesTabContent from './PushImagesTabContent';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import TestImagesTabContent from './TestImagesTabContent';
import TextField from '@mui/material/TextField';

import config from '@/lib/config';
import { useAuth } from 'react-oidc-context';

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

const PROJECT_ID=9621;
const CREATE_PIPELINE_URL=`${process.env.NEXT_PUBLIC_GL_URL}/api/v4/projects/${PROJECT_ID}/pipeline`;

//type Pipeline = {
//id: string,
//web_url: string,
//}

function createPipelineAction(generations: GenState, clusters: TestState, ref: string, token: string | undefined) {
  if (token === undefined) {
    console.error('No token');
    return;
  }
  console.log("Create pipeline with the following variables:");
  console.log("ENVIRONMENTS_LIST", getEnabledElements(generations));
  console.log("CLUSTERS", getValidSelectedClusters(generations, clusters));
  const payload = {
    ref,
    variables: [
      { key: 'ENVIRONMENTS_LIST', value: getEnabledElements(generations).join(',')},
      { key: 'CLUSTERS', value: getValidSelectedClusters(generations, clusters).join(',')},
    ]
  };
  fetch(CREATE_PIPELINE_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  }).then(data => console.log(data))
    .catch(e => console.error(e));
}

function CreatePipelineButton({
  generations,
  clusters,
  branch,
}: {
  branch: string,
  generations: GenState,
  clusters: TestState,
}) {
  const enabledEnvs = getEnabledElements(generations);
  const auth = useAuth();
  return (
    <Button
      component="label"
      role={undefined}
      variant="contained"
      disabled={enabledEnvs.length === 0}
      color="success"
      onClick={() => createPipelineAction(generations, clusters, branch, auth.user?.access_token)}
    >
      Create the pipeline
    </Button>
  );
}

// TODO: extract to own component and link to gitlab
function BranchSelector({ branch }: {
  branch: string,
  setBranch: Dispatch<SetStateAction<string>>,
}) {
  const loading = false;
  const allOptions = ['create-pipeline'];
  return (
    <Autocomplete
      sx={{ ml:'auto', mr: 2, mt: 1, width: 300 }}
      options={allOptions}
      loading={loading}
      value={branch}
      renderInput={(params) => (
        <TextField
          {...params}
          label="Branch"
          slotProps={{
            input: {
              ...params.InputProps,
              endAdornment: loading && (
                <CircularProgress color="inherit" size={20} />
              ),
            },
          }}
        />
      )}
    />
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
  const [branch, setBranch] = useState<string>('create-pipeline');

  return (
    <Container maxWidth="xl">
      <EnabledEnvAlert generations={generations} clusters={clusters} />
      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 2 }}>
        <Tabs value={value} onChange={handleChange}>
          <Tab label="Generation" />
          <Tab label="Tests" />
          <Tab label="Push" />
          <BranchSelector branch={branch} setBranch={setBranch} />
          <CreatePipelineButton
            branch={branch}
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
