export const metadata = {
  title: 'Hostel Hubs — UNIFY Ghana',
  description:
    'Real intel on KNUST, UG Legon, and UCC hostels from students already living there. Brunei, Kotei, Volta Hall, Limann, Casford and more.',
};

// ─── HUB DATA ─────────────────────────────────────────────────────────────────

const HUBS = [
  // KNUST
  {
    id: 'brunei',
    name: 'Brunei Hostel',
    school: 'KNUST',
    location: 'Kotei, Kumasi',
    residents: 420,
    type: 'Off-campus',
    vibe: ['Tech Heads', 'Night Coders', 'Quiet Block'],
    color: 'emerald',
    description:
      'The most popular off-campus zone for KNUST CS and Engineering students. Close to Faculty of Computing, walkable to campus gate.',
    perks: ['Fast MTN signal', 'Backup generator', '24hr security', 'Close to Kotei market'],
  },
  {
    id: 'kotei',
    name: 'Kotei Hostels',
    school: 'KNUST',
    location: 'Kotei, Kumasi',
    residents: 680,
    type: 'Off-campus',
    vibe: ['Mixed Vibes', 'Social', 'Uber Splitters'],
    color: 'green',
    description:
      'Broad residential area with dozens of private hostels. Budget-friendly options exist. Popular among all faculties.',
    perks: ['Multiple price tiers', 'Near Kotei Junction', 'Trotro access', 'Shops nearby'],
  },
  {
    id: 'unity',
    name: 'Unity Hall',
    school: 'KNUST',
    location: 'KNUST Main Campus',
    residents: 890,
    type: 'On-campus',
    vibe: ['Social', 'Traditions', 'Katanga Rivals'],
    color: 'blue',
    description:
      'One of the oldest and most spirited halls on campus. Brotherhood culture is strong. Close to the Great Hall and SRC.',
    perks: ['On-campus location', 'Hall Week events', 'Close to lecture halls', 'Dining hall access'],
  },
  {
    id: 'katanga',
    name: 'Katanga Hall',
    school: 'KNUST',
    location: 'KNUST Main Campus',
    residents: 760,
    type: 'On-campus',
    vibe: ['Brotherhood', 'Sporty', 'Loud & Proud'],
    color: 'amber',
    description:
      'The most legendary hall at KNUST. Famous for hall week, sports dominance, and a culture freshers either love or find intense.',
    perks: ['Strong hall culture', 'Sports facilities', 'Central location', 'Dining hall'],
  },
  // UCC
  {
    id: 'evandy',
    name: 'Evandy Hostel',
    school: 'UCC',
    location: 'Cape Coast Campus',
    residents: 340,
    type: 'Off-campus',
    vibe: ['Quiet Study', 'Neat Freaks', 'Medical Students'],
    color: 'violet',
    description:
      'Top choice for UCC Nursing and Allied Health students. Quiet environment, good water supply, close to the School of Medical Sciences.',
    perks: ['Good water supply', 'Quiet floors', 'Close to Medical School', 'Female-friendly'],
  },
  {
    id: 'tf',
    name: 'TF Hostel',
    school: 'UCC',
    location: 'Cape Coast Campus',
    residents: 290,
    type: 'Off-campus',
    vibe: ['Affordable', 'Mixed', 'Social Floor'],
    color: 'sky',
    description:
      'Budget-friendly and centrally located. Known for its social atmosphere. A solid first-year option for UCC freshers.',
    perks: ['Affordable rates', 'Central location', 'Social common areas', 'Near campus gate'],
  },
  {
    id: 'casford',
    name: 'Casford Hall',
    school: 'UCC',
    location: 'Cape Coast Campus',
    residents: 445,
    type: 'On-campus',
    vibe: ['Academic', 'Disciplined', 'Early Risers'],
    color: 'teal',
    description:
      'On-campus hall known for academic focus and discipline. Great for students serious about their first year GPA.',
    perks: ['On-campus location', 'Quiet study environment', 'Close to lecture halls', 'Organized hall structure'],
  },
  // UG Legon
  {
    id: 'volta',
    name: 'Volta Hall',
    school: 'UG Legon',
    location: 'University of Ghana',
    residents: 510,
    type: 'On-campus',
    vibe: ['Sisterhood', 'Scholars', 'Night Library Runs'],
    color: 'rose',
    description:
      'The most prestigious female hall at Legon. Strong academic culture, beautiful grounds, and a tight-knit sisterhood community.',
    perks: ['Female-only', 'Library access', 'Stunning grounds', 'Strong alumnae network'],
  },
  {
    id: 'limann',
    name: 'Limann Hall',
    school: 'UG Legon',
    location: 'University of Ghana',
    residents: 390,
    type: 'On-campus',
    vibe: ['Mixed', 'Chill', 'Good Wi-Fi'],
    color: 'blue',
    description:
      'A newer hall at Legon with modern facilities. Popular with Business and Social Sciences students. Good internet infrastructure.',
    perks: ['Modern facilities', 'Better Wi-Fi', 'Mixed gender floors', 'Close to Balme Library'],
  },
  {
    id: 'commonwealth',
    name: 'Commonwealth Hall',
    school: 'UG Legon',
    location: 'University of Ghana',
    residents: 820,
    type: 'On-campus',
    vibe: ['Brotherhood', 'Vandal Nation', 'Legendary'],
    color: 'amber',
    description:
      'The most famous male hall at Legon. Home of the Vandals. Massive culture, hall week is unmissable. Brotherhood is for life.',
    perks: ['Iconic hall culture', 'Sports dominance', 'Central to campus', 'Strong alumni network'],
  },
];

