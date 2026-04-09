jest.mock('../db/games.js', () => ({
  insertGame: jest.fn(),
}));

const { insertGame } = require('../db/games.js');
const { newGame } = require('../controllers/newGame');

function mockRes() {
  const res = {};
  res.status = jest.fn(() => res);
  res.json = jest.fn(() => res);
  res.sendStatus = jest.fn(() => res);
  return res;
}

beforeEach(() => jest.clearAllMocks());

describe('newGame', () => {
  test('returns 400 when name is missing', async () => {
    const req = { body: {}, user: { id: 'uid1' } };
    const res = mockRes();

    await newGame(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'NAME_REQ' });
  });

  test('returns 400 when name is not a string', async () => {
    const req = { body: { name: 99 }, user: { id: 'uid1' } };
    const res = mockRes();

    await newGame(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'NAME_REQ' });
  });

  test('returns 400 when genre.category is not a string', async () => {
    const req = { body: { name: 'Chess', genre: { category: 42 } }, user: { id: 'uid1' } };
    const res = mockRes();

    await newGame(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'INVALID_INPUT' });
  });

  test('returns 400 when genre.type is not a string', async () => {
    const req = { body: { name: 'Chess', genre: { type: false } }, user: { id: 'uid1' } };
    const res = mockRes();

    await newGame(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'INVALID_INPUT' });
  });

  test('returns 400 when coverImage is not a string', async () => {
    const req = { body: { name: 'Chess', coverImage: 123 }, user: { id: 'uid1' } };
    const res = mockRes();

    await newGame(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'INVALID_INPUT' });
  });

  test('returns 401 when user is not authenticated', async () => {
    const req = { body: { name: 'Chess' }, user: undefined };
    const res = mockRes();

    await newGame(req, res);

    expect(res.sendStatus).toHaveBeenCalledWith(401);
  });

  test('returns 201 with inserted id on success', async () => {
    insertGame.mockResolvedValue({ insertedId: 'new-game-id' });
    const req = { body: { name: 'Chess', genre: { category: 'Strategy' } }, user: { id: 'uid1' } };
    const res = mockRes();

    await newGame(req, res);

    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith({ id: 'new-game-id' });
  });

  test('returns 500 when database throws', async () => {
    insertGame.mockRejectedValue(new Error('DB write failed'));
    const req = { body: { name: 'Chess' }, user: { id: 'uid1' } };
    const res = mockRes();

    await newGame(req, res);

    expect(res.sendStatus).toHaveBeenCalledWith(500);
  });
});
