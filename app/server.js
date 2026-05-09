const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.get('/api/info', (_req, res) => {
  res.json({
    app: process.env.APP_NAME || 'hello-world',
    version: process.env.APP_VERSION || 'dev',
    pod: process.env.POD_NAME,
    node: process.env.NODE_NAME,
    secret_loaded: !!process.env.API_KEY,
  });
});

app.get('/', (_req, res) => {
  res.send(`<h1>Hello from EKS</h1>
<p>Pod: ${process.env.POD_NAME || 'unknown'}</p>
<p>Node: ${process.env.NODE_NAME || 'unknown'}</p>
<p>Secret loaded: ${!!process.env.API_KEY}</p>
<p><a href="/api/info">/api/info</a> · <a href="/health">/health</a></p>`);
});

app.listen(port, () => {
  console.log(`hello-world listening on :${port}`);
});
