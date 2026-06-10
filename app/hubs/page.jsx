import { MapPin, Check, ArrowRight, Users, Building2, Shield } from 'lucide-react';

export const metadata = {
  title: 'Hostel Hubs — UNIFY Ghana',
  description: 'Real intel on KNUST, UG Legon, and UCC hostels from students already living there. Brunei, Kotei, Volta Hall, Limann, Casford and more.',
};

const HUBS = [
  {
    id: 'brunei', name: 'Brunei Hostel', school: 'KNUST', location: 'Kotei, Kumasi',
    residents: 420, type: 'Off-campus', color: 'emerald',
    grad: 'linear-gradient(135deg,#059669,#0891b2)', initials: 'BR',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/College_of_Engineering,_KNUST,_Kumasi,_Ghana.JPG?width=600',
    vibe: ['Tech Heads', 'Night Coders', 'Quiet Block'],
    description: 'The most popular off-campus zone for KNUST CS and Engineering students. Close to Faculty of Computing, walkable to campus gate.',
    perks: ['Fast MTN signal', 'Backup generator', '24hr security', 'Close to Kotei market'],
  },
  {
    id: 'kotei', name: 'Kotei Hostels', school: 'KNUST', location: 'Kotei, Kumasi',
    residents: 680, type: 'Off-campus', color: 'green',
    grad: 'linear-gradient(135deg,#16a34a,#059669)', initials: 'KO',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/KNUST_main_entrance_with_Kwame_Nkrumah_Memorial_Park.jpg?width=600',
    vibe: ['Mixed Vibes', 'Social', 'Uber Splitters'],
    description: 'Broad residential area with dozens of private hostels. Budget-friendly options exist. Popular among all faculties.',
    perks: ['Multiple price tiers', 'Near Kotei Junction', 'Trotro access', 'Shops nearby'],
  },
  {
    id: 'unity', name: 'Unity Hall', school: 'KNUST', location: 'KNUST Main Campus',
    residents: 890, type: 'On-campus', color: 'blue',
    grad: 'linear-gradient(135deg,#0066FF,#6366f1)', initials: 'UN',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Kwame_Nkrumah_University_of_Science_and_Technology_(KNUST)_%E2%80%93_Side_view_of_the_College_of_Architecture_and_Planning.JPG?width=600',
    vibe: ['Social', 'Traditions', 'Katanga Rivals'],
    description: 'One of the oldest and most spirited halls on campus. Brotherhood culture is strong. Close to the Great Hall and SRC.',
    perks: ['On-campus location', 'Hall Week events', 'Close to lecture halls', 'Dining hall access'],
  },
  {
    id: 'katanga', name: 'Katanga Hall', school: 'KNUST', location: 'KNUST Main Campus',
    residents: 760, type: 'On-campus', color: 'orange',
    grad: 'linear-gradient(135deg,#FF6B35,#dc2626)', initials: 'KA',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/College_of_Engineering,_KNUST,_Kumasi,_Ghana.JPG?width=600',
    vibe: ['Brotherhood', 'Sporty', 'Loud & Proud'],
    description: 'The most legendary hall at KNUST. Famous for hall week, sports dominance, and a culture freshers either love or find intense.',
    perks: ['Strong hall culture', 'Sports facilities', 'Central location', 'Dining hall'],
  },
  {
    id: 'evandy', name: 'Evandy Hostel', school: 'UCC', location: 'Cape Coast Campus',
    residents: 340, type: 'Off-campus', color: 'violet',
    grad: 'linear-gradient(135deg,#7c3aed,#a855f7)', initials: 'EV',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Cape_Coast_Ghana.JPG?width=600',
    vibe: ['Quiet Study', 'Neat Freaks', 'Medical Students'],
    description: 'Top choice for UCC Nursing and Allied Health students. Quiet environment, good water supply, close to the School of Medical Sciences.',
    perks: ['Good water supply', 'Quiet floors', 'Close to Medical School', 'Female-friendly'],
  },
  {
    id: 'tf', name: 'TF Hostel', school: 'UCC', location: 'Cape Coast Campus',
    residents: 290, type: 'Off-campus', color: 'sky',
    grad: 'linear-gradient(135deg,#0891b2,#0066FF)', initials: 'TF',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Cape_Coast_Ghana.JPG?width=600',
    vibe: ['Affordable', 'Mixed', 'Social Floor'],
    description: 'Budget-friendly and centrally located. Known for its social atmosphere. A solid first-year option for UCC freshers.',
    perks: ['Affordable rates', 'Central location', 'Social common areas', 'Near campus gate'],
  },
  {
    id: 'casford', name: 'Casford Hall', school: 'UCC', location: 'Cape Coast Campus',
    residents: 445, type: 'On-campus', color: 'teal',
    grad: 'linear-gradient(135deg,#0891b2,#059669)', initials: 'CA',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Cape_Coast_Ghana.JPG?width=600',
    vibe: ['Academic', 'Disciplined', 'Early Risers'],
    description: 'On-campus hall known for academic focus and discipline. Great for students serious about their first year GPA.',
    perks: ['On-campus location', 'Quiet study environment', 'Close to lecture halls', 'Organized hall structure'],
  },
  {
    id: 'volta', name: 'Volta Hall', school: 'UG Legon', location: 'University of Ghana',
    residents: 510, type: 'On-campus', color: 'rose',
    grad: 'linear-gradient(135deg,#be185d,#9333ea)', initials: 'VO',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Legon_Tower.JPG?width=600',
    vibe: ['Sisterhood', 'Scholars', 'Night Library Runs'],
    description: 'The most prestigious female hall at Legon. Strong academic culture, beautiful grounds, and a tight-knit sisterhood community.',
    perks: ['Female-only', 'Library access', 'Stunning grounds', 'Strong alumnae network'],
  },
  {
    id: 'limann', name: 'Limann Hall', school: 'UG Legon', location: 'University of Ghana',
    residents: 390, type: 'On-campus', color: 'blue',
    grad: 'linear-gradient(135deg,#0066FF,#0891b2)', initials: 'LI',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Athletics_Oval_at_University_of_Ghana,_Legon.jpg?width=600',
    vibe: ['Mixed', 'Chill', 'Good Wi-Fi'],
    description: 'A newer hall at Legon with modern facilities. Popular with Business and Social Sciences students. Good internet infrastructure.',
    perks: ['Modern facilities', 'Better Wi-Fi', 'Mixed gender floors', 'Close to Balme Library'],
  },
  {
    id: 'commonwealth', name: 'Commonwealth Hall', school: 'UG Legon', location: 'University of Ghana',
    residents: 820, type: 'On-campus', color: 'orange',
    grad: 'linear-gradient(135deg,#d97706,#FF6B35)', initials: 'CW',
    photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Legon_Tower.JPG?width=600',
    vibe: ['Brotherhood', 'Vandal Nation', 'Legendary'],
    description: 'The most famous male hall at Legon. Home of the Vandals. Massive culture, hall week is unmissable. Brotherhood is for life.',
    perks: ['Iconic hall culture', 'Sports dominance', 'Central to campus', 'Strong alumni network'],
  },
];

