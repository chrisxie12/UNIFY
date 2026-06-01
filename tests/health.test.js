const request = require('supertest');
const app = require('../src/app');

describe('API health endpoint', () => {
  it('returns status ok', async () => {
    const res = await request(app).get('/api/health');

    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });
});
