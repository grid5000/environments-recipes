import config from '@/lib/config';

export default function TestImagesTabContent() {
  return (
    <div>{Object.keys(config.clusters_per_site).join(', ')}</div>
  );
}
