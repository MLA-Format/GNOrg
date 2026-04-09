jest.mock('../db/games.js', () => ({
  getGames: jest.fn(),
}));

const { getGames } = require('../db/games.js');
const { fetchGames } = require('../controllers/getGames');

function mockRes() {
  const res = {};
  res.status = jest.fn(() => res);
  res.json = jest.fn(() => res);
  res.sendStatus = jest.fn(() => res);
  return res;
}

beforeEach(() => jest.clearAllMocks());

describe('fetchGames', () => {
  test('returns 401 when user is not authenticated', async () => {
    const req = { body: {}, user: undefined };
    const res = mockRes();

    await fetchGames(req, res);

    expect(res.sendStatus).toHaveBeenCalledWith(401);
  });

  test('returns 400 for an invalid ObjectId', async () => {
    const req = { body: { id: 'not-a-valid-object-id' }, user: { id: 'uid1' } };
    const res = mockRes();

    await fetchGames(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'ID_INVALID' });
  });

  test('returns 400 when name is not a string', async () => {
    const req = { body: { name: 42 }, user: { id: 'uid1' } };
    const res = mockRes();

    await fetchGames(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'INVALID_INPUT' });
  });

  test('returns 400 when genre.category is not a string', async () => {
    const req = { body: { genre: { category: true } }, user: { id: 'uid1' } };
    const res = mockRes();

    await fetchGames(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: 'INVALID_INPUT' });
  });

  test('returns 404 when no games match the query', async () => {
    getGames.mockResolvedValue([]);
    const req = { body: { name: 'Nonexistent Game' }, user: { id: 'uid1' } };
    const res = mockRes();

    await fetchGames(req, res);

    expect(res.sendStatus).toHaveBeenCalledWith(404);
  });

  test('returns 200 with results on successful query', async () => {
    const games = [{ _id: 'g1', name: 'Chess' }, { _id: 'g2', name: 'Catan' }];
    getGames.mockResolvedValue(games);
    const req = { body: { name: 'Chess' }, user: { id: 'uid1' } };
    const res = mockRes();

    await fetchGames(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(games);
  });

  test('returns 500 when database throws', async () => {
    getGames.mockRejectedValue(new Error('DB error'));
    const req = { body: {}, user: { id: 'uid1' } };
    const res = mockRes();

    await fetchGames(req, res);

    expect(res.sendStatus).toHaveBeenCalledWith(500);
  });
});