// ─── COLOR MAP ────────────────────────────────────────────────────────────────

const COLOR_MAP = {
  emerald: {
    border: 'border-emerald-500/20',
    bg: 'bg-emerald-500/[0.04]',
    accent: 'text-emerald-400',
    topBar: 'bg-emerald-500/30',
    pill: 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20',
  },
  green: {
    border: 'border-green-500/20',
    bg: 'bg-green-500/[0.04]',
    accent: 'text-green-400',
    topBar: 'bg-green-500/30',
    pill: 'bg-green-500/10 text-green-400 border-green-500/20',
  },
  blue: {
    border: 'border-blue-500/20',
    bg: 'bg-blue-500/[0.04]',
    accent: 'text-blue-400',
    topBar: 'bg-blue-500/30',
    pill: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
  },
  amber: {
    border: 'border-amber-500/20',
    bg: 'bg-amber-500/[0.04]',
    accent: 'text-amber-400',
    topBar: 'bg-amber-500/30',
    pill: 'bg-amber-500/10 text-amber-400 border-amber-500/20',
  },
  violet: {
    border: 'border-violet-500/20',
    bg: 'bg-violet-500/[0.04]',
    accent: 'text-violet-400',
    topBar: 'bg-violet-500/30',
    pill: 'bg-violet-500/10 text-violet-400 border-violet-500/20',
  },
  sky: {
    border: 'border-sky-500/20',
    bg: 'bg-sky-500/[0.04]',
    accent: 'text-sky-400',
    topBar: 'bg-sky-500/30',
    pill: 'bg-sky-500/10 text-sky-400 border-sky-500/20',
  },
  rose: {
    border: 'border-rose-500/20',
    bg: 'bg-rose-500/[0.04]',
    accent: 'text-rose-400',
    topBar: 'bg-rose-500/30',
    pill: 'bg-rose-500/10 text-rose-400 border-rose-500/20',
  },
  teal: {
    border: 'border-teal-500/20',
    bg: 'bg-teal-500/[0.04]',
    accent: 'text-teal-400',
    topBar: 'bg-teal-500/30',
    pill: 'bg-teal-500/10 text-teal-400 border-teal-500/20',
  },
};

// ─── SCHOOL GROUPS ────────────────────────────────────────────────────────────

const SCHOOL_GROUPS = [
  {
    id: 'knust',
    label: 'KNUST',
    full: 'Kwame Nkrumah University of Science & Technology',
    hubs: HUBS.filter((h) => h.school === 'KNUST'),
  },
  {
    id: 'ug-legon',
    label: 'UG Legon',
    full: 'University of Ghana, Legon',
    hubs: HUBS.filter((h) => h.school === 'UG Legon'),
  },
  {
    id: 'ucc',
    label: 'UCC',
    full: 'University of Cape Coast',
    hubs: HUBS.filter((h) => h.school === 'UCC'),
  },
];

// ─── HUB CARD COMPONENT ───────────────────────────────────────────────────────

