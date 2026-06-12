import { ImageResponse } from 'next/og';

export const runtime = 'edge';

export async function GET() {
  return new ImageResponse(
    (
      <div
        style={{
          width: 1200,
          height: 630,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          background: '#FAF3E8',
          fontFamily: 'system-ui, sans-serif',
          padding: 80,
          border: '8px solid #111111',
        }}
      >
        {/* GH badge */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          background: '#FFFFFF', border: '3px solid #111111',
          boxShadow: '6px 6px 0px #111111',
          borderRadius: 0, padding: '10px 24px', marginBottom: 40,
        }}>
          <div style={{ width: 10, height: 10, borderRadius: 0, background: '#FF6B35' }} />
          <span style={{ color: '#111111', fontSize: 18, fontWeight: 700, letterSpacing: 2 }}>BUILT FOR GHANA FRESHERS</span>
        </div>
        {/* UNIFY wordmark */}
        <div style={{ color: '#111111', fontSize: 120, fontWeight: 900, letterSpacing: -4, lineHeight: 1 }}>
          UNIFY
        </div>
        {/* Tagline */}
        <div style={{ color: '#111111', fontSize: 38, fontWeight: 700, marginTop: 28, textAlign: 'center', maxWidth: 900 }}>
          Don&apos;t pull up to campus alone, fr.
        </div>
        {/* Subtext */}
        <div style={{ color: '#555555', fontSize: 24, marginTop: 16, textAlign: 'center' }}>
          Built for Ghana&apos;s Class of &apos;30
        </div>
        {/* Stats row */}
        <div style={{ display: 'flex', gap: 48, marginTop: 60 }}>
          {[['180+', 'Universities'], ['12K+', 'Freshers'], ['847', 'Matched']].map(([n, l]) => (
            <div key={l} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              background: '#FF6B35', border: '3px solid #111111',
              boxShadow: '5px 5px 0px #111111', padding: '14px 28px',
            }}>
              <div style={{ color: '#111111', fontSize: 32, fontWeight: 900 }}>{n}</div>
              <div style={{ color: '#111111', fontSize: 16, marginTop: 4, fontWeight: 700 }}>{l}</div>
            </div>
          ))}
        </div>
      </div>
    ),
    { width: 1200, height: 630 }
  );
}
