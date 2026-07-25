// API keys are resolved from the Authorization header. Each key belongs to a
// tenant and carries a plan tier: 'free' | 'pro' | 'enterprise'.
const keys = new Map();

function register(key, tenantId, tier) {
  keys.set(key, { tenantId, tier });
}

function resolve(authHeader) {
  if (!authHeader?.startsWith('Bearer ')) return null;
  return keys.get(authHeader.slice(7)) ?? null;
}

module.exports = { register, resolve, keys };