const COLOR_MAP = {
  emerald: { border: 'border-[#A8C4FF]/30', accent: 'text-[#A8C4FF]', pill: 'bg-[#A8C4FF]/10 text-[#A8C4FF] border-[#A8C4FF]/30' },
  green:   { border: 'border-[#A8C4FF]/30', accent: 'text-[#A8C4FF]', pill: 'bg-[#A8C4FF]/10 text-[#A8C4FF] border-[#A8C4FF]/30' },
  blue:    { border: 'border-[#FF6B35]/40', accent: 'text-[#FF6B35]', pill: 'bg-[#FF6B35]/10 text-purple-300 border-[#FF6B35]/30' },
  orange:  { border: 'border-amber-400/30', accent: 'text-amber-400',  pill: 'bg-amber-400/10 text-amber-300 border-amber-400/30' },
  violet:  { border: 'border-[#FF6B35]/40', accent: 'text-purple-400', pill: 'bg-[#FF6B35]/10 text-purple-300 border-[#FF6B35]/30' },
  sky:     { border: 'border-[#A8C4FF]/30', accent: 'text-[#A8C4FF]', pill: 'bg-[#A8C4FF]/10 text-[#A8C4FF] border-[#A8C4FF]/30' },
  rose:    { border: 'border-amber-400/30', accent: 'text-amber-400',  pill: 'bg-amber-400/10 text-amber-300 border-amber-400/30' },
  teal:    { border: 'border-[#A8C4FF]/30', accent: 'text-[#A8C4FF]', pill: 'bg-[#A8C4FF]/10 text-[#A8C4FF] border-[#A8C4FF]/30' },
};

