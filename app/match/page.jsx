'use client';

import { useState } from 'react';
import { MapPin, ArrowRight, X, Users, BookOpen, Home } from 'lucide-react';

// ─── MOCK DATA ────────────────────────────────────────────────────────────────

const PROFILES = [
  {
    id: 1,
    name: 'Ama Owusu',
    photo: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce',
    school: 'KNUST',
    course: 'Computer Science',
    year: 'Fresher 2026',
    hometown: 'Accra',
    habits: ['Early riser', 'Quiet study', 'Non-smoker'],
    bio: "Into machine learning and Afrobeats. Looking for a quiet roommate who won't judge my 2am debugging sessions.",
    lookingFor: 'Roommate',
  },
  {
    id: 2,
    name: 'Kwame Asante',
    photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
    school: 'KNUST',
    course: 'Mechanical Engineering',
    year: 'Fresher 2026',
    hometown: 'Kumasi',
    habits: ['Night owl', 'Gym rat', 'Social'],
    bio: 'Gym 6am, then class. Weekend footballing. Need a roommate who can handle my protein shake collection.',
    lookingFor: 'Both',
  },
  {
    id: 3,
    name: 'Abena Mensah',
    photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    school: 'UG Legon',
    course: 'Economics',
    year: 'Fresher 2026',
    hometown: 'Cape Coast',
    habits: ['Early riser', 'Quiet study', 'Non-smoker'],
    bio: 'Love reading, hate noise. Want a roommate who respects study hours and appreciates good jollof.',
    lookingFor: 'Roommate',
  },
  {
    id: 4,
    name: 'Kofi Boateng',
    photo: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    school: 'UG Legon',
    course: 'Political Science',
    year: 'Fresher 2026',
    hometown: 'Tamale',
    habits: ['Social', 'Night owl'],
    bio: 'Debate club president in SHS. Looking for coursemates to form a study group before lectures start.',
    lookingFor: 'Coursemates',
  },
  {
    id: 5,
    name: 'Efua Asiedu',
    photo: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91',
    school: 'UCC',
    course: 'Nursing',
    year: 'Fresher 2026',
    hometown: 'Accra',
    habits: ['Early riser', 'Non-smoker', 'Quiet study'],
    bio: 'Pre-med mindset. Quiet, organized, always studying. Need someone equally serious about their GPA.',
    lookingFor: 'Roommate',
  },
  {
    id: 6,
    name: 'Yaw Darko',
    photo: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7',
    school: 'KNUST',
    course: 'Architecture',
    year: 'Fresher 2026',
    hometown: 'Sunyani',
    habits: ['Night owl', 'Social', 'Gym rat'],
    bio: 'Studio nights are my life. Looking for a roommate chill enough to deal with blueprints everywhere.',
    lookingFor: 'Roommate',
  },
  {
    id: 7,
    name: 'Akosua Tawiah',
    photo: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df',
    school: 'UG Legon',
    course: 'Psychology',
    year: 'Fresher 2026',
    hometown: 'Kumasi',
    habits: ['Quiet study', 'Early riser', 'Non-smoker'],
    bio: 'Mental health advocate and bookworm. Seeking coursemates who take academic integrity seriously.',
    lookingFor: 'Both',
  },
  {
    id: 8,
    name: 'Nana Osei',
    photo: 'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6',
    school: 'KNUST',
    course: 'Civil Engineering',
    year: 'Fresher 2026',
    hometown: 'Accra',
    habits: ['Gym rat', 'Social', 'Night owl'],
    bio: 'Engineering is a team sport. Want to build a solid study group from day one.',
    lookingFor: 'Coursemates',
  },
  {
    id: 9,
    name: 'Adwoa Poku',
    photo: 'https://images.unsplash.com/photo-1548142813-c348350df52b',
    school: 'UCC',
    course: 'Business Administration',
    year: 'Fresher 2026',
    hometown: 'Ho',
    habits: ['Early riser', 'Social', 'Non-smoker'],
    bio: "Entrepreneur at heart. Want a roommate who's motivated and doesn't sleep past 7am.",
    lookingFor: 'Roommate',
  },
  {
    id: 10,
    name: 'Fiifi Mensah',
    photo: 'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f',
    school: 'KNUST',
    course: 'Electrical Engineering',
    year: 'Fresher 2026',
    hometown: 'Tema',
    habits: ['Night owl', 'Quiet study', 'Non-smoker'],
    bio: "PCB designs and lo-fi beats. I'm clean and quiet, need the same in return.",
    lookingFor: 'Roommate',
  },
  {
    id: 11,
    name: 'Serwa Acheampong',
    photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    school: 'UG Legon',
    course: 'Law',
    year: 'Fresher 2026',
    hometown: 'Accra',
    habits: ['Night owl', 'Quiet study'],
    bio: 'Books and briefs. Law school prep starts now. Need serious coursemates for case study groups.',
    lookingFor: 'Coursemates',
  },
  {
    id: 12,
    name: 'Kwabena Frimpong',
    photo: 'https://images.unsplash.com/photo-1542178243-bc20204b769f',
    school: 'KNUST',
    course: 'Biochemistry',
    year: 'Fresher 2026',
    hometown: 'Takoradi',
    habits: ['Early riser', 'Gym rat', 'Non-smoker'],
    bio: 'Pre-med track. Wake up at 5am to study before lab. Need someone with the same energy.',
    lookingFor: 'Both',
  },
  {
    id: 13,
    name: 'Maame Serwah',
    photo: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
    school: 'UCC',
    course: 'Education',
    year: 'Fresher 2026',
    hometown: 'Wa',
    habits: ['Social', 'Early riser'],
    bio: 'Teaching is a calling. Friendly, organized, and always down for a good conversation after class.',
    lookingFor: 'Both',
  },
  {
    id: 14,
    name: 'Ebo Hayford',
    photo: 'https://images.unsplash.com/photo-1463453091185-61582044d556',
    school: 'UG Legon',
    course: 'Computer Science',
    year: 'Fresher 2026',
    hometown: 'Accra',
    habits: ['Night owl', 'Social', 'Gym rat'],
    bio: "Full-stack dreams. Hackathons, coding bootcamps, and Legon vibes. Link if you're in CS.",
    lookingFor: 'Coursemates',
  },
  {
    id: 15,
    name: 'Afia Boampong',
    photo: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    school: 'KNUST',
    course: 'Pharmacy',
    year: 'Fresher 2026',
    hometown: 'Kumasi',
    habits: ['Quiet study', 'Non-smoker', 'Early riser'],
    bio: 'Pharmacy is intense. Looking for a roommate who understands that and keeps things peaceful.',
    lookingFor: 'Roommate',
  },
];