function HubCard({ hub }) {
  const c = COLOR_MAP[hub.color] || COLOR_MAP.blue;

  return (
    <div
      className={`relative rounded-2xl border ${c.border} ${c.bg} overflow-hidden flex flex-col`}
    >
      {/* Top accent bar */}
      <div className={`h-1 w-full ${c.topBar}`} />

      <div className="p-6 flex flex-col flex-1 gap-4">
        {/* Header */}
        <div className="flex flex-col gap-2">
          <div className="flex items-start justify-between gap-2 flex-wrap">
            <h3 className="text-xl font-bold text-white leading-tight">{hub.name}</h3>
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-white/[0.07] border border-white/[0.1] text-white/70">
                {hub.school}
              </span>
              <span
                className={`text-xs font-semibold px-2 py-0.5 rounded-full border ${
                  hub.type === 'On-campus'
                    ? 'bg-green-500/10 border-green-500/20 text-green-400'
                    : 'bg-orange-500/10 border-orange-500/20 text-orange-400'
                }`}
              >
                {hub.type}
              </span>
            </div>
          </div>

          {/* Location + residents */}
          <div className="flex items-center gap-4 flex-wrap">
            <span className="text-sm text-white/50 flex items-center gap-1">
              📍 {hub.location}
            </span>
            <span className={`text-sm font-semibold ${c.accent}`}>
              {hub.residents.toLocaleString()}+ freshers
            </span>
          </div>
        </div>

        {/* Description */}
        <p className="text-sm text-white/60 leading-relaxed">{hub.description}</p>

        {/* Perks */}
        <ul className="grid grid-cols-1 gap-1.5">
          {hub.perks.map((perk) => (
            <li key={perk} className="flex items-center gap-2 text-sm text-white/70">
              <span className={`font-bold ${c.accent}`}>✓</span>
              {perk}
            </li>
          ))}
        </ul>

        {/* Vibe tags */}
        <div className="flex flex-wrap gap-1.5">
          {hub.vibe.map((tag) => (
            <span
              key={tag}
              className={`text-xs font-medium px-2.5 py-1 rounded-full border ${c.pill}`}
            >
              {tag}
            </span>
          ))}
        </div>

        {/* CTA */}
        <div className="mt-auto pt-2">
          <a
            href="/#waitlist"
            className="flex items-center justify-center gap-2 w-full py-2.5 px-4 rounded-xl bg-amber-400 hover:bg-amber-300 text-[#050d20] text-sm font-bold transition-colors"
          >
            Join {hub.name} Hub →
          </a>
        </div>
      </div>
    </div>
  );
}

// ─── PAGE ─────────────────────────────────────────────────────────────────────

