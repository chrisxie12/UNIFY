import { ImageResponse } from 'next/og';

export const runtime = 'edge';

export async function GET() {
  return new ImageResponse(
    (
      <div
        style={{
          width: '1200px',
          height: '630px',
          background: '#050d20',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start',
          justifyContent: 'center',
          padding: '72px 80px',
          fontFamily: 'system-ui, sans-serif',
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        {/* background glow */}
        <div style={{
          position: 'absolute', top: '-100px', right: '-100px',
          width: '500px', height: '500px',
          background: 'radial-gradient(circle, rgba(251,191,36,0.12) 0%, transparent 70%)',
          borderRadius: '50%',
        }} />
        <div style={{
          position: 'absolute', bottom: '-80px', left: '-80px',
          width: '400px', height: '400px',
          background: 'radial-gradient(circle, rgba(59,130,246,0.08) 0%, transparent 70%)',
          borderRadius: '50%',
        }} />

        {/* Ghana flag stripe top */}
        <div style={{
          position: 'absolute', top: 0, left: 0, right: 0, height: '6px',
          background: 'linear-gradient(to right, #DC2626, #F59E0B, #16A34A)',
        }} />

        {/* logo */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '40px',
        }}>
          <div style={{
            width: '56px', height: '56px', borderRadius: '16px',
            background: 'linear-gradient(135deg, #FBBF24, #F59E0B)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <span style={{ fontSize: '24px', fontWeight: '900', color: '#050d20' }}>U</span>
          </div>
          <span style={{ fontSize: '28px', fontWeight: '900', color: 'white', letterSpacing: '-0.5px' }}>UNIFY</span>
          <div style={{
            fontSize: '13px', fontWeight: '700', color: 'rgba(251,191,36,0.9)',
            background: 'rgba(251,191,36,0.1)', border: '1px solid rgba(251,191,36,0.25)',
            borderRadius: '100px', padding: '4px 12px', marginLeft: '4px',
          }}>
            🇬🇭 Ghana's Fresher Network
          </div>
        </div>

        {/* headline */}
        <div style={{
          fontSize: '72px', fontWeight: '900', color: 'white',
          lineHeight: '1.05', letterSpacing: '-2px', marginBottom: '24px',
        }}>
          Don't pull up to<br />
          campus alone,{' '}
          <span style={{ color: '#FBBF24' }}>fr.</span>
        </div>

        {/* subtext */}
        <div style={{
          fontSize: '22px', color: 'rgba(255,255,255,0.45)',
          lineHeight: '1.5', maxWidth: '680px', marginBottom: '48px',
        }}>
          Find your roommate, link with coursemates, and tap into your official campus hub — before matriculation day.
        </div>

        {/* school pills */}
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          {['KNUST', 'UG Legon', 'UCC', 'UPSA', 'UDS', 'GCTU'].map((s) => (
            <div key={s} style={{
              fontSize: '14px', fontWeight: '800', color: 'rgba(255,255,255,0.6)',
              background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
              borderRadius: '100px', padding: '6px 16px',
            }}>
              {s}
            </div>
          ))}
        </div>

        {/* bottom right — url */}
        <div style={{
          position: 'absolute', bottom: '36px', right: '80px',
          fontSize: '15px', fontWeight: '700', color: 'rgba(255,255,255,0.2)',
        }}>
          unify-lake.vercel.app
        </div>

        {/* Ghana flag stripe bottom */}
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0, height: '4px',
          background: 'linear-gradient(to right, #DC2626, #F59E0B, #16A34A)',
        }} />
      </div>
    ),
    { width: 1200, height: 630 }
  );
}
