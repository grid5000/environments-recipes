import { ChangeEvent, useMemo } from "react";
import { GenState, GenStateProps } from "@/lib/generation";

import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import CardHeader from "@mui/material/CardHeader";
import Checkbox from "@mui/material/Checkbox";
import Divider from "@mui/material/Divider";
import { EnvironmentDescription } from "@/lib/config";
import FormControl from "@mui/material/FormControl";
import FormLabel from "@mui/material/FormLabel";
import GenImageCheckbox from "./GenImageCheckbox";
import Stack from "@mui/material/Stack";

function FormForImageArch({
  env,
  name,
  arch,
  generations,
  setGenerations,
} : {
  env: EnvironmentDescription,
  name: string,
  arch: string,
} & GenStateProps) {
  const localEnvs = env.variants.map(v => `${name}-${arch}-${v}`);
  const oneChecked = localEnvs.some(envName => generations[envName]);
  const oneUnchecked = localEnvs.some(envName => !generations[envName]);
  const handleChange = useMemo(() => (ev: ChangeEvent<HTMLInputElement>) => {
    setGenerations((prevGenerations: GenState) => {
      const newGenerations = {
        ...prevGenerations,
      };
      localEnvs.forEach(e => newGenerations[e] = ev.target.checked)
      return newGenerations;
    });
  }, [setGenerations, localEnvs]);
  return (
    <FormControl component="fieldset">
      <FormLabel component="legend">
        {arch}
        <Checkbox
          checked={oneChecked}
          onChange={handleChange}
          indeterminate={oneChecked && oneUnchecked}
        />
      </FormLabel>
      {env.variants.map(v => {
        const fullName = `${name}-${arch}-${v}`;
        return <GenImageCheckbox
          key={v}
          name={fullName}
          value={generations[fullName]}
          set={setGenerations}
        />
      })}
    </FormControl>
  );
}

export default function GenImageCard({
  name,
  env,
  generations,
  setGenerations,
}: {
  name: string,
  env: EnvironmentDescription,
} & GenStateProps) {
  const localEnvs = env.archs.flatMap(a => env.variants.map(v => `${name}-${a}-${v}`));
  const oneChecked = localEnvs.some(envName => generations[envName]);
  const oneUnchecked = localEnvs.some(envName => !generations[envName]);
  const handleChange = useMemo(() => (ev: ChangeEvent<HTMLInputElement>) => {
    setGenerations((prevGenerations: GenState) => {
      const newGenerations = {
        ...prevGenerations,
      };
      localEnvs.forEach(e => newGenerations[e] = ev.target.checked)
      return newGenerations;
    });
  }, [setGenerations, localEnvs]);
  return (
    <Card>
      <CardHeader
        title={name}
        action={
          <Checkbox
            checked={oneChecked}
            onChange={handleChange}
            indeterminate={oneChecked && oneUnchecked}
          />
        }
      />
      <CardContent>
        <Stack
          direction="row"
          sx={{ alignItems: 'flex-start' }}
          spacing={2}
          divider={<Divider orientation="vertical" flexItem />}
        >
          {env.archs.map(a => (
            <FormForImageArch
              env={env}
              name={name}
              key={a}
              arch={a}
              generations={generations}
              setGenerations={setGenerations}
            />
          ))}
        </Stack>
      </CardContent>
    </Card>
  );
}
