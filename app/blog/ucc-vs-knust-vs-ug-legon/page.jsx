export const metadata = {
  title: "UCC vs KNUST vs UG Legon: Which Campus is Right for You? — UNIFY Blog",
  description: "An honest comparison of UCC, KNUST, and UG Legon — campus culture, academic strengths, hostel life, and location vibes for Ghana freshers.",
};

const s = {
  page: { fontFamily: "'Inter', system-ui, sans-serif", background: '#0F0E17', minHeight: '100vh',  },
  nav: { borderBottom: '1px solid #E5E7EB', padding: '16px 24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', maxWidth: 720, margin: '0 auto' },
  back: { fontSize: 14, color: 'rgba(255,255,255,0.6)', textDecoration: 'none', fontWeight: 600 },
  blogLink: { fontSize: 14, color: '#0066FF', textDecoration: 'none', fontWeight: 700 },
  article: { maxWidth: 720, margin: '0 auto', padding: '40px 24px 80px' },
  tag: { display: 'inline-block', background: '#F5F3FF', border: '1px solid #DDD6FE', color: '#7c3aed', fontSize: 11, fontWeight: 800, padding: '4px 12px', borderRadius: 999, letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 16 },
  meta: { fontSize: 13, color: 'rgba(255,255,255,0.4)', marginBottom: 32, display: 'flex', gap: 16 },
  h1: { fontSize: '2.2rem', fontWeight: 900, , lineHeight: 1.15, marginBottom: 12 },
  h2: { fontSize: '1.3rem', fontWeight: 800, , marginTop: 40, marginBottom: 12, paddingBottom: 8, borderBottom: '2px solid #F3F4F6' },
  p: { fontSize: '1.05rem', lineHeight: 1.8, color: 'rgba(255,255,255,0.8)', marginBottom: 20 },
  li: { fontSize: '1.05rem', lineHeight: 1.8, color: 'rgba(255,255,255,0.8)', marginBottom: 8 },
  callout: { background: '#F0F7FF', borderLeft: '4px solid #0066FF', padding: '16px 20px', borderRadius: '0 8px 8px 0', margin: '24px 0', fontStyle: 'italic', color: 'rgba(255,255,255,0.8)', fontSize: '1rem', lineHeight: 1.7 },
  table: { width: '100%', borderCollapse: 'collapse', marginBottom: 24, fontSize: '0.95rem' },
  th: { background: '#F3F4F6', padding: '10px 12px', textAlign: 'left', fontWeight: 700, color: 'rgba(255,255,255,0.8)', border: '1px solid #E5E7EB' },
  td: { padding: '10px 12px', border: '1px solid #E5E7EB', color: 'rgba(255,255,255,0.8)', verticalAlign: 'top' },
  cta: { marginTop: 56, background: '#F9FAFB', border: '1px solid #E5E7EB', borderRadius: 16, padding: '32px', textAlign: 'center' },
  ctaBtn: { display: 'inline-block', background: '#7B2FBE', color: '#fff', fontWeight: 900, fontSize: 15, padding: '14px 28px', borderRadius: 999, textDecoration: 'none', marginTop: 16 },
  footer: { background: '#7B2FBE', color: 'white', textAlign: 'center', padding: '24px', fontSize: 13 },
};