const SCHOOLS = ['All', 'KNUST', 'UG Legon', 'UCC'];
const HABITS = ['All', 'Early riser', 'Night owl', 'Quiet study', 'Social', 'Gym rat', 'Non-smoker'];

// ─── HELPERS ──────────────────────────────────────────────────────────────────

function getSchoolColor(school) {
  if (school === 'KNUST') return { bg: 'bg-amber-400/20', text: 'text-amber-400', border: 'border-amber-400/30', dot: 'bg-amber-400' };
  if (school === 'UG Legon') return { bg: 'bg-blue-400/20', text: 'text-blue-400', border: 'border-blue-400/30', dot: 'bg-blue-400' };
  if (school === 'UCC') return { bg: 'bg-emerald-400/20', text: 'text-emerald-400', border: 'border-emerald-400/30', dot: 'bg-emerald-400' };
  return { bg: 'bg-white/10', text: 'text-white/60', border: 'border-white/20', dot: 'bg-white/20' };
}

function getLookingForStyle(lookingFor) {
  if (lookingFor === 'Roommate') return 'bg-violet-500/20 text-violet-300 border-violet-500/30';
  if (lookingFor === 'Coursemates') return 'bg-sky-500/20 text-sky-300 border-sky-500/30';
  return 'bg-amber-500/20 text-amber-300 border-amber-500/30';
}

function getLookingForIcon(lookingFor) {
  if (lookingFor === 'Roommate') return <Home size={11} />;
  if (lookingFor === 'Coursemates') return <BookOpen size={11} />;
  return <Users size={11} />;
}

// ─── NAV ──────────────────────────────────────────────────────────────────────

function Nav() {
  return (
    <nav className="fixed top-0 left-0 right-0 z-50 border-b border-white/[0.06] backdrop-blur-md bg-[#050d20]/80">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        <a href="/" className="flex items-center gap-2">
          <span className="text-xl font-bold tracking-tight text-white">
            UNI<span className="text-amber-400">FY</span>
          </span>
        </a>
        <div className="hidden md:flex items-center gap-8 text-sm text-white/60">
          <a href="/#features" className="hover:text-white transition-colors">Features</a>
          <a href="/hubs" className="hover:text-white transition-colors">Hubs</a>
          <a href="/match" className="text-white font-medium">Meet Freshers</a>
        </div>
        <a
          href="/#waitlist"
          className="inline-flex items-center gap-1.5 bg-amber-400 hover:bg-amber-300 text-[#050d20] font-semibold text-sm px-4 py-2 rounded-xl transition-colors"
        >
          Get Early Access <ArrowRight size={14} />
        </a>
      </div>
    </nav>
  );
}

// ─── PROFILE CARD ─────────────────────────────────────────────────────────────

