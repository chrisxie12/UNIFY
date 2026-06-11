export const metadata = {
  title: "How to Find a Roommate in Ghana Before Matriculation — UNIFY Blog",
  description: "Why finding your roommate before orientation matters, the right questions to ask, red flags to watch for, and how UNIFY makes it simple.",
};

const s = {
  page: { fontFamily: "'Inter', system-ui, sans-serif", background: '#0D1B3E', minHeight: '100vh',  },
  nav: { borderBottom: '1px solid rgba(255,255,255,0.1)', padding: '16px 24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', maxWidth: 720, margin: '0 auto' },
  back: { fontSize: 14, color: 'rgba(255,255,255,0.6)', textDecoration: 'none', fontWeight: 600 },
  blogLink: { fontSize: 14, color: '#FF6B35', textDecoration: 'none', fontWeight: 700 },
  article: { maxWidth: 720, margin: '0 auto', padding: '40px 24px 80px' },
  tag: { display: 'inline-block', background: '#F0FDF4', border: '1px solid #BBF7D0', color: '#16a34a', fontSize: 11, fontWeight: 800, padding: '4px 12px', borderRadius: 0, letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 16 },
  meta: { fontSize: 13, color: 'rgba(255,255,255,0.4)', marginBottom: 32, display: 'flex', gap: 16 },
  h1: { fontSize: '2.2rem', fontWeight: 900, lineHeight: 1.15, marginBottom: 12 },
  h2: { fontSize: '1.3rem', fontWeight: 800, marginTop: 40, marginBottom: 12, paddingBottom: 8, borderBottom: '2px solid rgba(255,255,255,0.1)' },
  p: { fontSize: '1.05rem', lineHeight: 1.8, color: 'rgba(255,255,255,0.8)', marginBottom: 20 },
  li: { fontSize: '1.05rem', lineHeight: 1.8, color: 'rgba(255,255,255,0.8)', marginBottom: 10 },
  callout: { background: '#162347', borderLeft: '4px solid #0066FF', padding: '16px 20px', borderRadius: 0, margin: '24px 0', fontStyle: 'italic', color: 'rgba(255,255,255,0.8)', fontSize: '1rem', lineHeight: 1.7 },
  num: { display: 'inline-block', width: 28, height: 28, borderRadius: 0, background: '#FF6B35', color: '#fff', fontWeight: 900, fontSize: 13, lineHeight: '28px', textAlign: 'center', marginRight: 12, flexShrink: 0 },
  cta: { marginTop: 56, background: '#162347', border: '1px solid rgba(255,255,255,0.1)', borderRadius: 0, padding: '32px', textAlign: 'center' },
  ctaBtn: { display: 'inline-block', background: '#FF6B35', color: '#fff', fontWeight: 900, fontSize: 15, padding: '14px 28px', borderRadius: 0, textDecoration: 'none', marginTop: 16 },
  footer: { background: '#FF6B35', color: 'white', textAlign: 'center', padding: '24px', fontSize: 13 },
};

