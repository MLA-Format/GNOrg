// Central API base URL.
// Empty string = relative URLs, so calls work against whatever host serves the app.
// In dev, Vite proxies /api/* to localhost:3000.
// In production, Nginx proxies /api/* to the Express backend.
export const API_BASE = '/api';