const SCHOOL_GROUPS = [
  { id: 'knust',    label: 'KNUST',    full: 'Kwame Nkrumah University of Science & Technology', hubs: HUBS.filter(h => h.school === 'KNUST') },
  { id: 'ug-legon', label: 'UG Legon', full: 'University of Ghana, Legon',                        hubs: HUBS.filter(h => h.school === 'UG Legon') },
  { id: 'ucc',      label: 'UCC',      full: 'University of Cape Coast',                          hubs: HUBS.filter(h => h.school === 'UCC') },
];

function HubCard({ hub }) {
  const c = COLOR_MAP[hub.color] || COLOR_MAP.blue;
  return (
    <div className="relative bg-[#162347] border border-white/10 shadow-[0_8px_32px_rgba(0,0,0,0.4)] rounded-3xl overflow-hidden flex flex-col hover:bg-[#1f1d30] hover:-translate-y-1.5 hover:border-[#FF6B35]/40 hover:shadow-[0_16px_48px_rgba(123,47,190,0.2)] transition-all duration-300">
      {/* Gradient banner */}
      <div className="relative h-48 overflow-hidden flex items-center justify-center" style={{ background: hub.grad }}>
        {/* Campus photo */}
        {hub.photo && (
          <img src={hub.photo} alt={hub.name} className="absolute inset-0 w-full h-full object-cover object-center" />
        )}
        {/* Dark gradient overlay */}
        <div className="absolute inset-0" style={{ background: 'linear-gradient(to bottom, rgba(0,0,0,0.08) 0%, rgba(0,0,0,0.32) 100%)' }} />
        {/* Large faded initials watermark */}
        <span className="absolute right-4 bottom-2 text-[80px] font-black leading-none select-none pointer-events-none" style={{ color: 'rgba(255,255,255,0.15)' }}>{hub.initials}</span>
        {/* Centered initials circle */}
        <div className="relative w-16 h-16 rounded-2xl bg-white/20 border border-white/30 flex items-center justify-center">
          <span className="text-2xl font-black text-white">{hub.initials}</span>
        </div>
        <div className="absolute bottom-3 left-4 flex gap-2">
          <span className="text-xs font-bold px-2.5 py-1 rounded-full bg-black/30 backdrop-blur-sm border border-white/20 text-white">{hub.school}</span>
          <span className={`text-xs font-bold px-2.5 py-1 rounded-full backdrop-blur-sm border ${hub.type === 'On-campus' ? 'bg-green-500/25 border-green-400/40 text-white' : 'bg-white/20 border-white/30 text-white'}`}>{hub.type}</span>
        </div>
      </div>

      <div className="p-6 flex flex-col flex-1 gap-4">
        <div>
          <h3 className="text-xl font-black text-white leading-tight mb-2">{hub.name}</h3>
          <div className="flex items-center gap-4 flex-wrap">
            <span className="text-sm text-white/50 flex items-center gap-1.5"><MapPin className="w-3.5 h-3.5" />{hub.location}</span>
            <span className={`text-sm font-bold ${c.accent}`}><Users className="w-3.5 h-3.5 inline mr-1" />{hub.residents.toLocaleString()}+ freshers</span>
          </div>
        </div>

        <p className="text-sm text-white/60 leading-relaxed">{hub.description}</p>

        <ul className="space-y-1.5">
          {hub.perks.map(perk => (
            <li key={perk} className="flex items-center gap-2 text-sm text-white/80">
              <Check className={`w-3.5 h-3.5 flex-shrink-0 ${c.accent}`} />{perk}
            </li>
          ))}
        </ul>

        <div className="flex flex-wrap gap-1.5">
          {hub.vibe.map(tag => (
            <span key={tag} className={`text-xs font-medium px-2.5 py-1 rounded-full border ${c.pill}`}>{tag}</span>
          ))}
        </div>

        <a href="/#waitlist" className="mt-auto flex items-center justify-center gap-2 w-full py-3 px-4 rounded-full bg-[#FF6B35] hover:bg-[#E55A22] text-white text-sm font-black transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(123,47,190,0.4)]">
          Join {hub.name} Hub <ArrowRight className="w-4 h-4" />
        </a>
      </div>
    </div>
  );
}

