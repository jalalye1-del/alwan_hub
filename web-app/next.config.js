/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: [
      'images.unsplash.com',
      'images.pexels.com',
      'www.soundhelix.com',
      'commondatastorage.googleapis.com',
    ],
  },
};

module.exports = nextConfig;
