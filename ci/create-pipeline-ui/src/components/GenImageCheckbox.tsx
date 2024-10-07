import { ChangeEvent, Dispatch, SetStateAction, useMemo } from "react";
import Checkbox from "@mui/material/Checkbox";
import FormControlLabel from "@mui/material/FormControlLabel";
import { GenState } from "@/lib/generation";

export default function GenImageCheckbox({ value, name, set }: {
  value: boolean,
  name: string,
  set: Dispatch<SetStateAction<GenState>>
}) {
  const handleChange = useMemo(() => (ev: ChangeEvent<HTMLInputElement>) => {
    set((prevGenerations: GenState) => {
      return {
        ...prevGenerations,
        [name]: ev.target.checked,
      };
    });
  }, [set, name]);
  const labelFromName = name.split('-')[2];
  return (
    <FormControlLabel
      value={name}
      label={labelFromName}
      labelPlacement="start"
      control={<Checkbox
        checked={value}
        onChange={handleChange}
        inputProps={{ 'aria-label': 'controlled' }}
      />}
    />
  );
}