export default function UCCvsKNUSTvsLegon() {
  return (
    <div style={s.page}>
      <div style={s.nav}>
        <a href="/" style={s.back}>← UNIFY</a>
        <a href="/blog" style={s.blogLink}>Blog</a>
      </div>

      <article style={s.article}>
        <div style={s.tag}>Campus Life</div>
        <h1 style={s.h1}>UCC vs KNUST vs UG Legon: Which Campus is Right for You?</h1>
        <div style={s.meta}><span>7 min read</span><span>·</span><span>June 2026</span></div>

        <p style={s.p}>All three are excellent universities. All three will give you a degree that carries weight in Ghana. But they are not the same place, and the campus you choose will shape your first year — your social life, your study environment, your cost of living, and the kind of person you become during that time. Here is an honest comparison.</p>

        <h2 style={s.h2}>KNUST — The Engineers' Campus</h2>
        <p style={s.p}>Kwame Nkrumah University of Science and Technology sits in Kumasi, and it operates on its own energy. KNUST is Ghana's premier science and technology university — if you are going into Engineering, Computer Science, Medicine, Pharmacy, or Architecture, this is where the strongest programmes are.</p>
        <p style={s.p}>Campus life is intense in the best way. The halls — Brunei, Kotei, Unity, Evandy — each have their own culture and identity. Social life centres around hall traditions, Saturday football, and the strip of restaurants and chop bars along Kotei Road. Kumasi's weather is more forgiving than Accra, and the cost of living is meaningfully lower.</p>
        <p style={s.p}>The trade-off is isolation — you are in Kumasi, not Accra. If your family is in Accra or you value easy city access, factor that in. But most KNUST students say within a month they stop thinking about it.</p>

        <div style={s.callout}>"KNUST feels like its own city. You barely need to leave campus in first year — everything is there, everyone is there. It takes some getting used to but I love it." — Ama, KNUST Engineering '29</div>

        <h2 style={s.h2}>UG Legon — The Prestige Campus</h2>
        <p style={s.p}>The University of Ghana is Ghana's oldest and most prestigious university, and it operates with that awareness. If you are going into Law, Social Sciences, Business, Humanities, or Political Science, UG Legon is the destination. The Balme Library is one of the best academic libraries in West Africa. The alumni network is unmatched.</p>
        <p style={s.p}>Legon sits on the outskirts of Accra, which means city access is real — but so is the urban cost of living. Transport, food, and accommodation near campus run higher than in Kumasi or Cape Coast. The campus itself is large and can feel overwhelming in the first weeks. Unlike KNUST, there is less of a single campus culture — identity is more tied to your hall and your programme.</p>
        <p style={s.p}>The social scene is large and diverse. The proximity to Accra means events, internships, and networking opportunities that students at other campuses simply do not have access to in the same way.</p>

        <h2 style={s.h2}>UCC — The Underrated Gem</h2>
        <p style={s.p}>University of Cape Coast does not always get the hype it deserves. It should. UCC is Ghana's strongest university for Nursing, Education, and Sciences. The campus sits above Cape Coast town with one of the best views of any university in the country — Atlantic Hall has a direct ocean view that would cost a fortune anywhere else.</p>
        <p style={s.p}>UCC is smaller and more personal than both KNUST and Legon. You will know people across programmes, the community feels tighter, and the pace of social life is more manageable. Cost of living in Cape Coast is the lowest of the three — your stipend stretches further here.</p>
        <p style={s.p}>The trade-off is that Cape Coast is further from major economic activity. If your programme leads directly into the Accra job market, you may need to be more intentional about internships and city networking during your time at UCC.</p>

        <h2 style={s.h2}>Quick Comparison</h2>
        <table style={s.table}>
          <thead>
            <tr>
              <th style={s.th}>Factor</th>
              <th style={s.th}>KNUST</th>
              <th style={s.th}>UG Legon</th>
              <th style={s.th}>UCC</th>
            </tr>
          </thead>
          <tbody>
            {[
              ['Campus Vibe', 'High-energy, tight-knit', 'Large, diverse, prestige', 'Smaller, personal, scenic'],
              ['Strongest Faculty', 'Engineering, CS, Medicine, Pharmacy', 'Law, Social Sciences, Business', 'Nursing, Education, Sciences'],
              ['Hostel Life', 'Hall culture is central to identity', 'Hall-based, varied by hall', 'Smaller halls, closer community'],
              ['City Access', 'Kumasi (good, not Accra)', 'Accra (best access)', 'Cape Coast (quieter)'],
              ['Cost of Living', 'Moderate', 'Higher (Accra prices)', 'Lowest of the three'],
              ['Social Life', 'Campus-focused, strong', 'Campus + city, very active', 'Campus-focused, relaxed'],
            ].map(([factor, knust, ug, ucc]) => (
              <tr key={factor}>
                <td style={{ ...s.td, fontWeight: 700 }}>{factor}</td>
                <td style={s.td}>{knust}</td>
                <td style={s.td}>{ug}</td>
                <td style={s.td}>{ucc}</td>
              </tr>
            ))}
          </tbody>
        </table>

        <h2 style={s.h2}>Our Take</h2>
        <p style={s.p}>If your programme is in Engineering, CS, Medicine, Pharmacy, or Architecture — choose KNUST. The labs, the lecturers, the industry connections, and the culture around those disciplines are strongest there.</p>
        <p style={s.p}>If you are going into Law, Business, Economics, or Humanities and you want the prestige network and Accra access — UG Legon is the right call.</p>
        <p style={s.p}>If you are going into Nursing, Education, or Sciences, or you want a tighter community with lower living costs — UCC is genuinely underrated, and you will not regret it.</p>
        <p style={s.p}>What all three have in common: you will spend the first few weeks figuring out where everything is, who your people are, and how the system works. Start that process before you arrive.</p>

        <div style={s.cta}>
          <p style={{ fontSize: 18, fontWeight: 900, , marginBottom: 8 }}>Already know your campus? Find your people now.</p>
          <p style={{ fontSize: 14, color: 'rgba(255,255,255,0.6)', marginBottom: 0 }}>Join your school hub on UNIFY, find your roommate, and arrive ready.</p>
          <a href="/#waitlist" style={s.ctaBtn}>Claim Your Spot →</a>
        </div>
      </article>

      <footer style={s.footer}>
        <p>© 2026 UNIFY Ghana. <a href="/blog" style={{ color: 'rgba(255,255,255,0.8)', textDecoration: 'none' }}>Blog</a> · <a href="/faq" style={{ color: 'rgba(255,255,255,0.8)', textDecoration: 'none' }}>FAQ</a></p>
      </footer>
    </div>
  );
}
