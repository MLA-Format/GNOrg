module.exports = {
  apps: [
    {
      name: 'gnorg-backend',
      script: './server.js',
      // Restart automatically on crashes; do not watch files in prod.
      watch: false,
      // Merge stdout and stderr into a single log stream.
      merge_logs: true,
      // Restart if memory exceeds 512 MB.
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
      },
    },
  ],
};