function ProfileCard({ profile, onConnect }) {
  const school = getSchoolColor(profile.school);

  return (
    <div className="bg-white/[0.03] border border-white/[0.07] rounded-2xl p-5 flex flex-col gap-4 hover:bg-white/[0.05] hover:border-white/[0.12] transition-all duration-200 group">
      {/* Header */}
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-3">
          {/* Avatar — photo */}
          <div className="relative w-16 h-16 rounded-2xl overflow-hidden border-2 border-white/10 flex-shrink-0">
            <img
              src={`${profile.photo}?auto=format&fit=crop&w=200&h=200&crop=faces&q=80`}
              alt={profile.name}
              className="w-full h-full object-cover"
            />
            {/* school color dot */}
            <div className={`absolute bottom-1 right-1 w-3 h-3 rounded-full border-2 border-[#050d20] ${school.dot}`} />
          </div>
          <div>
            <p className="font-semibold text-white text-sm leading-tight">{profile.name}</p>
            <span className={`inline-block mt-1 text-[11px] px-2 py-0.5 rounded-full border ${school.bg} ${school.text} ${school.border}`}>
              {profile.school}
            </span>
          </div>
        </div>
        <span className={`inline-flex items-center gap-1 text-[11px] px-2 py-1 rounded-full border flex-shrink-0 ${getLookingForStyle(profile.lookingFor)}`}>
          {getLookingForIcon(profile.lookingFor)}
          {profile.lookingFor}
        </span>
      </div>

      {/* Course + Hometown */}
      <div className="space-y-1">
        <p className="text-white/80 text-sm font-medium">
          {profile.course} · <span className="text-white/40 font-normal">{profile.year}</span>
        </p>
        <p className="text-white/40 text-xs flex items-center gap-1">
          <MapPin size={11} className="text-white/30" />
          {profile.hometown}
        </p>
      </div>

      {/* Habit tags */}
      <div className="flex flex-wrap gap-1.5">
        {profile.habits.map(habit => (
          <span
            key={habit}
            className="text-[11px] px-2 py-0.5 rounded-full bg-white/[0.06] border border-white/[0.08] text-white/60"
          >
            {habit}
          </span>
        ))}
      </div>

      {/* Bio */}
      <p className="text-sm text-white/55 leading-relaxed flex-1">{profile.bio}</p>

      {/* CTA */}
      <button
        onClick={() => onConnect(profile.name)}
        className="w-full bg-amber-400 hover:bg-amber-300 text-[#050d20] font-semibold text-sm py-2.5 rounded-xl transition-colors group-hover:shadow-[0_0_20px_rgba(251,191,36,0.15)]"
      >
        Connect →
      </button>
    </div>
  );
}

// ─── TOAST ────────────────────────────────────────────────────────────────────

function Toast({ name, onClose }) {
  return (
    <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 w-full max-w-sm px-4">
      <div className="bg-[#0d1a35] border border-white/[0.12] rounded-2xl p-4 shadow-2xl flex items-start gap-3">
        <span className="text-xl flex-shrink-0">🔗</span>
        <div className="flex-1 min-w-0">
          <p className="text-white font-semibold text-sm">Link sent to {name}!</p>
          <p className="text-white/55 text-xs mt-0.5 leading-relaxed">
            Join the waitlist to unlock full messaging when UNIFY launches.
          </p>
          <a
            href="/#waitlist"
            className="inline-block mt-2 text-xs text-amber-400 hover:text-amber-300 font-medium transition-colors"
          >
            Join waitlist →
          </a>
        </div>
        <button onClick={onClose} className="text-white/30 hover:text-white/60 transition-colors flex-shrink-0 mt-0.5">
          <X size={14} />
        </button>
      </div>
    </div>
  );
}

// ─── PAGE ─────────────────────────────────────────────────────────────────────

