const routes = new Map();

function route(method, path, handler) {
  routes.set(`${method} ${path}`, handler);
}

async function handle(req) {
  const handler = routes.get(`${req.method} ${req.path}`);
  if (!handler) return { status: 404, body: { error: 'not_found' } };
  return handler(req);
}

module.exports = { route, handle, routes };
