'use client';

import { useState } from 'react';
import { MapPin, ArrowRight, X, Users, BookOpen, Home, Heart, Filter, Users2 } from 'lucide-react';

const PROFILES = [
  {
    id: 1, name: 'Ama Owusu',
    photo: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce',
    school: 'KNUST', course: 'Computer Science', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Early riser', 'Quiet study', 'Non-smoker'],
    bio: "Into machine learning and Afrobeats. Looking for a quiet roommate who won't judge my 2am debugging sessions.",
    lookingFor: 'Roommate',
  },
  {
    id: 2, name: 'Kwame Asante',
    photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
    school: 'KNUST', course: 'Mechanical Engineering', year: 'Fresher 2026', hometown: 'Kumasi',
    habits: ['Night owl', 'Gym rat', 'Social'],
    bio: 'Gym 6am, then class. Weekend footballing. Need a roommate who can handle my protein shake collection.',
    lookingFor: 'Both',
  },
  {
    id: 3, name: 'Abena Mensah',
    photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    school: 'UG Legon', course: 'Economics', year: 'Fresher 2026', hometown: 'Cape Coast',
    habits: ['Early riser', 'Quiet study', 'Non-smoker'],
    bio: 'Love reading, hate noise. Want a roommate who respects study hours and appreciates good jollof.',
    lookingFor: 'Roommate',
  },
  {
    id: 4, name: 'Kofi Boateng',
    photo: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    school: 'UG Legon', course: 'Political Science', year: 'Fresher 2026', hometown: 'Tamale',
    habits: ['Social', 'Night owl'],
    bio: 'Debate club president in SHS. Looking for coursemates to form a study group before lectures start.',
    lookingFor: 'Coursemates',
  },
  {
    id: 5, name: 'Efua Asiedu',
    photo: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91',
    school: 'UCC', course: 'Nursing', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Early riser', 'Non-smoker', 'Quiet study'],
    bio: 'Pre-med mindset. Quiet, organized, always studying. Need someone equally serious about their GPA.',
    lookingFor: 'Roommate',
  },
  {
    id: 6, name: 'Yaw Darko',
    photo: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7',
    school: 'KNUST', course: 'Architecture', year: 'Fresher 2026', hometown: 'Sunyani',
    habits: ['Night owl', 'Social', 'Gym rat'],
    bio: 'Studio nights are my life. Looking for a roommate chill enough to deal with blueprints everywhere.',
    lookingFor: 'Roommate',
  },
  {
    id: 7, name: 'Akosua Tawiah',
    photo: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df',
    school: 'UG Legon', course: 'Psychology', year: 'Fresher 2026', hometown: 'Kumasi',
    habits: ['Quiet study', 'Early riser', 'Non-smoker'],
    bio: 'Mental health advocate and bookworm. Seeking coursemates who take academic integrity seriously.',
    lookingFor: 'Both',
  },
  {
    id: 8, name: 'Nana Osei',
    photo: 'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6',
    school: 'KNUST', course: 'Civil Engineering', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Gym rat', 'Social', 'Night owl'],
    bio: 'Engineering is a team sport. Want to build a solid study group from day one.',
    lookingFor: 'Coursemates',
  },
  {
    id: 9, name: 'Adwoa Poku',
    photo: 'https://images.unsplash.com/photo-1548142813-c348350df52b',
    school: 'UCC', course: 'Business Administration', year: 'Fresher 2026', hometown: 'Ho',
    habits: ['Early riser', 'Social', 'Non-smoker'],
    bio: "Entrepreneur at heart. Want a roommate who's motivated and doesn't sleep past 7am.",
    lookingFor: 'Roommate',
  },
  {
    id: 10, name: 'Fiifi Mensah',
    photo: 'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f',
    school: 'KNUST', course: 'Electrical Engineering', year: 'Fresher 2026', hometown: 'Tema',
    habits: ['Night owl', 'Quiet study', 'Non-smoker'],
    bio: "PCB designs and lo-fi beats. I'm clean and quiet, need the same in return.",
    lookingFor: 'Roommate',
  },
  {
    id: 11, name: 'Serwa Acheampong',
    photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    school: 'UG Legon', course: 'Law', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Night owl', 'Quiet study'],
    bio: 'Books and briefs. Law school prep starts now. Need serious coursemates for case study groups.',
    lookingFor: 'Coursemates',
  },
  {
    id: 12, name: 'Kwabena Frimpong',
    photo: 'https://images.unsplash.com/photo-1542178243-bc20204b769f',
    school: 'KNUST', course: 'Biochemistry', year: 'Fresher 2026', hometown: 'Takoradi',
    habits: ['Early riser', 'Gym rat', 'Non-smoker'],
    bio: 'Pre-med track. Wake up at 5am to study before lab. Need someone with the same energy.',
    lookingFor: 'Both',
  },
  {
    id: 13, name: 'Maame Serwah',
    photo: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
    school: 'UCC', course: 'Education', year: 'Fresher 2026', hometown: 'Wa',
    habits: ['Social', 'Early riser'],
    bio: 'Teaching is a calling. Friendly, organized, and always down for a good conversation after class.',
    lookingFor: 'Both',
  },
  {
    id: 14, name: 'Ebo Hayford',
    photo: 'https://images.unsplash.com/photo-1463453091185-61582044d556',
    school: 'UG Legon', course: 'Computer Science', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Night owl', 'Social', 'Gym rat'],
    bio: "Full-stack dreams. Hackathons, coding bootcamps, and Legon vibes. Link if you're in CS.",
    lookingFor: 'Coursemates',
  },
  {
    id: 15, name: 'Afia Boampong',
    photo: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    school: 'KNUST', course: 'Pharmacy', year: 'Fresher 2026', hometown: 'Kumasi',
    habits: ['Quiet study', 'Non-smoker', 'Early riser'],
    bio: 'Pharmacy is intense. Looking for a roommate who understands that and keeps things peaceful.',
    lookingFor: 'Roommate',
  },
];

