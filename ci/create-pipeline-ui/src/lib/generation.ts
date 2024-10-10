import { Dispatch, SetStateAction } from "react";
import { Cluster } from "./config";

import config from '@/lib/config';

export interface BooleanMap {
  [name: string]: boolean;
};

export type GenState = BooleanMap;
export type TestState = BooleanMap;

export type ClusterList = Cluster[];

export type TestClustersProps = {
  clusters: TestState,
  setClusters: Dispatch<SetStateAction<TestState>>,
};

export type GenStateProps = {
  generations: GenState,
  setGenerations: Dispatch<SetStateAction<GenState>>,
};

export function getEnabledElements<T extends BooleanMap>(itemsMap: T): string[] {
  return Object.entries(itemsMap)
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

export function getValidSelectedClusters(
  generations: GenState, clusters: TestState,
): ClusterList {
  const archs = getEnabledArchs(generations);
  const allValidClusters = archs.flatMap(a => config.clusters_per_arch[a]);
  const allEnabledClusters = getEnabledElements(clusters);

  return allEnabledClusters.filter(c => allValidClusters.indexOf(c) !== -1);
}
