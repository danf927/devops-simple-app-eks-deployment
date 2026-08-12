const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('If you can read this, you just deployed successfully!\n');
});

server.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

// Handle SIGTERM explicitly (12-Factor Factor IX: Graceful Shutdown)
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server gracefully...');
  server.close(() => {
    console.log('HTTP server closed. Exiting process.');
    process.exit(0);
  });
});