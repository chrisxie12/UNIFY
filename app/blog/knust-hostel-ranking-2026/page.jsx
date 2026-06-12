export const metadata = {
  title: 'KNUST Hostel Ranking 2026: Brunei vs Kotei vs Unity — UNIFY Blog',
  description: "We compared WiFi, water supply, proximity to lectures, and social life across KNUST's top hostels. Here's the honest 2026 ranking before you commit.",
};

const sharedStyles = {
  page: { fontFamily: "'Inter', system-ui, sans-serif", background: '#F4F4F0', minHeight: '100vh' },
  nav: { borderBottom: '1px solid rgba(0,0,0,0.15)', padding: '0 24px' },
  navInner: { maxWidth: 720, margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 56 },
  navLogo: { fontWeight: 800, textDecoration: 'none', fontSize: '1rem' },
  navLink: { color: '#555', textDecoration: 'none', fontSize: '0.9rem' },
  article: { maxWidth: 720, margin: '0 auto', padding: '48px 24px 80px' },
  backLink: { color: '#555', textDecoration: 'none', fontSize: '0.875rem', display: 'inline-block', marginBottom: 32 },
  tag: { display: 'inline-block', background: 'rgba(255,107,53,0.1)', color: '#FF6B35', fontSize: '0.78rem', fontWeight: 700, padding: '3px 12px', borderRadius: 0, marginBottom: 16, letterSpacing: '0.02em' },
  meta: { color: '#777', fontSize: '0.875rem', marginBottom: 40, display: 'flex', gap: 16 },
  h1: { fontSize: '2.5rem', fontWeight: 800, margin: '0 0 16px', lineHeight: 1.2, letterSpacing: '-0.5px' },
  h2: { fontSize: '1.5rem', fontWeight: 700, margin: '48px 0 16px', paddingBottom: 10, borderBottom: '1px solid rgba(0,0,0,0.15)' },
  body: { fontSize: '1.1rem', color: '#333', lineHeight: 1.8, margin: '0 0 20px' },
  table: { width: '100%', borderCollapse: 'collapse', margin: '24px 0 32px', fontSize: '0.95rem' },
  th: { background: '#FF6B35', color: '#111', fontWeight: 700, padding: '12px', textAlign: 'left', border: '2px solid #000' },
  td: { padding: '12px', border: '2px solid #000', color: '#333', lineHeight: 1.5 },
  quote: { borderLeft: '4px solid #0066FF', background: '#FFFFFF', padding: '16px 20px', borderRadius: 0, margin: '20px 0', fontStyle: 'italic', color: '#333', fontSize: '1rem', lineHeight: 1.7 },
  cta: { marginTop: 56, background: '#FFFFFF', border: '2px solid #000', borderRadius: 0, padding: '36px', textAlign: 'center' },
  ctaBtn: { display: 'inline-block', background: '#FF6B35', color: '#fff', padding: '14px 32px', borderRadius: 0, textDecoration: 'none', fontWeight: 700, fontSize: '1rem', marginTop: 16 },
  footer: { background: '#FF6B35', padding: '32px 24px', textAlign: 'center' },
  footerText: { color: '#fff', fontWeight: 800, fontSize: '1rem' },
  footerSub: { color: '#555', fontSize: '0.8rem', marginTop: 4 },
};

