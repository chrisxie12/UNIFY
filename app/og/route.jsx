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
          background: 'linear-gradient(135deg, #0066FF 0%, #0052CC 50%, #003d99 100%)',
          fontFamily: 'system-ui, sans-serif',
          padding: 80,
        }}
      >
        {/* Subtle dot pattern */}
        <div style={{
          position: 'absolute', inset: 0,
          backgroundImage: 'radial-gradient(circle, rgba(255,255,255,0.12) 1.5px, transparent 1.5px)',
          backgroundSize: '32px 32px',
        }} />
        {/* GH badge */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          background: 'rgba(255,255,255,0.15)', border: '1.5px solid rgba(255,255,255,0.3)',
          borderRadius: 50, padding: '10px 24px', marginBottom: 40,
        }}>
          <div style={{ width: 10, height: 10, borderRadius: '50%', background: '#4FC3F7' }} />
          <span style={{ color: 'rgba(255,255,255,0.9)', fontSize: 18, fontWeight: 700, letterSpacing: 2 }}>BUILT FOR GHANA FRESHERS</span>
        </div>
        {/* UNIFY wordmark */}
        <div style={{ color: 'white', fontSize: 120, fontWeight: 900, letterSpacing: -4, lineHeight: 1 }}>
          UNIFY
        </div>
        {/* Tagline */}
        <div style={{ color: 'rgba(255,255,255,0.9)', fontSize: 38, fontWeight: 700, marginTop: 28, textAlign: 'center', maxWidth: 900 }}>
          Don&apos;t pull up to campus alone, fr.
        </div>
        {/* Subtext */}
        <div style={{ color: 'rgba(255,255,255,0.65)', fontSize: 24, marginTop: 16, textAlign: 'center' }}>
          Built for Ghana&apos;s Class of &apos;30
        </div>
        {/* Stats row */}
        <div style={{ display: 'flex', gap: 48, marginTop: 60 }}>
          {[['180+', 'Universities'], ['12K+', 'Freshers'], ['847', 'Matched']].map(([n, l]) => (
            <div key={l} style={{ textAlign: 'center' }}>
              <div style={{ color: 'white', fontSize: 32, fontWeight: 900 }}>{n}</div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: 16, marginTop: 4 }}>{l}</div>
            </div>
          ))}
        </div>
      </div>
    ),
    { width: 1200, height: 630 }
  );
}
