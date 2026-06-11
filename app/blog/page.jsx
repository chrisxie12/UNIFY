export const metadata = {
  title: "The Freshers' Blog — UNIFY",
  description: "Real intel for Ghana's university freshers — no sugarcoating. Hostel rankings, registration hacks, roommate tips, and campus guides.",
};

const posts = [
  {
    slug: 'knust-hostel-ranking-2026',
    title: 'KNUST Hostel Ranking 2026: Brunei vs Kotei vs Unity',
    excerpt: "We compared WiFi, water supply, location, and social life across KNUST's top halls. Here's the honest breakdown before you commit.",
    tag: 'KNUST',
    color: '#FF6B35',
  },
  {
    slug: 'ug-legon-fresher-guide',
    title: 'UG Legon Fresher Guide: What Nobody Tells You',
    excerpt: 'The packing list, registration hacks, best food joints on campus, and how to avoid the portal queue chaos nobody warned you about.',
    tag: 'UG Legon',
    color: '#FF6B35',
  },
  {
    slug: 'how-to-find-a-roommate-ghana',
    title: 'How to Find a Roommate in Ghana Before Matriculation',
    excerpt: 'Why matching early matters, what questions to ask, red flags to avoid, and how to use UNIFY to secure your person before orientation.',
    tag: 'Roommates',
    color: '#059669',
  },
  {
    slug: 'ucc-vs-knust-vs-ug-legon',
    title: 'UCC vs KNUST vs UG Legon: Which Campus is Right for You?',
    excerpt: "Culture, programs, location vibes, and hostel life — an honest comparison to help you understand what you're walking into.",
    tag: 'Campus Life',
    color: '#0066FF',
  },
];

export default function BlogPage() {
  return (
    <div style={{ fontFamily: "'Inter', system-ui, sans-serif", background: '#0D1B3E', minHeight: '100vh' }}>
      <style>{`@media(min-width:640px){.md-show{display:block !important}}`}</style>
      {/* Nav */}
      <nav style={{ borderBottom: '2px solid #FF6B35', padding: '0 24px' }}>
        <div style={{ maxWidth: 1100, margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 64 }}>
          <a href="/" style={{ fontWeight: 900, fontSize: '1.1rem', textDecoration: 'none', letterSpacing: '-0.5px', color: '#FFFFFE', fontFamily: "'Barlow Condensed', sans-serif" }}>UNIFY</a>
          <div style={{ display: 'flex', alignItems: 'center', gap: 20 }}>
            <a href="/" style={{ color: 'rgba(255,255,255,0.6)', textDecoration: 'none', fontSize: '0.9rem', display: 'none' }} className="md-show">Home</a>
            <a href="/schools" style={{ color: 'rgba(255,255,255,0.6)', textDecoration: 'none', fontSize: '0.9rem', display: 'none' }} className="md-show">Schools</a>
            <a href="/faq" style={{ color: 'rgba(255,255,255,0.6)', textDecoration: 'none', fontSize: '0.9rem', display: 'none' }} className="md-show">FAQ</a>
            <a href="/#waitlist" style={{ background: '#FF6B35', color: '#fff', padding: '8px 18px', borderRadius: 0, border: '2px solid white', boxShadow: '3px 3px 0px rgba(255,255,255,0.3)', textDecoration: 'none', fontSize: '0.85rem', fontWeight: 700, whiteSpace: 'nowrap' }}>
              Join Waitlist
            </a>
          </div>
        </div>
      </nav>

      {/* Hero */}
      <section style={{ textAlign: 'center', padding: '80px 24px 60px' }}>
        <h1 style={{ fontSize: '3rem', fontWeight: 800, margin: '0 0 16px', letterSpacing: '-1px', fontFamily: "'Barlow Condensed', sans-serif", textTransform: 'uppercase' }}>
          The Freshers&apos; Blog
        </h1>
        <p style={{ fontSize: '1.2rem', color: 'rgba(255,255,255,0.6)', maxWidth: 520, margin: '0 auto' }}>
          Real intel for Ghana&apos;s university freshers — no sugarcoating.
        </p>
      </section>

      {/* Grid */}
      <section style={{ maxWidth: 960, margin: '0 auto', padding: '0 24px 100px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 24 }}>
          {posts.map((post) => (
            <a
              key={post.slug}
              href={`/blog/${post.slug}`}
              style={{ textDecoration: 'none', display: 'block', borderRadius: 0, border: '2px solid #FF6B35', boxShadow: '4px 4px 0px #FF6B35', overflow: 'hidden', transition: 'box-shadow 0.2s' }}
            >
              {/* Accent bar */}
              <div style={{ height: 8, background: post.color }} />
              <div style={{ padding: '28px 28px 24px' }}>
                <span
                  style={{
                    display: 'inline-block',
                    background: post.color + '18',
                    color: post.color,
                    fontSize: '0.78rem',
                    fontWeight: 700,
                    padding: '3px 12px',
                    borderRadius: 0,
                    marginBottom: 14,
                    letterSpacing: '0.02em',
                  }}
                >
                  {post.tag}
                </span>
                <h2 style={{ fontSize: '1.15rem', fontWeight: 700, margin: '0 0 12px', lineHeight: 1.4 }}>
                  {post.title}
                </h2>
                <p style={{ fontSize: '0.95rem', color: 'rgba(255,255,255,0.6)', margin: '0 0 20px', lineHeight: 1.7 }}>
                  {post.excerpt}
                </p>
                <span style={{ color: post.color, fontWeight: 600, fontSize: '0.9rem' }}>Read →</span>
              </div>
            </a>
          ))}
        </div>
      </section>

      {/* Footer */}
      <footer style={{ background: '#FF6B35', padding: '40px 24px', borderTop: '3px solid #FF6B35' }}>
        <div style={{ maxWidth: 960, margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span style={{ color: '#fff', fontWeight: 800, fontSize: '1.1rem', letterSpacing: '-0.5px' }}>UNIFY GH</span>
          <span style={{ color: 'rgba(255,255,255,0.75)', fontSize: '0.85rem' }}>© 2026 UNIFY. All rights reserved.</span>
        </div>
      </footer>
    </div>
  );
}
