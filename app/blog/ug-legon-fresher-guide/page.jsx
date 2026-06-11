export const metadata = {
  title: 'UG Legon Fresher Guide: What Nobody Tells You — UNIFY Blog',
  description: "The packing list, registration hacks, best food spots on campus, and how to beat the portal queue — the guide UG Legon freshers actually need.",
};

const s = {
  page: { fontFamily: "'Inter', system-ui, sans-serif", background: '#0D1B3E', minHeight: '100vh' },
  nav: { borderBottom: '1px solid rgba(255,255,255,0.1)', padding: '0 24px' },
  navInner: { maxWidth: 720, margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 56 },
  navLogo: { fontWeight: 800, textDecoration: 'none', fontSize: '1rem' },
  navLink: { color: 'rgba(255,255,255,0.6)', textDecoration: 'none', fontSize: '0.9rem' },
  article: { maxWidth: 720, margin: '0 auto', padding: '48px 24px 80px' },
  backLink: { color: 'rgba(255,255,255,0.6)', textDecoration: 'none', fontSize: '0.875rem', display: 'inline-block', marginBottom: 32 },
  tag: { display: 'inline-block', background: 'rgba(244,196,48,0.1)', color: '#FF6B35', fontSize: '0.78rem', fontWeight: 700, padding: '3px 12px', borderRadius: 0, marginBottom: 16, letterSpacing: '0.02em' },
  meta: { color: 'rgba(255,255,255,0.4)', fontSize: '0.875rem', marginBottom: 40, display: 'flex', gap: 16 },
  h1: { fontSize: '2.5rem', fontWeight: 800, margin: '0 0 16px', lineHeight: 1.2, letterSpacing: '-0.5px' },
  h2: { fontSize: '1.5rem', fontWeight: 700, margin: '48px 0 16px', paddingBottom: 10, borderBottom: '1px solid rgba(255,255,255,0.1)' },
  body: { fontSize: '1.1rem', color: 'rgba(255,255,255,0.8)', lineHeight: 1.8, margin: '0 0 20px' },
  li: { fontSize: '1.05rem', color: 'rgba(255,255,255,0.8)', lineHeight: 1.8, marginBottom: 10 },
  quote: { borderLeft: '4px solid #0066FF', background: '#162347', padding: '16px 20px', borderRadius: 0, margin: '20px 0', fontStyle: 'italic', color: 'rgba(255,255,255,0.8)', fontSize: '1rem', lineHeight: 1.7 },
  cta: { marginTop: 56, background: '#162347', border: '1px solid rgba(255,255,255,0.1)', borderRadius: 0, padding: '36px', textAlign: 'center' },
  ctaBtn: { display: 'inline-block', background: '#FF6B35', color: '#fff', padding: '14px 32px', borderRadius: 0, textDecoration: 'none', fontWeight: 700, fontSize: '1rem', marginTop: 16 },
  footer: { background: '#FF6B35', padding: '32px 24px', textAlign: 'center' },
  footerText: { color: '#fff', fontWeight: 800, fontSize: '1rem' },
  footerSub: { color: 'rgba(255,255,255,0.7)', fontSize: '0.8rem', marginTop: 4 },
};