export default function HubsPage() {
  const totalResidents = HUBS.reduce((sum, h) => sum + h.residents, 0);

  return (
    <div
      style={{ fontFamily: 'system-ui, Inter, sans-serif', backgroundColor: '#050d20' }}
      className="min-h-screen text-white"
    >
      {/* ── NAV ─────────────────────────────────────────────────────────────── */}
      <nav className="fixed top-0 left-0 right-0 z-50 border-b border-white/[0.05] bg-[#050d20]/80 backdrop-blur-2xl h-16">
        <div className="max-w-6xl mx-auto h-full px-6 flex items-center justify-between">
          {/* Logo */}
          <a href="/" className="flex items-center gap-2 no-underline">
            <span className="text-xl font-black tracking-tight text-white">
              UNI<span className="text-amber-400">FY</span>
            </span>
          </a>

          {/* Center links */}
          <div className="hidden md:flex items-center gap-6">
            <a href="/#features" className="text-sm text-white/60 hover:text-white transition-colors">
              Features
            </a>
            <a href="/hubs" className="text-sm text-amber-400 font-medium">
              Hubs
            </a>
            <a href="/#freshers" className="text-sm text-white/60 hover:text-white transition-colors">
              Meet Freshers
            </a>
          </div>

          {/* CTA */}
          <a
            href="/#waitlist"
            className="px-4 py-2 rounded-xl bg-amber-400 hover:bg-amber-300 text-[#050d20] text-sm font-bold transition-colors whitespace-nowrap"
          >
            Get Early Access →
          </a>
        </div>
      </nav>

      {/* ── HERO ─────────────────────────────────────────────────────────────── */}
      <section className="pt-32 pb-16 px-6 text-center">
        <div className="max-w-3xl mx-auto">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/[0.04] border border-white/[0.08] text-white/60 text-sm mb-6">
            <span className="w-2 h-2 rounded-full bg-amber-400 inline-block" />
            10 active hubs · Growing
          </div>

          <h1 className="text-4xl md:text-5xl lg:text-6xl font-black text-white leading-tight mb-6">
            Find your people before
            <br />
            <span className="text-amber-400">you find your room.</span>
          </h1>

          <p className="text-lg md:text-xl text-white/60 max-w-xl mx-auto leading-relaxed">
            Real intel on hostels and halls from students already living there.{' '}
            <span className="text-white/80">No sugarcoating.</span>
          </p>

          {/* Ghana flag stripe */}
          <div className="h-1 w-24 mx-auto mt-6 rounded-full bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />

          {/* Stats */}
          <div className="mt-10 flex items-center justify-center gap-8 flex-wrap">
            <div className="text-center">
              <p className="text-3xl font-black text-amber-400">{HUBS.length}</p>
              <p className="text-xs text-white/50 mt-0.5">Active Hubs</p>
            </div>
            <div className="w-px h-8 bg-white/[0.07]" />
            <div className="text-center">
              <p className="text-3xl font-black text-white">{totalResidents.toLocaleString()}+</p>
              <p className="text-xs text-white/50 mt-0.5">Fresher Residents</p>
            </div>
            <div className="w-px h-8 bg-white/[0.07]" />
            <div className="text-center">
              <p className="text-3xl font-black text-green-400">3</p>
              <p className="text-xs text-white/50 mt-0.5">Universities</p>
            </div>
          </div>
        </div>
      </section>

      {/* ── FILTER TABS ──────────────────────────────────────────────────────── */}
      <div className="flex justify-center gap-2 px-6 flex-wrap">
        <a
          href="#hubs-top"
          className="px-4 py-2 rounded-full text-sm font-medium border transition-colors bg-amber-400/10 border-amber-400/30 text-amber-400"
        >
          All Hubs
        </a>
        {SCHOOL_GROUPS.map((school) => (
          <a
            key={school.id}
            href={`#${school.id}`}
            className="px-4 py-2 rounded-full text-sm font-medium border transition-colors bg-white/[0.04] border-white/[0.07] text-white/50 hover:bg-amber-400/10 hover:border-amber-400/30 hover:text-amber-400"
          >
            {school.label}
          </a>
        ))}
      </div>

      {/* ── HUB GRID ─────────────────────────────────────────────────────────── */}
      <div id="hubs-top" className="max-w-7xl mx-auto px-6 pb-24 mt-14 space-y-20">
        {SCHOOL_GROUPS.map((school) => {
          const schoolResidents = school.hubs.reduce((sum, h) => sum + h.residents, 0);
          return (
            <section key={school.id} id={school.id}>
              {/* School header */}
              <div className="flex flex-col sm:flex-row sm:items-end gap-3 mb-8">
                <div>
                  <h2 className="text-2xl md:text-3xl font-black text-white">
                    {school.label} Hubs
                  </h2>
                  <p className="text-sm text-white/40 mt-1">{school.full}</p>
                </div>
                <div className="sm:ml-auto flex items-center gap-3">
                  <span className="text-sm text-white/50">
                    {school.hubs.length} hubs ·{' '}
                    <span className="text-amber-400 font-semibold">
                      {schoolResidents.toLocaleString()}+ residents
                    </span>
                  </span>
                </div>
              </div>

              {/* Cards grid */}
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
                {school.hubs.map((hub) => (
                  <HubCard key={hub.id} hub={hub} />
                ))}
              </div>
            </section>
          );
        })}
      </div>

      {/* ── BOTTOM CTA ───────────────────────────────────────────────────────── */}
      <section className="px-6 pb-24">
        <div className="max-w-2xl mx-auto text-center rounded-2xl border border-white/[0.07] bg-white/[0.03] p-12">
          {/* Icon */}
          <div className="w-16 h-16 rounded-2xl bg-amber-400/10 border border-amber-400/20 flex items-center justify-center mx-auto mb-6 text-2xl">
            🏠
          </div>

          <h2 className="text-3xl md:text-4xl font-black text-white mb-4">
            Your hostel hub is waiting.
          </h2>

          <p className="text-white/60 text-lg mb-8 leading-relaxed">
            Sign up to get notified{' '}
            <span className="text-amber-400 font-semibold">48hrs before your hub goes live.</span>{' '}
            Be first in. Link early. Walk into orientation knowing people.
          </p>

          <a
            href="/#waitlist"
            className="inline-flex items-center gap-2 px-8 py-3.5 rounded-xl bg-amber-400 hover:bg-amber-300 text-[#050d20] font-bold text-base transition-colors"
          >
            Claim Your Handle →
          </a>

          <p className="text-white/30 text-xs mt-6">
            Free · No spam · Ghana university freshers only
          </p>
        </div>
      </section>

      {/* ── FOOTER ───────────────────────────────────────────────────────────── */}
      <footer className="border-t border-white/[0.05] px-6 py-8">
        <div className="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-white/30 text-sm">
            © 2026 UNIFY · Ghana 🇬🇭 · Built for freshers
          </p>
          <div className="flex items-center gap-6">
            <a href="/" className="text-sm text-white/30 hover:text-white/60 transition-colors">
              Home
            </a>
            <a href="/hubs" className="text-sm text-white/30 hover:text-white/60 transition-colors">
              Hubs
            </a>
            <a href="/#waitlist" className="text-sm text-amber-400/70 hover:text-amber-400 transition-colors">
              Get Early Access
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}