export default function MatchPage() {
  const [schoolFilter, setSchoolFilter] = useState('All');
  const [habitsFilter, setHabitsFilter] = useState('All');
  const [toast, setToast] = useState(null);

  const filtered = PROFILES.filter(p => {
    const schoolOk = schoolFilter === 'All' || p.school === schoolFilter;
    const habitOk = habitsFilter === 'All' || p.habits.includes(habitsFilter);
    return schoolOk && habitOk;
  });

  function handleConnect(name) {
    setToast(name);
    setTimeout(() => setToast(null), 5000);
  }

  return (
    <div className="min-h-screen bg-[#050d20] text-white">
      <Nav />

      {/* ── Hero ── */}
      <section className="pt-32 pb-16 px-4 text-center">
        <div className="max-w-3xl mx-auto relative space-y-6">
          {/* Hero photo grid — desktop only */}
          <div className="hidden md:grid grid-cols-2 gap-2 absolute right-0 top-1/2 -translate-y-1/2 opacity-30">
            {PROFILES.slice(0, 4).map((p) => (
              <div key={p.id} className="w-20 h-20 rounded-xl overflow-hidden">
                <img src={`${p.photo}?auto=format&fit=crop&w=100&h=100&q=60`} alt="" className="w-full h-full object-cover" />
              </div>
            ))}
          </div>

          {/* Animated badge */}
          <div className="inline-flex items-center gap-2 bg-white/[0.05] border border-white/[0.08] rounded-full px-4 py-1.5 text-sm text-white/70">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75" />
              <span className="relative inline-flex rounded-full h-2 w-2 bg-amber-400" />
            </span>
            ✦ 847 freshers matched so far
          </div>

          <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight leading-tight">
            Find your roommate{' '}
            <span className="text-amber-400">before</span>{' '}
            orientation.
          </h1>

          <p className="text-lg text-white/55 max-w-xl mx-auto leading-relaxed">
            Browse freshers from your school and course. Connect before campus chaos starts.
          </p>

          {/* Ghana flag stripe */}
          <div className="flex justify-center pt-2">
            <div
              className="h-1 w-24 rounded-full"
              style={{ background: 'linear-gradient(to right, #CE1126, #FCD116, #006B3F)' }}
            />
          </div>
        </div>
      </section>

      {/* ── Filters ── */}
      <section className="px-4 pb-10">
        <div className="max-w-7xl mx-auto space-y-4">
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-xs text-white/40 uppercase tracking-wider font-medium mr-1">School</span>
            {SCHOOLS.map(s => (
              <button
                key={s}
                onClick={() => setSchoolFilter(s)}
                className={`text-sm px-4 py-1.5 rounded-full border transition-all duration-150 ${
                  schoolFilter === s
                    ? 'bg-amber-400 text-[#050d20] border-amber-400 font-semibold'
                    : 'bg-white/[0.04] border-white/[0.08] text-white/60 hover:bg-white/[0.08] hover:text-white'
                }`}
              >
                {s}
              </button>
            ))}
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <span className="text-xs text-white/40 uppercase tracking-wider font-medium mr-1">Habits</span>
            {HABITS.map(h => (
              <button
                key={h}
                onClick={() => setHabitsFilter(h)}
                className={`text-sm px-4 py-1.5 rounded-full border transition-all duration-150 ${
                  habitsFilter === h
                    ? 'bg-amber-400 text-[#050d20] border-amber-400 font-semibold'
                    : 'bg-white/[0.04] border-white/[0.08] text-white/60 hover:bg-white/[0.08] hover:text-white'
                }`}
              >
                {h}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* ── Profile Grid ── */}
      <section className="px-4 pb-24">
        <div className="max-w-7xl mx-auto">
          {filtered.length === 0 ? (
            <div className="text-center py-24 space-y-4">
              <div className="text-5xl">🤷🏾</div>
              <p className="text-white/60 text-lg max-w-sm mx-auto leading-relaxed">
                No freshers match your filters yet. Be the first to join from your school!
              </p>
              <a
                href="/#waitlist"
                className="inline-flex items-center gap-1.5 bg-amber-400 hover:bg-amber-300 text-[#050d20] font-semibold text-sm px-5 py-2.5 rounded-xl transition-colors"
              >
                Join the waitlist <ArrowRight size={14} />
              </a>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
              {filtered.map(profile => (
                <ProfileCard key={profile.id} profile={profile} onConnect={handleConnect} />
              ))}
            </div>
          )}
        </div>
      </section>

      {/* ── Bottom CTA ── */}
      <section className="px-4 pb-24">
        <div className="max-w-2xl mx-auto text-center space-y-6 bg-white/[0.03] border border-white/[0.07] rounded-3xl px-8 py-14">
          <div className="flex justify-center">
            <div
              className="h-1 w-16 rounded-full"
              style={{ background: 'linear-gradient(to right, #CE1126, #FCD116, #006B3F)' }}
            />
          </div>
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight">
            Ready to find your match?
          </h2>
          <p className="text-white/55 text-base leading-relaxed max-w-md mx-auto">
            Join thousands of Ghana freshers already connecting on UNIFY before orientation week.
          </p>
          <a
            href="/#waitlist"
            className="inline-flex items-center gap-2 bg-amber-400 hover:bg-amber-300 text-[#050d20] font-bold text-base px-8 py-3.5 rounded-xl transition-all hover:shadow-[0_0_40px_rgba(251,191,36,0.25)]"
          >
            Join the waitlist <ArrowRight size={16} />
          </a>
        </div>
      </section>

      {/* ── Footer ── */}
      <footer className="border-t border-white/[0.06] px-4 py-8">
        <div className="max-w-7xl mx-auto text-center text-sm text-white/30">
          © 2026 UNIFY · Ghana 🇬🇭 · Built for freshers
        </div>
      </footer>

      {/* ── Toast ── */}
      {toast && <Toast name={toast} onClose={() => setToast(null)} />}
    </div>
  );
}