export default function UGLegonFresherGuidePage() {
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

        <div style={s.tag}>UG Legon</div>
        <h1 style={s.h1}>UG Legon Fresher Guide: What Nobody Tells You</h1>

        <div style={s.meta}>
          <span>6 min read</span>
          <span>·</span>
          <span>June 2026</span>
        </div>

        <p style={s.body}>
          Legon is beautiful. The Balme Library, the tree-lined walkways, the sense that you have arrived somewhere real — it hits you on day one. Then week two starts, the student portal crashes during course registration, your hall bathroom has no running water, and you realise nobody gave you the real orientation. This guide is the one you should have gotten on admission day.
        </p>
        <p style={s.body}>
          The University of Ghana is Ghana&apos;s oldest and most prestigious university, and that prestige comes with both genuine advantages and a bureaucracy that will test your patience. The good news: students who know the system navigate it fine. The bad news: most freshers learn through pain. Here is how to skip that.
        </p>

        <h2 style={s.h2}>Registration Hack: Beat the Portal Queue</h2>
        <p style={s.body}>
          The UG student portal is one of the most frustrating systems you will encounter. Thousands of freshers try to register for courses in the same narrow window, and the server buckles under the load. Here is how to get ahead:
        </p>
        <ul>
          <li style={s.li}><strong>Register at 6am.</strong> Seriously. Set an alarm. The server load is lowest in the early morning hours before most students wake up. Students who log in at 8am or later often find the portal timing out repeatedly.</li>
          <li style={s.li}><strong>Have your student ID and programme code ready before you sit down.</strong> The portal times out fast. Any delay on your end kills your session. Know your programme code by heart — find it on your admission letter and write it somewhere visible.</li>
          <li style={s.li}><strong>Use a laptop, not a phone.</strong> The portal is not optimised for mobile. Sessions drop more frequently on phone browsers. A laptop on a stable WiFi connection (try the Balme Library WiFi early morning) gives you the best shot.</li>
          <li style={s.li}><strong>Screenshot every confirmation page.</strong> The system sometimes processes your registration but doesn&apos;t show a confirmation. Screenshot whatever you see and save it. If there is a dispute later, you have evidence.</li>
        </ul>

        <h2 style={s.h2}>What to Actually Pack</h2>
        <p style={s.body}>
          Packing lists online are usually written by people who have never been to a Ghanaian university hall. Here is what actually matters:
        </p>
        <ul>
          <li style={s.li}><strong>Power strip (4-gang minimum).</strong> Hall rooms typically have one or two sockets shared between two or more people. A power strip is non-negotiable for your phone, laptop, fan, and anything else you run simultaneously.</li>
          <li style={s.li}><strong>Bucket and padlock.</strong> Shared hall bathrooms at Legon operate on a bring-your-own-bucket basis. A padlock for your locker or room valuables is equally essential — don&apos;t leave anything unattended in open spaces.</li>
          <li style={s.li}><strong>Mosquito net.</strong> Legon mosquitoes are a well-documented menace. The campus is green and beautiful, which also means it is prime mosquito territory. A treated net is GH₵ 30–60 and worth every pesewa.</li>
          <li style={s.li}><strong>Printed copies of all admission documents.</strong> UG admin offices will ask for physical copies of documents at unexpected moments — your admission letter, WASSCE results, medical form. Bring three printed copies of everything. The printing shops on campus are always packed.</li>
          <li style={s.li}><strong>A small fan.</strong> Hall rooms get hot, especially in the early months. The ceiling fans in some halls are unreliable. A personal desk or clip fan is a quality-of-life upgrade that makes studying and sleeping manageable.</li>
        </ul>

        <h2 style={s.h2}>Best Food Spots on Campus</h2>
        <p style={s.body}>
          Legon has a surprisingly decent food ecosystem once you know where to look. The hall canteens are functional but repetitive. Branch out early:
        </p>
        <ul>
          <li style={s.li}><strong>Okponglo Junction.</strong> A short walk or trotro ride from the main campus gate, Okponglo has a row of food spots selling jollof rice, fried rice, kelewele, and grilled chicken at prices students can actually afford. GH₵ 20–40 gets you a full plate. This is a staple destination, especially after evening lectures.</li>
          <li style={s.li}><strong>Night Market (after 8pm).</strong> Once the sun goes down, a cluster of food vendors sets up near the main halls. Indomie, egg sandwiches, fried yam, fresh juice. It is late-night student fuel and social spot in one. Go at least once a week.</li>
          <li style={s.li}><strong>Balme Library Canteen.</strong> For a quick, no-fuss lunch between lectures. The portions are decent and the location is central. Expect to wait a few minutes at peak time, but it moves fast.</li>
          <li style={s.li}><strong>JQB (Junction near Quality Bakers area).</strong> A longtime student favourite near campus. Known for affordable rice dishes and a vibe that feels less rushed than the on-campus spots. Ask any second-year student and they will know exactly where this is.</li>
        </ul>

        <h2 style={s.h2}>Halls: What to Know Before You Choose</h2>
        <p style={s.body}>
          Not all UG halls are created equal. Each has a personality, and understanding that before you arrive helps you set expectations:
        </p>
        <ul>
          <li style={s.li}><strong>Commonwealth Hall (Vandal City).</strong> The most storied male hall on campus. Loud, high-energy, and built on a culture of brotherhood and hall pride. If you want the social experience, Vandal City delivers. If you need quiet nights for studying, it may not be your fit.</li>
          <li style={s.li}><strong>Volta Hall.</strong> A female-only hall with a reputation for being well-maintained and relatively calm. Popular among students who prioritise safety and a stable environment. Waiting list can be long.</li>
          <li style={s.li}><strong>Limann Hall.</strong> One of the newer halls. Quieter, slightly further from the main lecture areas, but in better physical condition than some of the older halls. Good for students who want modern facilities over legacy culture.</li>
          <li style={s.li}><strong>Mensah Sarbah Hall.</strong> Central location, mix of academic and social culture. One of the more balanced options — you are close to everything, the vibe is not extreme either way, and it houses a significant number of freshers.</li>
        </ul>

        <h2 style={s.h2}>The One Thing Everyone Regrets</h2>
        <p style={s.body}>
          Ask any UG second-year student what they wish they had done differently in their first semester and a surprising number give the same answer: they waited too long to link up with coursemates.
        </p>
        <div style={s.quote}>
          By week two, WhatsApp groups are formed, study partners are paired, and the social fabric of your year group has already started to set. Breaking into that later is genuinely harder — not impossible, but harder. The students who arrive with connections already in place — even just knowing three or four people in their programme — enter those first weeks with confidence and end up embedded in the right circles faster.
        </div>
        <p style={s.body}>
          This is not about being an extrovert. It is about not starting from zero on a campus of thousands. Finding your people before orientation — even via a roommate matching platform or a programme WhatsApp group — changes everything about how those first few weeks feel.
        </p>

        {/* CTA */}
        <div style={s.cta}>
          <p style={{ fontSize: '1.1rem', fontWeight: 700, margin: '0 0 8px' }}>Don&apos;t go to Legon cold.</p>
          <p style={{ color: 'rgba(255,255,255,0.6)', fontSize: '0.95rem', margin: 0 }}>
            UNIFY matches you with compatible freshers at your school before orientation. Start your year with your people already found.
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

