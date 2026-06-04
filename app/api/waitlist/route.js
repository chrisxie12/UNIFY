import { NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';

const DB = path.join(process.cwd(), 'data', 'waitlist.json');

async function readDB() {
  try {
    const raw = await fs.readFile(DB, 'utf8');
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

export async function POST(req) {
  const { phone, school } = await req.json();

  if (!phone || !school) {
    return NextResponse.json({ error: 'Phone and school required' }, { status: 400 });
  }

  const entries = await readDB();

  if (entries.some((e) => e.phone === phone)) {
    return NextResponse.json({ ok: true, duplicate: true });
  }

  entries.push({ phone, school, ts: new Date().toISOString() });

  await fs.mkdir(path.dirname(DB), { recursive: true });
  await fs.writeFile(DB, JSON.stringify(entries, null, 2));

  return NextResponse.json({ ok: true, count: entries.length });
}

export async function GET() {
  const entries = await readDB();
  return NextResponse.json({ count: entries.length });
}
