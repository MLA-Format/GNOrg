const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

jest.mock('../db/usr.js', () => ({
  connect: jest.fn(),
  checkUserExistence: jest.fn(),
}));
jest.mock('bcryptjs');
jest.mock('jsonwebtoken');

const { connect, checkUserExistence } = require('../db/usr.js');
const { login } = require('../controllers/userLogin');

function mockRes() {
  const res = {};
  res.status = jest.fn(() => res);
  res.json = jest.fn(() => res);
  res.sendStatus = jest.fn(() => res);
  return res;
}

beforeEach(() => {
  jest.clearAllMocks();
  process.env.JWT_SECRET = 'test-secret';
});

test('returns 400 when credentials are not strings', async () => {
  const req = { body: { username: 123, password: 'abc' } };
  const res = mockRes();

  await login(req, res);

  expect(res.sendStatus).toHaveBeenCalledWith(400);
});

test('returns 401 when user does not exist', async () => {
  connect.mockResolvedValue();
  checkUserExistence.mockResolvedValue(null);
  const req = { body: { username: 'ghost', password: 'pass' } };
  const res = mockRes();

  await login(req, res);

  expect(res.sendStatus).toHaveBeenCalledWith(401);
});

test('returns 401 when password is incorrect', async () => {
  connect.mockResolvedValue();
  checkUserExistence.mockResolvedValue({ password: 'hashed', isVerified: true });
  bcrypt.compare.mockResolvedValue(false);
  const req = { body: { username: 'user', password: 'wrongpass' } };
  const res = mockRes();

  await login(req, res);

  expect(res.sendStatus).toHaveBeenCalledWith(401);
});

test('returns 403 with EMAIL_NOT_VERIFIED when account is unverified', async () => {
  connect.mockResolvedValue();
  checkUserExistence.mockResolvedValue({ password: 'hashed', isVerified: false });
  bcrypt.compare.mockResolvedValue(true);
  const req = { body: { username: 'user', password: 'pass' } };
  const res = mockRes();

  await login(req, res);

  expect(res.status).toHaveBeenCalledWith(403);
  expect(res.json).toHaveBeenCalledWith({ error: 'EMAIL_NOT_VERIFIED' });
});

test('returns 200 with JWT token on successful login', async () => {
  connect.mockResolvedValue();
  checkUserExistence.mockResolvedValue({ _id: 'uid1', password: 'hashed', isVerified: true });
  bcrypt.compare.mockResolvedValue(true);
  jwt.sign.mockReturnValue('signed-jwt-token');
  const req = { body: { username: 'user', password: 'correctpass' } };
  const res = mockRes();

  await login(req, res);

  expect(res.status).toHaveBeenCalledWith(200);
  expect(res.json).toHaveBeenCalledWith({ token: 'signed-jwt-token' });
});

test('returns 500 when database throws', async () => {
  connect.mockRejectedValue(new Error('DB connection failed'));
  const req = { body: { username: 'user', password: 'pass' } };
  const res = mockRes();

  await login(req, res);

  expect(res.sendStatus).toHaveBeenCalledWith(500);
});