const SCHOOLS = ['All', 'KNUST', 'UG Legon', 'UCC'];
const HABITS = ['All', 'Early riser', 'Night owl', 'Quiet study', 'Social', 'Gym rat', 'Non-smoker'];

function getSchoolStyle(school) {
  if (school === 'KNUST')    return { pill: 'bg-blue-50 text-[#0066FF] border-blue-200', dot: 'bg-[#0066FF]' };
  if (school === 'UG Legon') return { pill: 'bg-emerald-50 text-emerald-700 border-emerald-200', dot: 'bg-emerald-500' };
  if (school === 'UCC')      return { pill: 'bg-orange-50 text-orange-700 border-orange-200', dot: 'bg-orange-500' };
  return { pill: 'bg-[#F9FAFB] text-[#6B7280] border-[#E5E7EB]', dot: 'bg-[#9CA3AF]' };
}

function getLookingForStyle(lookingFor) {
  if (lookingFor === 'Roommate')   return 'bg-violet-50 text-violet-700 border-violet-200';
  if (lookingFor === 'Coursemates') return 'bg-sky-50 text-sky-700 border-sky-200';
  return 'bg-[#0066FF]/8 text-[#0066FF] border-[#0066FF]/20';
}

function getLookingForIcon(lookingFor) {
  if (lookingFor === 'Roommate')   return <Home size={11} />;
  if (lookingFor === 'Coursemates') return <BookOpen size={11} />;
  return <Users size={11} />;
}

function ProfileCard({ profile, onConnect }) {
  const school = getSchoolStyle(profile.school);
  return (
    <div className="bg-white/65 backdrop-blur-xl border border-white/75 shadow-[0_8px_32px_rgba(0,0,0,0.08),inset_0_1px_0_rgba(255,255,255,0.8)] rounded-3xl p-5 flex flex-col gap-4 hover:bg-white/80 hover:-translate-y-1.5 hover:shadow-[0_16px_48px_rgba(0,0,0,0.12)] transition-all duration-300">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="relative w-16 h-16 rounded-2xl overflow-hidden border-2 border-white/60 flex-shrink-0">
            <img
              src={`${profile.photo}?auto=format&fit=crop&w=200&h=200&crop=faces&q=80`}
              alt={profile.name}
              className="w-full h-full object-cover"
            />
            <div className={`absolute bottom-1 right-1 w-3 h-3 rounded-full border-2 border-white ${school.dot}`} />
          </div>
          <div>
            <p className="font-semibold text-[#111827] text-sm leading-tight">{profile.name}</p>
            <span className={`inline-block mt-1 text-[11px] px-2 py-0.5 rounded-full border ${school.pill}`}>
              {profile.school}
            </span>
          </div>
        </div>
        <span className={`inline-flex items-center gap-1 text-[11px] px-2 py-1 rounded-full border flex-shrink-0 ${getLookingForStyle(profile.lookingFor)}`}>
          {getLookingForIcon(profile.lookingFor)}
          {profile.lookingFor}
        </span>
      </div>

      <div className="space-y-1">
        <p className="text-[#374151] text-sm font-medium">
          {profile.course} · <span className="text-[#9CA3AF] font-normal">{profile.year}</span>
        </p>
        <p className="text-[#9CA3AF] text-xs flex items-center gap-1">
          <MapPin size={11} className="text-[#9CA3AF]" />
          {profile.hometown}
        </p>
      </div>

      <div className="flex flex-wrap gap-1.5">
        {profile.habits.map(habit => (
          <span key={habit} className="text-[11px] px-2 py-0.5 rounded-full bg-white/60 backdrop-blur-sm border border-white/70 text-[#6B7280]">
            {habit}
          </span>
        ))}
      </div>

      <p className="text-sm text-[#6B7280] leading-relaxed flex-1">{profile.bio}</p>

      <button
        onClick={() => onConnect(profile.name)}
        className="w-full bg-[#1F2937] hover:bg-[#111827] text-white font-semibold text-sm py-2.5 rounded-full transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(31,41,55,0.35)] flex items-center justify-center gap-2"
      >
        Connect <Heart size={14} />
      </button>
    </div>
  );
}