export default function FindRoommateGhana() {
  return (
    <div style={s.page}>
      <div style={s.nav}>
        <a href="/" style={s.back}>← UNIFY</a>
        <a href="/blog" style={s.blogLink}>Blog</a>
      </div>

      <article style={s.article}>
        <div style={s.tag}>Roommates</div>
        <h1 style={s.h1}>How to Find a Roommate in Ghana Before Matriculation</h1>
        <div style={s.meta}><span>4 min read</span><span>·</span><span>June 2026</span></div>

        <p style={s.p}>Most Ghana freshers end up with their roommate the same way: a random assignment, a group chat someone added them to last minute, or whoever happened to be standing near the hostel gate on move-in day. It works — until it doesn't. Your first-year roommate affects your sleep, your grades, and your entire social starting point. That gamble is avoidable.</p>

        <h2 style={s.h2}>Why It Matters More Than You Think</h2>
        <p style={s.p}>The first semester is when habits form. If your roommate sleeps at 10pm and you study until 2am, that is a daily conflict. If they have guests over every weekend and you need quiet to focus, resentment builds fast. It is not about finding someone perfect — it is about finding someone compatible.</p>
        <p style={s.p}>Research on university roommate pairs consistently shows that incompatible roommates are one of the top reasons students struggle to settle in first year. In Ghana specifically, where hall rooms are small and personal space is limited, the friction amplifies quickly.</p>

        <div style={s.callout}>"We matched on UNIFY in June. By the time we arrived in September, we had already talked for two months. We knew each other's habits, divided up what to bring, and arrived without drama. Everyone else was stressed out — we weren't." — Ama K., KNUST CS '30</div>

        <h2 style={s.h2}>5 Questions to Ask Before You Agree</h2>
        <p style={s.p}>Before you commit to sharing a room with someone, get these answers:</p>
        {[
          { q: 'Sleep schedule — early bird or night owl?', a: 'This is the most common source of roommate conflict. If you sleep at 9pm and they study with the light on until 1am, someone loses every night.' },
          { q: 'Study habits — silent or group study?', a: 'Some people need absolute quiet. Others think out loud, play music, and work in groups. Neither is wrong, but they cannot coexist in a small room.' },
          { q: 'Guests and visitors — how often, how late?', a: 'Are their friends constantly around? Do they have a partner who visits regularly? What is the boundary on overnight guests? Get this settled early.' },
          { q: 'Cleanliness standard — drawer-neat or floor pile?', a: 'You do not need to be identical. But if one of you has a mop schedule and the other has never owned one, that gap will cause problems.' },
          { q: 'Social life — do they go out or stay in?', a: 'If they party every Friday and you have 8am Saturday lectures, you will be woken up at 2am regularly. Know this upfront.' },
        ].map((item, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'flex-start', marginBottom: 20 }}>
            <div style={s.num}>{i + 1}</div>
            <div>
              <p style={{ ...s.p, marginBottom: 4, fontWeight: 700 }}>{item.q}</p>
              <p style={{ ...s.p, marginBottom: 0, color: 'rgba(255,255,255,0.6)', fontSize: '0.95rem' }}>{item.a}</p>
            </div>
          </div>
        ))}

        <h2 style={s.h2}>Red Flags to Watch Out For</h2>
        <p style={s.p}>Some warning signs during the matching process are worth paying attention to:</p>
        <ul style={{ paddingLeft: 24, marginBottom: 20 }}>
          <li style={s.li}><strong>Vague about everything.</strong> If they cannot give a straight answer about sleep schedule or guests, they may be hiding an incompatibility.</li>
          <li style={s.li}><strong>Defensive about cleanliness questions.</strong> A simple "I keep my space tidy" is fine. Getting irritated by the question is a flag.</li>
          <li style={s.li}><strong>No stable contact.</strong> If their WhatsApp shows "last seen 3 weeks ago" and they only reply sometimes, the communication pattern in real life will be similar.</li>
          <li style={s.li}><strong>Pressuring you to decide the same day.</strong> A good match should not feel rushed. If someone needs an answer immediately, ask why.</li>
        </ul>

        <h2 style={s.h2}>How UNIFY Solves This</h2>
        <p style={s.p}>UNIFY matches freshers based on their actual habits — not just their school and programme. You fill in a compatibility profile covering sleep schedule, study style, cleanliness, social preferences, and hostel area. The matching engine pairs you with freshers from the same school who fit your profile.</p>
        <p style={s.p}>From there, you chat before you commit. No random assignment, no broker who does not know either of you, no group chat chaos where you end up with whoever replies first. You choose, knowing who you are choosing.</p>
        <p style={s.p}>The earlier you join, the better your options. Hostel spots and compatible matches both run out as matriculation gets closer.</p>

        <div style={s.cta}>
          <p style={{ fontSize: 18, fontWeight: 900, marginBottom: 8 }}>Find your roommate on UNIFY — free</p>
          <p style={{ fontSize: 14, color: 'rgba(255,255,255,0.6)', marginBottom: 0 }}>Fill your profile, get matched, and secure your person before orientation chaos starts.</p>
          <a href="/#waitlist" style={s.ctaBtn}>Claim Your Spot →</a>
        </div>
      </article>

      <footer style={s.footer}>
        <p>© 2026 UNIFY Ghana. <a href="/blog" style={{ color: 'rgba(255,255,255,0.8)', textDecoration: 'none' }}>Blog</a> · <a href="/faq" style={{ color: 'rgba(255,255,255,0.8)', textDecoration: 'none' }}>FAQ</a></p>
      </footer>
    </div>
  );
}
