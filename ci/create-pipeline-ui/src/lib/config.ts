import rawconfig from '@/generated/config.json';

export type Architecture = 'x64' | 'arm64' | 'ppc64';
export type Variant = 'min' | 'base' | 'nfs' | 'big' | 'std';
export type Site = string;
export type Cluster = string;
export type EnvironmentDescription = {
  archs: Architecture[],
  variants: Variant[],
};

export type Config = {
  environments: {
    [name: string]: EnvironmentDescription,
  },
  architectures: Architecture[],
  variants: Variant[],
  sites_per_arch: {
    // FIXME: it seems I can't put 'Architecture' as type key, but they are.
    [arch: string]: Site[],
  },
  clusters_per_site: {
    [site: string]: Cluster[],
  },
  clusters_per_arch: {
    [arch: string]: Cluster[],
  },
};

const config = rawconfig as Config;
export default config;