function Toast({ name, onClose }) {
  return (
    <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 w-full max-w-sm px-4">
      <div className="bg-white/80 backdrop-blur-2xl border border-white/70 shadow-2xl rounded-2xl p-4 flex items-start gap-3">
        <span className="text-xl flex-shrink-0">🔗</span>
        <div className="flex-1 min-w-0">
          <p className="text-[#111827] font-semibold text-sm">Link sent to {name}!</p>
          <p className="text-[#6B7280] text-xs mt-0.5 leading-relaxed">
            Join the waitlist to unlock full messaging when UNIFY launches.
          </p>
          <a href="/#waitlist" className="inline-block mt-2 text-xs text-[#0066FF] hover:underline font-medium transition-colors">
            Join waitlist →
          </a>
        </div>
        <button onClick={onClose} className="text-[#9CA3AF] hover:text-[#6B7280] transition-colors flex-shrink-0 mt-0.5">
          <X size={14} />
        </button>
      </div>
    </div>
  );
}

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
    <div className="relative min-h-screen p-4 md:p-6 antialiased"
         style={{ background: 'linear-gradient(135deg, #EEF1F8 0%, #D1D5DB 50%, #E8EEFF 100%)', fontFamily: 'system-ui, Inter, sans-serif' }}>

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
        <div className="absolute -top-1/4 -right-1/4 w-[700px] h-[700px] rounded-full bg-[#0066FF]/[0.07] blur-[120px]" />
        <div className="absolute -bottom-1/4 -left-1/4 w-[600px] h-[600px] rounded-full bg-indigo-400/[0.06] blur-[100px]" />
        <div className="absolute top-1/3 left-1/3 w-[400px] h-[400px] rounded-full bg-blue-200/[0.05] blur-[80px]" />
      </div>

      <div className="max-w-7xl mx-auto bg-white/75 backdrop-blur-2xl border border-white/60 shadow-[0_40px_100px_rgba(0,66,255,0.10),0_0_0_1px_rgba(255,255,255,0.5)] rounded-[32px] overflow-hidden">

        {/* Blue top bar */}
        <div className="h-1.5 bg-[#0066FF]" />

        {/* ── NAV ── */}
        <nav className="sticky top-0 z-50 bg-white/60 backdrop-blur-2xl border-b border-white/50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
            <a href="/" className="flex items-center gap-2">
              <span className="text-lg font-black tracking-tight text-[#111827]">UNIFY</span>
              <span className="text-[10px] font-black px-2 py-0.5 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/25 text-[#0066FF]">GH</span>
            </a>
            <div className="hidden md:flex items-center gap-6 text-sm text-[#6B7280] font-medium">
              <a href="/" className="hover:text-[#111827] transition-colors">Home</a>
              <a href="/hubs" className="hover:text-[#111827] transition-colors">Hubs</a>
              <a href="/match" className="relative text-[#111827] font-semibold">
                Match
                <span className="absolute -bottom-0.5 left-0 right-0 h-0.5 rounded-full bg-[#0066FF]" />
              </a>
            </div>
            <a href="/#waitlist" className="inline-flex items-center gap-1.5 bg-[#1F2937] hover:bg-[#111827] text-white font-black text-xs px-4 py-2.5 rounded-full transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(31,41,55,0.35)]">
              Get Early Access <ArrowRight size={14} />
            </a>
          </div>
        </nav>

        {/* ── HERO ── */}
        <section className="pt-16 md:pt-24 pb-12 px-6 text-center">
          <div className="max-w-3xl mx-auto space-y-6">
            <div className="anim-float inline-flex items-center gap-2 bg-[#0066FF]/8 border border-[#0066FF]/20 text-[#0066FF] text-xs font-bold px-4 py-1.5 rounded-full anim-fade-up">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#0066FF] opacity-75" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-[#0066FF]" />
              </span>
              847 freshers matched so far
            </div>

            <h1 className="anim-fade-up delay-100 text-4xl sm:text-5xl lg:text-6xl font-black tracking-tight leading-tight text-[#111827]">
              Find your roommate{' '}
              <span className="text-[#0066FF]">before</span>{' '}
              orientation.
            </h1>

            <p className="anim-fade-up delay-200 text-lg text-[#6B7280] max-w-xl mx-auto leading-relaxed">
              Browse freshers from your school and course. Connect before campus chaos starts.
            </p>

            <div className="anim-fade-up delay-300 flex justify-center pt-2">
              <div className="h-1 w-24 rounded-full bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />
            </div>
          </div>
        </section>

        {/* ── FILTERS ── */}
        <section className="px-6 pb-10">
          <div className="max-w-7xl mx-auto space-y-4">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-xs text-[#9CA3AF] uppercase tracking-wider font-semibold mr-1 flex items-center gap-1">
                <Filter size={12} /> School
              </span>
              {SCHOOLS.map(s => (
                <button
                  key={s}
                  onClick={() => setSchoolFilter(s)}
                  className={`text-sm px-4 py-1.5 rounded-full border transition-all duration-150 ${
                    schoolFilter === s
                      ? 'bg-[#0066FF] text-white border-[#0066FF] font-semibold'
                      : 'bg-white/60 backdrop-blur-sm border-white/70 text-[#6B7280] hover:border-[#0066FF] hover:text-[#0066FF] hover:bg-white/80'
                  }`}
                >
                  {s}
                </button>
              ))}
            </div>

            <div className="flex flex-wrap items-center gap-2">
              <span className="text-xs text-[#9CA3AF] uppercase tracking-wider font-semibold mr-1 flex items-center gap-1">
                <Users2 size={12} /> Habits
              </span>
              {HABITS.map(h => (
                <button
                  key={h}
                  onClick={() => setHabitsFilter(h)}
                  className={`text-sm px-4 py-1.5 rounded-full border transition-all duration-150 ${
                    habitsFilter === h
                      ? 'bg-[#0066FF] text-white border-[#0066FF] font-semibold'
                      : 'bg-white/60 backdrop-blur-sm border-white/70 text-[#6B7280] hover:border-[#0066FF] hover:text-[#0066FF] hover:bg-white/80'
                  }`}
                >
                  {h}
                </button>
              ))}
            </div>
          </div>
        </section>

        {/* ── PROFILE GRID ── */}
        <section className="px-6 pb-20">
          <div className="max-w-7xl mx-auto">
            {filtered.length === 0 ? (
              <div className="text-center py-24 space-y-4">
                <div className="text-5xl">🤷🏾</div>
                <p className="text-[#6B7280] text-lg max-w-sm mx-auto leading-relaxed">
                  No freshers match your filters yet. Be the first to join from your school!
                </p>
                <a href="/#waitlist" className="inline-flex items-center gap-1.5 bg-[#1F2937] hover:bg-[#111827] text-white font-semibold text-sm px-5 py-2.5 rounded-full transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(31,41,55,0.35)]">
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

        {/* ── BOTTOM CTA ── */}
        <section className="px-6 pb-20">
          <div className="max-w-2xl mx-auto text-center bg-white/65 backdrop-blur-xl border border-white/75 shadow-[0_8px_32px_rgba(0,0,0,0.08),inset_0_1px_0_rgba(255,255,255,0.8)] rounded-3xl px-8 py-14">
            <div className="flex justify-center mb-6">
              <div className="h-1 w-16 rounded-full bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />
            </div>
            <h2 className="text-3xl sm:text-4xl font-black text-[#111827] mb-4">
              Ready to find your match?
            </h2>
            <p className="text-[#6B7280] text-base leading-relaxed max-w-md mx-auto mb-8">
              Join thousands of Ghana freshers already connecting on UNIFY before orientation week.
            </p>
            <a href="/#waitlist" className="inline-flex items-center gap-2 bg-[#1F2937] hover:bg-[#111827] text-white font-black text-base px-8 py-3.5 rounded-full transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(31,41,55,0.35)]">
              Join the waitlist <ArrowRight size={16} />
            </a>
          </div>
        </section>

        {/* ── FOOTER ── */}
        <footer className="bg-[#0066FF]/95 backdrop-blur-xl px-6 pt-8 pb-6">
          <div className="max-w-7xl mx-auto text-center text-sm text-white/70">
            © 2026 UNIFY · Ghana 🇬🇭 · Built for freshers
          </div>
          <div className="max-w-6xl mx-auto mt-4 h-[3px] rounded-full bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />
        </footer>

      </div>

      {toast && <Toast name={toast} onClose={() => setToast(null)} />}
    </div>
  );
}
