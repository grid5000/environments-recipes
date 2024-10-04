/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  basePath: process.env.WEBSITE_PREFIX || '',
};

export default nextConfig;
