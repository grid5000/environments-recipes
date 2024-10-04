import rawconfig from '@/generated/config.json';

type Architecture = 'x64' | 'arm64' | 'ppc64';
type Variant = 'min' | 'base' | 'nfs' | 'big' | 'std';
type Site = string;
type EnvironmentDescription = {
  archs: Architecture[],
  variants: Variant[],
};

type Config = {
  environments: {
    [name: string]: EnvironmentDescription,
  },
  architectures: Architecture[],
  variants: Variant[],
  sites_per_arch: {
    // FIXME: it seems I can't put 'Architecture' as type key, but they are.
    [arch: string]: Site[],
  }
};

const config = rawconfig as Config;
export default config;
