export const metadata = {
  title: 'UCC vs KNUST vs UG Legon: Which Campus is Right for You? — UNIFY Blog',
  description: "An honest comparison of UCC, KNUST, and UG Legon — campus culture, academic strengths, hostel life, and location vibes for Ghana freshers.",
};

const s = {
  page: { fontFamily: "'Inter', system-ui, sans-serif", background: '#fff', minHeight: '100vh' },
  nav: { borderBottom: '1px solid #E5E7EB', padding: '0 24px' },
  navInner: { maxWidth: 720, margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 56 },
  navLogo: { fontWeight: 800, color: '#111827', textDecoration: 'none', fontSize: '1rem' },
  navLink: { color: '#6B7280', textDecoration: 'none', fontSize: '0.9rem' },
  article: { maxWidth: 720, margin: '0 auto', padding: '48px 24px 80px' },
  backLink: { color: '#6B7280', textDecoration: 'none', fontSize: '0.875rem', display: 'inline-block', marginBottom: 32 },
  tag: { display: 'inline-block', background: '#7c3aed18', color: '#7c3aed', fontSize: '0.78rem', fontWeight: 700, padding: '3px 12px', borderRadius: 9999, marginBottom: 16, letterSpacing: '0.02em' },
  meta: { color: '#9CA3AF', fontSize: '0.875rem', marginBottom: 40, display: 'flex', gap: 16 },
  h1: { fontSize: '2.5rem', fontWeight: 800, color: '#111827', margin: '0 0 16px', lineHeight: 1.2, letterSpacing: '-0.5px' },
  h2: { fontSize: '1.5rem', fontWeight: 700, color: '#111827', margin: '48px 0 16px', paddingBottom: 10, borderBottom: '1px solid #E5E7EB' },
  body: { fontSize: '1.1rem', color: '#374151', lineHeight: 1.8, margin: '0 0 20px' },
  li: { fontSize: '1.05rem', color: '#374151', lineHeight: 1.8, marginBottom: 10 },
  table: { width: '100%', borderCollapse: 'collapse', margin: '24px 0 32px', fontSize: '0.92rem' },
  th: { background: '#F3F4F6', color: '#111827', fontWeight: 600, padding: '12px', textAlign: 'left', border: '1px solid #E5E7EB' },
  td: { padding: '12px', border: '1px solid #E5E7EB', color: '#374151', lineHeight: 1.5 },
  quote: { borderLeft: '4px solid #0066FF', background: '#F0F7FF', padding: '16px 20px', borderRadius: '0 8px 8px 0', margin: '24px 0', fontStyle: 'italic', color: '#374151', fontSize: '1rem', lineHeight: 1.7 },
  cta: { marginTop: 56, background: '#F9FAFB', border: '1px solid #E5E7EB', borderRadius: 12, padding: '36px', textAlign: 'center' },
  ctaBtn: { display: 'inline-block', background: '#1F2937', color: '#fff', padding: '14px 32px', borderRadius: 9999, textDecoration: 'none', fontWeight: 700, fontSize: '1rem', marginTop: 16 },
  footer: { background: '#0066FF', padding: '32px 24px', textAlign: 'center' },
  footerText: { color: '#fff', fontWeight: 800, fontSize: '1rem' },
  footerSub: { color: 'rgba(255,255,255,0.7)', fontSize: '0.8rem', marginTop: 4 },
};