export default function KnustHostelRankingPage() {
  return (
    <div style={sharedStyles.page}>
      {/* Nav */}
      <nav style={sharedStyles.nav}>
        <div style={sharedStyles.navInner}>
          <a href="/" style={sharedStyles.navLogo}>← UNIFY</a>
          <a href="/blog" style={sharedStyles.navLink}>Blog</a>
        </div>
      </nav>

      {/* Article */}
      <article style={sharedStyles.article}>
        <a href="/blog" style={sharedStyles.backLink}>← All Posts</a>

        <div style={sharedStyles.tag}>KNUST</div>
        <h1 style={sharedStyles.h1}>KNUST Hostel Ranking 2026: Brunei vs Kotei vs Unity</h1>

        <div style={sharedStyles.meta}>
          <span>5 min read</span>
          <span>·</span>
          <span>June 2026</span>
        </div>

        <p style={sharedStyles.body}>
          Moving into KNUST without insider knowledge is rough. Everyone tells you to &quot;just pick a hostel,&quot; but nobody explains what that decision actually costs you — in sleep quality, commute time, water supply reliability, and how your entire first semester feels. We spent time collecting real student feedback so you can make an informed decision before rooms fill up.
        </p>
        <p style={sharedStyles.body}>
          The choice of hostel at KNUST is less about preference and more about personality. Are you someone who needs silence to study? Or do you thrive on energy and social connection? Different halls attract different types, and the infrastructure genuinely varies. Here is the complete breakdown.
        </p>

        <h2 style={sharedStyles.h2}>The Big Three: Brunei, Kotei, Unity Hall</h2>
        <p style={sharedStyles.body}>
          When KNUST freshers talk about where to stay, three names come up every time: Brunei Hostel, the Kotei residential area, and Unity Hall. Each serves a different kind of student. Brunei sits close to campus and offers a well-maintained social environment. Kotei stretches further out and suits those who want more quiet and lower cost. Unity Hall is legacy — a brotherhood institution with its own culture, songs, and identity that runs deep. Choosing between them is as much about who you want to become in your first year as it is about logistics.
        </p>

        <table style={sharedStyles.table}>
          <thead>
            <tr>
              <th style={sharedStyles.th}>Hall</th>
              <th style={sharedStyles.th}>WiFi</th>
              <th style={sharedStyles.th}>Water</th>
              <th style={sharedStyles.th}>Walk to Lectures</th>
              <th style={sharedStyles.th}>Vibe</th>
              <th style={sharedStyles.th}>Price Range</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style={{ ...sharedStyles.td, fontWeight: 600 }}>Brunei Hostel</td>
              <td style={sharedStyles.td}>Good</td>
              <td style={sharedStyles.td}>Reliable</td>
              <td style={sharedStyles.td}>~8 min</td>
              <td style={sharedStyles.td}>Social / Mixed</td>
              <td style={sharedStyles.td}>GH₵ 800–1,200/sem</td>
            </tr>
            <tr>
              <td style={{ ...sharedStyles.td, fontWeight: 600 }}>Kotei Area</td>
              <td style={sharedStyles.td}>Variable</td>
              <td style={sharedStyles.td}>Sometimes cut</td>
              <td style={sharedStyles.td}>15–20 min</td>
              <td style={sharedStyles.td}>Quieter / Study</td>
              <td style={sharedStyles.td}>GH₵ 600–900/sem</td>
            </tr>
            <tr>
              <td style={{ ...sharedStyles.td, fontWeight: 600 }}>Unity Hall</td>
              <td style={sharedStyles.td}>Weak in some blocks</td>
              <td style={sharedStyles.td}>Reliable</td>
              <td style={sharedStyles.td}>~5 min</td>
              <td style={sharedStyles.td}>Brotherhood / Loud</td>
              <td style={sharedStyles.td}>GH₵ 700–1,000/sem</td>
            </tr>
          </tbody>
        </table>

        <h2 style={sharedStyles.h2}>Evandy &amp; TF Hostel (Honourable Mentions)</h2>
        <p style={sharedStyles.body}>
          Not everyone ends up in the big three — and for some students, that&apos;s intentional. Evandy Hostel is a popular private option just off the main campus axis. It tends to attract students who want a slightly more independent living arrangement without the heavy hall culture. The facilities are decent, the water supply has generally been consistent, and it gives you a bit more breathing room than the packed main hostels. TF Hostel (short for Torture Factory — a nickname students gave it affectionately) is another off-campus option known for tight rooms and a grind culture. Despite the name, students who stay there tend to bond hard and perform academically. If you want a no-frills place to focus and save money, these two are worth considering, especially if campus accommodation is already full by the time you arrive.
        </p>

        <h2 style={sharedStyles.h2}>What Freshers Actually Say</h2>

        <div style={sharedStyles.quote}>
          &quot;I chose Brunei because it was close and my seniors said the vibe was good. They were right. I made most of my friends on my floor in the first two weeks. Yes, it costs more — but that social foundation was worth it for me.&quot;
          <br /><br />
          <strong>— Abena K., BSc Computer Science, Level 200</strong>
        </div>

        <div style={sharedStyles.quote}>
          &quot;Kotei saved me real money and I genuinely liked the quieter environment. The commute adds up if you have early morning lectures, so I got a bicycle. Problem solved. The water cut twice in semester one and that was rough, but manageable.&quot;
          <br /><br />
          <strong>— Kwabena Mensah, BSc Civil Engineering, Level 200</strong>
        </div>

        <div style={sharedStyles.quote}>
          &quot;Unity Hall is an experience, full stop. I cannot explain the culture to someone who wasn&apos;t there. The chants, the hall spirit, the solidarity — I felt like I belonged to something bigger than just a hostel. The WiFi situation in my block was bad though, I won&apos;t lie. Get a data plan as a backup.&quot;
          <br /><br />
          <strong>— Kofi Asante, BSc Electrical Engineering, Level 300</strong>
        </div>

        <h2 style={sharedStyles.h2}>Our Verdict</h2>
        <p style={sharedStyles.body}>
          <strong>Brunei Hostel</strong> is our top pick for freshers who are new to Kumasi and want to ease into campus life through social connection. The proximity to lecture halls, reliable water, and better WiFi make the higher cost justifiable in your first year when you are still figuring things out.
        </p>
        <p style={sharedStyles.body}>
          <strong>Kotei</strong> is the right call for students who are already self-disciplined, know how to study independently, and want to stretch their budget. You will need to sort out transport for early lectures and accept that some services are less reliable — but you will save GH₵ 200–400 per semester.
        </p>
        <p style={sharedStyles.body}>
          <strong>Unity Hall</strong> is for the student who wants the full KNUST brotherhood experience. If campus culture, identity, and lasting bonds matter to you, there is nowhere else like it. Just budget for mobile data and manage expectations on WiFi.
        </p>
        <p style={sharedStyles.body}>
          Whatever you choose, do not wait. Rooms — especially in Brunei — fill up fast once admission letters go out. Sort your hostel and your roommate situation as early as possible.
        </p>

        {/* CTA */}
        <div style={sharedStyles.cta}>
          <p style={{ fontSize: '1.1rem', fontWeight: 700, margin: '0 0 8px' }}>Ready to find your KNUST roommate?</p>
          <p style={{ color: '#555', fontSize: '0.95rem', margin: 0 }}>
            Don&apos;t end up with a random match on the first day. Get on UNIFY and connect with compatible freshers before halls fill up.
          </p>
          <a href="/#waitlist" style={sharedStyles.ctaBtn}>
            Find your KNUST roommate on UNIFY →
          </a>
        </div>
      </article>

      {/* Footer */}
      <footer style={sharedStyles.footer}>
        <p style={sharedStyles.footerText}>UNIFY GH</p>
        <p style={sharedStyles.footerSub}>© 2026 UNIFY. All rights reserved.</p>
      </footer>
    </div>
  );
}