export default function HubsPage() {
  const totalResidents = HUBS.reduce((sum, h) => sum + h.residents, 0);

  return (
    <div className="relative min-h-screen p-4 md:p-8 antialiased"
         style={{ background: '#0D1B3E', fontFamily: 'system-ui, Inter, sans-serif' }}>

      <style>{`
        @keyframes fadeUp {
          from { opacity: 0; transform: translateY(28px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes slideRight {
          from { opacity: 0; transform: translateX(-20px); }
          to   { opacity: 1; transform: translateX(0); }
        }
        @keyframes scaleIn {
          from { opacity: 0; transform: scale(0.93); }
          to   { opacity: 1; transform: scale(1); }
        }
        @keyframes glowPulse {
          0%, 100% { box-shadow: 0 0 20px rgba(0,102,255,0.15); }
          50%       { box-shadow: 0 0 40px rgba(0,102,255,0.30); }
        }
        @keyframes floatBadge {
          0%, 100% { transform: translateY(0px); }
          50%       { transform: translateY(-6px); }
        }
        .anim-fade-up    { animation: fadeUp 0.6s ease-out both; }
        .anim-slide-right { animation: slideRight 0.6s ease-out both; }
        .anim-scale-in   { animation: scaleIn 0.5s ease-out both; }
        .anim-glow       { animation: glowPulse 3s ease-in-out infinite; }
        .anim-float      { animation: floatBadge 4s ease-in-out infinite; }
        .delay-100 { animation-delay: 0.1s; }
        .delay-200 { animation-delay: 0.2s; }
        .delay-300 { animation-delay: 0.3s; }
        .delay-400 { animation-delay: 0.4s; }
        .delay-500 { animation-delay: 0.5s; }
      `}</style>

      {/* Fixed ambient blobs */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
        <div className="absolute -top-1/4 -right-1/4 w-[700px] h-[700px] rounded-full bg-[#FF6B35]/[0.10] blur-[120px]" />
        <div className="absolute -bottom-1/4 -left-1/4 w-[600px] h-[600px] rounded-full bg-[#A8C4FF]/[0.05] blur-[100px]" />
        <div className="absolute top-1/3 left-1/3 w-[400px] h-[400px] rounded-full bg-amber-400/[0.04] blur-[80px]" />
      </div>

      <div className="max-w-7xl mx-auto bg-[#0D1B3E] border border-white/10 shadow-[0_40px_100px_rgba(123,47,190,0.15)] rounded-[32px] overflow-hidden">

        {/* Purple top bar */}
        <div className="h-1.5 bg-gradient-to-r from-[#FF6B35] via-amber-400 to-[#A8C4FF]" />

        {/* ── NAV ── */}
        <nav className="sticky top-0 z-50 bg-[#0D1B3E]/90 backdrop-blur-2xl border-b border-white/10">
          <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
            <a href="/" className="flex items-center gap-2">
              <span className="text-lg font-black tracking-tight text-white">UNIFY</span>
              <span className="text-[10px] font-black px-2 py-0.5 rounded-full bg-amber-400/10 border border-amber-400/25 text-amber-400">GH</span>
            </a>
            <div className="hidden md:flex items-center gap-6 text-sm text-white/50 font-medium">
              <a href="/" className="hover:text-white transition-colors">Home</a>
              <a href="/hubs" className="relative text-white font-semibold">
                Hubs
                <span className="absolute -bottom-0.5 left-0 right-0 h-0.5 rounded-full bg-[#FF6B35]" />
              </a>
              <a href="/match" className="hover:text-white transition-colors">Match</a>
              <a href="/#faq" className="hover:text-white transition-colors">FAQ</a>
            </div>
            <a href="/#waitlist" className="bg-[#FF6B35] hover:bg-[#E55A22] text-white text-xs font-black px-4 py-2.5 rounded-full transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(123,47,190,0.4)]">
              Get Early Access →
            </a>
          </div>
        </nav>

        {/* ── HERO ── */}
        <section className="pt-16 md:pt-24 pb-12 px-6">
          <div className="max-w-6xl mx-auto grid md:grid-cols-[55fr_45fr] gap-10 md:gap-16 items-center">
            {/* Left */}
            <div className="anim-slide-right">
              <div className="anim-float inline-flex items-center gap-2 bg-[#FF6B35]/10 border border-[#FF6B35]/30 text-purple-300 text-xs font-bold px-3.5 py-2 rounded-full mb-7">
                <span className="w-1.5 h-1.5 rounded-full bg-[#FF6B35] animate-pulse" />
                10 active hubs · KNUST · UG Legon · UCC
              </div>
              <h1 className="anim-fade-up delay-100 text-[2.4rem] md:text-[3.4rem] font-black leading-[1.05] tracking-tight text-white mb-5">
                Find your people<br />before you find<br />
                <span className="text-amber-400">your room.</span>
              </h1>
              <p className="anim-fade-up delay-200 text-base md:text-lg text-white/60 leading-relaxed mb-8 max-w-md">
                Real intel on hostels and halls from students already living there. No sugarcoating, no guessing.
              </p>
              <div className="anim-fade-up delay-300 flex flex-wrap gap-3">
                <a href="#hubs-top" className="inline-flex items-center gap-2 bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-sm px-6 py-3 rounded-full transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(123,47,190,0.4)] anim-glow">
                  Browse Hubs <ArrowRight className="w-4 h-4" />
                </a>
                <a href="/match" className="inline-flex items-center gap-2 text-sm font-semibold text-white/60 px-6 py-3 rounded-full border border-white/10 bg-white/5 backdrop-blur-sm hover:border-amber-400/50 hover:text-amber-400 transition-all">
                  Find Roommate
                </a>
              </div>
            </div>

            {/* Right — campus photo collage */}
            <div className="hidden md:grid grid-cols-2 gap-3 anim-scale-in delay-200">
              {[
                { photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Kwame_Nkrumah_University_of_Science_and_Technology_(KNUST)_%E2%80%93_Side_view_of_the_College_of_Architecture_and_Planning.JPG?width=500', grad: 'linear-gradient(135deg,#0052cc,#0066FF)', initials: 'KN', label: 'KNUST', sub: '2,750 freshers' },
                { photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Legon_Tower.JPG?width=500', grad: 'linear-gradient(135deg,#7c3aed,#6366f1)', initials: 'UG', label: 'UG Legon', sub: '1,720 freshers' },
                { photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/Cape_Coast_Ghana.JPG?width=500', grad: 'linear-gradient(135deg,#059669,#0891b2)', initials: 'UC', label: 'UCC', sub: '1,075 freshers' },
                { photo: 'https://commons.wikimedia.org/wiki/Special:FilePath/KNUST_main_entrance_with_Kwame_Nkrumah_Memorial_Park.jpg?width=500', grad: 'linear-gradient(135deg,#d97706,#FF6B35)', initials: '10', label: 'Hubs Live', sub: 'Claim your spot' },
              ].map((item, i) => (
                <div key={i} className="relative rounded-2xl overflow-hidden border border-white/60 flex items-center justify-center" style={{ height: '140px', background: item.grad }}>
                  <img src={item.photo} alt={item.label} className="absolute inset-0 w-full h-full object-cover object-center" />
                  <div className="absolute inset-0" style={{ background: 'rgba(0,0,0,0.28)' }} />
                  <span className="absolute right-2 bottom-1 text-[52px] font-black leading-none select-none pointer-events-none" style={{ color: 'rgba(255,255,255,0.15)' }}>{item.initials}</span>
                  <div className="relative text-center">
                    <p className="text-white font-black text-lg leading-tight">{item.label}</p>
                    <p className="text-white/70 text-[11px] font-semibold">{item.sub}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── STATS BAND ── */}
        <div className="bg-[#FF6B35]/80 backdrop-blur-xl py-8 px-6">
          <div className="max-w-4xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-6 text-center divide-x divide-white/20">
            {[
              { num: HUBS.length,                    label: 'Active Hubs' },
              { num: `${totalResidents.toLocaleString()}+`, label: 'Fresher Residents' },
              { num: '3',                            label: 'Universities' },
              { num: '48h',                          label: 'Early Access Notice' },
            ].map(s => (
              <div key={s.label} className="px-4 anim-scale-in">
                <p className="text-3xl md:text-4xl font-black text-white">{s.num}</p>
                <p className="text-white/70 text-sm mt-1">{s.label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* ── FILTER PILLS ── */}
        <div className="flex justify-center gap-2 px-6 pt-12 flex-wrap">
          <a href="#hubs-top" className="px-5 py-2 rounded-full text-sm font-semibold border bg-[#FF6B35]/20 border-[#FF6B35]/40 text-purple-300">
            All Hubs
          </a>
          {SCHOOL_GROUPS.map(school => (
            <a key={school.id} href={`#${school.id}`} className="px-5 py-2 rounded-full text-sm font-semibold border bg-white/5 border-white/10 text-white/60 hover:bg-[#FF6B35]/20 hover:border-[#FF6B35]/40 hover:text-purple-300 transition-all">
              {school.label}
            </a>
          ))}
        </div>

        {/* ── HUB GRID ── */}
        <div id="hubs-top" className="max-w-7xl mx-auto px-6 pb-20 mt-10 space-y-20">
          {SCHOOL_GROUPS.map(school => {
            const schoolResidents = school.hubs.reduce((sum, h) => sum + h.residents, 0);
            return (
              <section key={school.id} id={school.id}>
                <div className="flex flex-col sm:flex-row sm:items-end gap-3 mb-8 pb-4 border-b border-white/10">
                  <div className="flex items-center gap-3">
                    <Building2 className="w-5 h-5 text-[#FF6B35]" />
                    <div>
                      <h2 className="text-2xl md:text-3xl font-black text-white">{school.label} Hubs</h2>
                      <p className="text-sm text-white/40 mt-1">{school.full}</p>
                    </div>
                  </div>
                  <div className="sm:ml-auto">
                    <span className="text-sm text-white/40">{school.hubs.length} hubs · </span>
                    <span className="text-sm font-bold text-[#A8C4FF]">{schoolResidents.toLocaleString()}+ residents</span>
                  </div>
                </div>
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
                  {school.hubs.map(hub => <HubCard key={hub.id} hub={hub} />)}
                </div>
              </section>
            );
          })}
        </div>

        {/* ── BOTTOM CTA ── */}
        <section className="px-6 pb-20">
          <div className="max-w-2xl mx-auto text-center bg-[#162347] border border-white/10 shadow-[0_8px_32px_rgba(123,47,190,0.2)] rounded-3xl p-12">
            <div className="w-16 h-16 rounded-2xl bg-[#FF6B35]/10 border border-[#FF6B35]/20 flex items-center justify-center mx-auto mb-6 text-2xl">🏠</div>
            <h2 className="text-3xl md:text-4xl font-black text-white mb-4">Your hostel hub is waiting.</h2>
            <p className="text-white/60 text-lg mb-8 leading-relaxed">
              Sign up to get notified <span className="text-amber-400 font-semibold">48hrs before your hub goes live.</span> Be first in. Link early. Walk into orientation knowing people.
            </p>
            <a href="/#waitlist" className="inline-flex items-center gap-2 px-8 py-3.5 rounded-full bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-base transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(123,47,190,0.4)]">
              Claim Your Handle →
            </a>
            <p className="text-white/30 text-xs mt-5">Free · No spam · Ghana university freshers only</p>
          </div>
        </section>

        {/* ── FOOTER ── */}
        <footer className="bg-[#162347] border-t border-white/10 px-6 pt-10 pb-8">
          <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-2">
              <span className="text-lg font-black text-white">UNIFY</span>
              <span className="text-2xl">🇬🇭</span>
            </div>
            <nav className="flex flex-wrap items-center justify-center gap-6 text-sm text-white/70">
              <a href="/" className="hover:text-white transition-colors">Home</a>
              <a href="/hubs" className="text-white font-semibold">Hubs</a>
              <a href="/match" className="hover:text-white transition-colors">Match</a>
              <a href="/#waitlist" className="hover:text-white transition-colors">Join Waitlist</a>
            </nav>
            <p className="text-xs text-white/50">© 2026 UNIFY · Built for freshers</p>
          </div>
          <div className="max-w-6xl mx-auto mt-6 h-[3px] rounded-full bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />
        </footer>

      </div>
    </div>
  );
}