export default function UCCvsKNUSTvsUGLegonPage() {
  return (
    <div style={s.page}>
      {/* Nav */}
      <nav style={s.nav}>
        <div style={s.navInner}>
          <a href="/" style={s.navLogo}>← UNIFY</a>
          <a href="/blog" style={s.navLink}>Blog</a>
        </div>
      </nav>

      {/* Article */}
      <article style={s.article}>
        <a href="/blog" style={s.backLink}>← All Posts</a>

        <div style={s.tag}>Campus Life</div>
        <h1 style={s.h1}>UCC vs KNUST vs UG Legon: Which Campus is Right for You?</h1>

        <div style={s.meta}>
          <span>7 min read</span>
          <span>·</span>
          <span>June 2026</span>
        </div>

        <p style={s.body}>
          All three are excellent universities. That needs to be said first, because this comparison is not about ranking them — it is about helping you understand what you are walking into. KNUST, UG Legon, and UCC are dramatically different experiences. The campus culture, social life, academic strengths, location, and even the pace of daily life vary in ways that matter enormously to a fresher who will spend four or more years in one of them.
        </p>
        <p style={s.body}>
          The worst decision you can make is choosing based on prestige alone, or because your senior told you one is &quot;better.&quot; Better for who? Better for what programme? Better for what kind of person? This guide helps you ask the right questions so you end up somewhere that actually fits.
        </p>

        <h2 style={s.h2}>KNUST — The Engineers&apos; Campus</h2>
        <p style={s.body}>
          The Kwame Nkrumah University of Science and Technology sits in Kumasi, Ghana&apos;s second city — and the campus radiates the energy of that positioning. KNUST is where Ghana&apos;s engineers, architects, pharmacists, doctors, and computer scientists are trained. The science and technology faculties are the institution&apos;s heartbeat, and the resources dedicated to those disciplines show.
        </p>
        <p style={s.body}>
          Life at KNUST has a tighter campus feel than Legon. The university is self-contained in a way that means you can go days without leaving campus and not feel cut off from things. The Kumasi weather is more forgiving than Accra — cooler on average, without the dry harmattan extremes. The social scene is strong: Kotei and Brunei area have restaurants, bars, and hangout spots that cater to the student population, and hall culture events run throughout the year.
        </p>
        <p style={s.body}>
          If you are studying engineering, computer science, medicine, pharmacy, architecture, or any of the natural sciences, KNUST is not just competitive — it is arguably the strongest environment in Ghana for those programmes. Faculty with serious industry connections, labs that are regularly updated, and a peer group that takes technical subjects seriously all combine to create something difficult to replicate elsewhere.
        </p>
        <div style={s.quote}>
          KNUST has a way of making you proud to be a student there, even when it&apos;s stressing you out. The campus identity is strong. You know you are part of something with a legacy.
        </div>

        <h2 style={s.h2}>UG Legon — The Prestige Campus</h2>
        <p style={s.body}>
          The University of Ghana in Legon, Accra, is the oldest and historically most prestigious public university in Ghana. It is where law, social sciences, economics, political science, languages, and humanities have traditionally found their strongest expression in Ghanaian academia. The Balme Library is genuinely one of the best academic libraries in West Africa, and the reading culture there is real — students who use it well gain a research edge that is hard to overstate.
        </p>
        <p style={s.body}>
          The Legon campus is large. Very large. It takes time to understand how to move around efficiently, and the spread of faculties means you might spend 15–20 minutes walking between departments. For some students, this feels freeing and beautiful — the campus is genuinely scenic, with wide tree-lined roads and old colonial architecture. For others, especially in the first semester, it can feel overwhelming and isolating.
        </p>
        <p style={s.body}>
          Being in Accra is a significant advantage for certain types of students. You are close to government institutions, media houses, law firms, and NGOs — which matters enormously if you are in law, journalism, public policy, or business. Internship and networking opportunities in Accra are simply more plentiful. The city&apos;s social scene — East Legon, Osu, Madina, Accra Mall — is accessible via trotro or rideshare, and many students take full advantage of it.
        </p>

        <h2 style={s.h2}>UCC — The Underrated Gem</h2>
        <p style={s.body}>
          The University of Cape Coast often gets overlooked in this conversation, and that is a mistake. UCC is Ghana&apos;s leading institution for education, nursing, sciences, and social sciences. If you are pursuing a career in education, healthcare, or marine sciences, UCC does not just match the other two — in many cases it surpasses them in programme quality and graduate employment rates.
        </p>
        <p style={s.body}>
          What makes UCC genuinely distinctive is its size and feel. Smaller than both KNUST and Legon, the campus has a more personal, community-oriented atmosphere. Lecturers are more accessible. Class sizes in certain programmes are more manageable. The relationships you build — with peers and with faculty — tend to go deeper because the environment does not swallow people the way a large campus can.
        </p>
        <p style={s.body}>
          Atlantic Hall at UCC is frequently cited as having one of the best campus views in Ghana. The proximity to the Atlantic coast is a real feature of life there — the beach is accessible, the air is different, and the pace of Cape Coast itself is calmer than Accra or Kumasi. For students who thrive in quieter environments, this is not a compromise — it is exactly what they need to do their best work.
        </p>
        <p style={s.body}>
          Cost of living in Cape Coast is meaningfully lower than in Accra or Kumasi. Food is cheaper, transport is cheaper, and accommodation outside campus tends to be more affordable. For students on tighter budgets, or those who want to stretch their family&apos;s support further, UCC has a structural financial advantage that compounds across years.
        </p>

        <h2 style={s.h2}>Quick Comparison Table</h2>
        <table style={s.table}>
          <thead>
            <tr>
              <th style={s.th}>University</th>
              <th style={s.th}>Campus Vibe</th>
              <th style={s.th}>Strongest Faculty</th>
              <th style={s.th}>Hostel Life</th>
              <th style={s.th}>City Access</th>
              <th style={s.th}>Cost of Living</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style={{ ...s.td, fontWeight: 600 }}>KNUST</td>
              <td style={s.td}>Energetic, tight-knit, hall culture-heavy</td>
              <td style={s.td}>Engineering, Medicine, CS, Pharmacy</td>
              <td style={s.td}>Strong brotherhood culture, noisy but bonding</td>
              <td style={s.td}>Kumasi city — good access</td>
              <td style={s.td}>Moderate</td>
            </tr>
            <tr>
              <td style={{ ...s.td, fontWeight: 600 }}>UG Legon</td>
              <td style={s.td}>Large, prestigious, spread out, Accra-adjacent</td>
              <td style={s.td}>Law, Social Sciences, Business, Humanities</td>
              <td style={s.td}>Varied — from quiet Volta to loud Commonwealth</td>
              <td style={s.td}>Accra — excellent for internships</td>
              <td style={s.td}>Higher</td>
            </tr>
            <tr>
              <td style={{ ...s.td, fontWeight: 600 }}>UCC</td>
              <td style={s.td}>Personal, community-focused, coastal calm</td>
              <td style={s.td}>Education, Nursing, Marine Sciences</td>
              <td style={s.td}>Smaller halls, more manageable, great views</td>
              <td style={s.td}>Cape Coast — quieter, slower pace</td>
              <td style={s.td}>Lower</td>
            </tr>
          </tbody>
        </table>

        <h2 style={s.h2}>Our Take</h2>
        <p style={s.body}>
          Here is the honest version: there is no universally better campus. There is only the one that fits who you are and what you are studying.
        </p>
        <p style={s.body}>
          <strong>If you are going into engineering, computer science, medicine, or pharmacy</strong> — go to KNUST. The infrastructure, the peer environment, the faculty, and the industry connections are optimised for technical disciplines in a way that the other campuses are not.
        </p>
        <p style={s.body}>
          <strong>If you are pursuing law, humanities, economics, business, or political science</strong> — Legon is where you want to be. The combination of programme strength, library resources, and proximity to Accra&apos;s professional ecosystem gives you advantages that compound throughout your career.
        </p>
        <p style={s.body}>
          <strong>If you are studying education, nursing, or the natural sciences, or you want a tighter community at a lower cost of living</strong> — UCC is genuinely the right call, and more students should be choosing it confidently rather than settling for it as a fallback. It is not a lesser option; it is a different and genuinely excellent one.
        </p>
        <p style={s.body}>
          Wherever you end up, start your year with your people already found. The students who arrive with connections — a roommate they already know, coursemates they have already talked to — start faster and finish stronger. Do not wait until orientation day to begin that.
        </p>

        {/* CTA */}
        <div style={s.cta}>
          <p style={{ fontSize: '1.1rem', fontWeight: 700, color: '#111827', margin: '0 0 8px' }}>Whichever campus you&apos;re headed to — find your roommate first.</p>
          <p style={{ color: '#6B7280', fontSize: '0.95rem', margin: 0 }}>
            UNIFY matches freshers at KNUST, UG Legon, and UCC based on real compatibility — sleep schedules, study habits, cleanliness, and more.
          </p>
          <a href="/#waitlist" style={s.ctaBtn}>Claim Your Spot on UNIFY →</a>
        </div>
      </article>

      {/* Footer */}
      <footer style={s.footer}>
        <p style={s.footerText}>UNIFY GH</p>
        <p style={s.footerSub}>© 2026 UNIFY. All rights reserved.</p>
      </footer>
    </div>
  );
}
