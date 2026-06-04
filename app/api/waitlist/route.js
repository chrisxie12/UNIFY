import { NextResponse } from 'next/server';

const SHEET_URL = 'https://script.google.com/macros/s/AKfycbyM33JowZDeb5TTU5mk_-WtS7BPXpiBdb2Xy1qhDIyUwCUt_cilKITDZ62DDwabYxy7/exec';

export async function POST(req) {
  const { phone, school } = await req.json();

  if (!phone || !school) {
    return NextResponse.json({ error: 'Phone and school required' }, { status: 400 });
  }

  try {
    await fetch(SHEET_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone, school, ts: new Date().toISOString() }),
    });
  } catch {
    return NextResponse.json({ error: 'Failed to save' }, { status: 500 });
  }

  return NextResponse.json({ ok: true });
}
