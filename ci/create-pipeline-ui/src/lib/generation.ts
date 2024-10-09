import { Dispatch, SetStateAction } from "react";
import { Cluster } from "./config";

export type GenState = {
  [name: string]: boolean;
};

export type ClusterList = Cluster[];

export type TestClustersProps = {
  clusters: ClusterList,
  setClusters: Dispatch<SetStateAction<ClusterList>>,
};

export type GenStateProps = {
  generations: GenState,
  setGenerations: Dispatch<SetStateAction<GenState>>,
};

export function getEnabledEnvs(generations: GenState): string[] {
  return Object.entries(generations)
    .filter(([, enabled]) => enabled)
    .map(([name]) => name);
}

function isFirstOne<T>(value: T, index: number, array: T[]) {
  return array.indexOf(value) === index;
}

export function getEnabledArchs(generations: GenState): string[] {
  return Object.entries(generations)
    .filter(([, enabled]) => enabled)
    .map(([name]) => name.split('-')[1])
    // This effectively makes sure we return unique values.
    .filter(isFirstOne);
}
