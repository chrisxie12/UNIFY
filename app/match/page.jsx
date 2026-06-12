'use client';

import { useState } from 'react';
import { MapPin, ArrowRight, X, Users, BookOpen, Home, Heart, Filter, Users2 } from 'lucide-react';

const PROFILES = [
  {
    id: 1, name: 'Ama Owusu', initials: 'AO', grad: '#0066FF',
    school: 'KNUST', course: 'Computer Science', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Early riser', 'Quiet study', 'Non-smoker'],
    bio: "Into machine learning and Afrobeats. Looking for a quiet roommate who won't judge my 2am debugging sessions.",
    lookingFor: 'Roommate',
  },
  {
    id: 2, name: 'Kwame Asante', initials: 'KA', grad: '#059669',
    school: 'KNUST', course: 'Mechanical Engineering', year: 'Fresher 2026', hometown: 'Kumasi',
    habits: ['Night owl', 'Gym rat', 'Social'],
    bio: 'Gym 6am, then class. Weekend footballing. Need a roommate who can handle my protein shake collection.',
    lookingFor: 'Both',
  },
  {
    id: 3, name: 'Abena Mensah', initials: 'AM', grad: '#FF6B35',
    school: 'UG Legon', course: 'Economics', year: 'Fresher 2026', hometown: 'Cape Coast',
    habits: ['Early riser', 'Quiet study', 'Non-smoker'],
    bio: 'Love reading, hate noise. Want a roommate who respects study hours and appreciates good jollof.',
    lookingFor: 'Roommate',
  },
  {
    id: 4, name: 'Kofi Boateng', initials: 'KB', grad: '#FF6B35',
    school: 'UG Legon', course: 'Political Science', year: 'Fresher 2026', hometown: 'Tamale',
    habits: ['Social', 'Night owl'],
    bio: 'Debate club president in SHS. Looking for coursemates to form a study group before lectures start.',
    lookingFor: 'Coursemates',
  },
  {
    id: 5, name: 'Efua Asiedu', initials: 'EA', grad: '#be185d',
    school: 'UCC', course: 'Nursing', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Early riser', 'Non-smoker', 'Quiet study'],
    bio: 'Pre-med mindset. Quiet, organized, always studying. Need someone equally serious about their GPA.',
    lookingFor: 'Roommate',
  },
  {
    id: 6, name: 'Yaw Darko', initials: 'YD', grad: '#0891b2',
    school: 'KNUST', course: 'Architecture', year: 'Fresher 2026', hometown: 'Sunyani',
    habits: ['Night owl', 'Social', 'Gym rat'],
    bio: 'Studio nights are my life. Looking for a roommate chill enough to deal with blueprints everywhere.',
    lookingFor: 'Roommate',
  },
  {
    id: 7, name: 'Akosua Tawiah', initials: 'AT', grad: '#d97706',
    school: 'UG Legon', course: 'Psychology', year: 'Fresher 2026', hometown: 'Kumasi',
    habits: ['Quiet study', 'Early riser', 'Non-smoker'],
    bio: 'Mental health advocate and bookworm. Seeking coursemates who take academic integrity seriously.',
    lookingFor: 'Both',
  },
  {
    id: 8, name: 'Nana Osei', initials: 'NO', grad: '#16a34a',
    school: 'KNUST', course: 'Civil Engineering', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Gym rat', 'Social', 'Night owl'],
    bio: 'Engineering is a team sport. Want to build a solid study group from day one.',
    lookingFor: 'Coursemates',
  },
  {
    id: 9, name: 'Adwoa Poku', initials: 'AP', grad: '#dc2626',
    school: 'UCC', course: 'Business Administration', year: 'Fresher 2026', hometown: 'Ho',
    habits: ['Early riser', 'Social', 'Non-smoker'],
    bio: "Entrepreneur at heart. Want a roommate who's motivated and doesn't sleep past 7am.",
    lookingFor: 'Roommate',
  },
  {
    id: 10, name: 'Fiifi Mensah', initials: 'FM', grad: '#0066FF',
    school: 'KNUST', course: 'Electrical Engineering', year: 'Fresher 2026', hometown: 'Tema',
    habits: ['Night owl', 'Quiet study', 'Non-smoker'],
    bio: "PCB designs and lo-fi beats. I'm clean and quiet, need the same in return.",
    lookingFor: 'Roommate',
  },
  {
    id: 11, name: 'Serwa Acheampong', initials: 'SA', grad: '#0066FF',
    school: 'UG Legon', course: 'Law', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Night owl', 'Quiet study'],
    bio: 'Books and briefs. Law school prep starts now. Need serious coursemates for case study groups.',
    lookingFor: 'Coursemates',
  },
  {
    id: 12, name: 'Kwabena Frimpong', initials: 'KF', grad: '#FF6B35',
    school: 'KNUST', course: 'Biochemistry', year: 'Fresher 2026', hometown: 'Takoradi',
    habits: ['Early riser', 'Gym rat', 'Non-smoker'],
    bio: 'Pre-med track. Wake up at 5am to study before lab. Need someone with the same energy.',
    lookingFor: 'Both',
  },
  {
    id: 13, name: 'Maame Serwah', initials: 'MS', grad: '#9333ea',
    school: 'UCC', course: 'Education', year: 'Fresher 2026', hometown: 'Wa',
    habits: ['Social', 'Early riser'],
    bio: 'Teaching is a calling. Friendly, organized, and always down for a good conversation after class.',
    lookingFor: 'Both',
  },
  {
    id: 14, name: 'Ebo Hayford', initials: 'EH', grad: '#059669',
    school: 'UG Legon', course: 'Computer Science', year: 'Fresher 2026', hometown: 'Accra',
    habits: ['Night owl', 'Social', 'Gym rat'],
    bio: "Full-stack dreams. Hackathons, coding bootcamps, and Legon vibes. Link if you're in CS.",
    lookingFor: 'Coursemates',
  },
  {
    id: 15, name: 'Afia Boampong', initials: 'AB', grad: '#0066FF',
    school: 'KNUST', course: 'Pharmacy', year: 'Fresher 2026', hometown: 'Kumasi',
    habits: ['Quiet study', 'Non-smoker', 'Early riser'],
    bio: 'Pharmacy is intense. Looking for a roommate who understands that and keeps things peaceful.',
    lookingFor: 'Roommate',
  },
];

const SCHOOLS = ['All', 'KNUST', 'UG Legon', 'UCC'];
const HABITS = ['All', 'Early riser', 'Night owl', 'Quiet study', 'Social', 'Gym rat', 'Non-smoker'];

function getSchoolStyle(school) {
  if (school === 'KNUST')    return { pill: 'bg-[#FFE8DC] text-black border-black', dot: 'bg-[#FF6B35]' };
  if (school === 'UG Legon') return { pill: 'bg-[#E3EDFF] text-black border-black', dot: 'bg-[#A8C4FF]' };
  if (school === 'UCC')      return { pill: 'bg-[#FFF3D6] text-black border-black', dot: 'bg-amber-400' };
  return { pill: 'bg-white text-[#555] border-black', dot: 'bg-[#555]' };
}

function getLookingForStyle(lookingFor) {
  if (lookingFor === 'Roommate')   return 'bg-[#FFE8DC] text-black border-black';
  if (lookingFor === 'Coursemates') return 'bg-[#E3EDFF] text-black border-black';
  return 'bg-[#FFF3D6] text-black border-black';
}

function getLookingForIcon(lookingFor) {
  if (lookingFor === 'Roommate')   return <Home size={11} />;
  if (lookingFor === 'Coursemates') return <BookOpen size={11} />;
  return <Users size={11} />;
}

function ProfileCard({ profile, onConnect }) {
  const school = getSchoolStyle(profile.school);
  return (
    <div className="bg-white border-2 border-black shadow-[4px_4px_0px_#000] rounded-none p-5 flex flex-col gap-4 hover:-translate-y-1.5 hover:shadow-[6px_6px_0px_#000] transition-all duration-300">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="relative w-16 h-16 rounded-none flex-shrink-0">
            <div
              className="w-full h-full rounded-none flex items-center justify-center text-[#111] font-black text-lg border-2 border-black"
              style={{ background: profile.grad }}
            >
              {profile.initials}
            </div>
            <div className={`absolute bottom-1 right-1 w-3 h-3 rounded-none border-2 border-black ${school.dot}`} />
          </div>
          <div>
            <p className="font-semibold text-black text-sm leading-tight">{profile.name}</p>
            <span className={`inline-block mt-1 text-[11px] px-2 py-0.5 rounded-none border-2 ${school.pill}`}>
              {profile.school}
            </span>
          </div>
        </div>
        <span className={`inline-flex items-center gap-1 text-[11px] px-2 py-1 rounded-none border-2 flex-shrink-0 ${getLookingForStyle(profile.lookingFor)}`}>
          {getLookingForIcon(profile.lookingFor)}
          {profile.lookingFor}
        </span>
      </div>

      <div className="space-y-1">
        <p className="text-black text-sm font-medium">
          {profile.course} · <span className="text-[#555] font-normal">{profile.year}</span>
        </p>
        <p className="text-[#555] text-xs flex items-center gap-1">
          <MapPin size={11} className="text-[#555]" />
          {profile.hometown}
        </p>
      </div>

      <div className="flex flex-wrap gap-1.5">
        {profile.habits.map(habit => (
          <span key={habit} className="text-[11px] px-2 py-0.5 rounded-none bg-white border-2 border-black text-[#555]">
            {habit}
          </span>
        ))}
      </div>

      <p className="text-sm text-[#555] leading-relaxed flex-1">{profile.bio}</p>

      <button
        onClick={() => onConnect(profile.name)}
        className="w-full bg-[#FF6B35] hover:bg-[#E55A22] text-black font-black text-sm py-2.5 rounded-none border-2 border-black shadow-[4px_4px_0px_#000] transition-all hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_#000] flex items-center justify-center gap-2"
      >
        Connect <Heart size={14} />
      </button>
    </div>
  );
}

function Toast({ name, onClose }) {
  return (
    <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 w-full max-w-sm px-4">
      <div className="bg-white border-2 border-black shadow-[4px_4px_0px_#000] rounded-none p-4 flex items-start gap-3">
        <span className="text-xl flex-shrink-0">🔗</span>
        <div className="flex-1 min-w-0">
          <p className="text-black font-semibold text-sm">Link sent to {name}!</p>
          <p className="text-[#555] text-xs mt-0.5 leading-relaxed">
            Join the waitlist to unlock full messaging when UNIFY launches.
          </p>
          <a href="/#waitlist" className="inline-block mt-2 text-xs text-[#555] hover:underline font-medium transition-colors">
            Join waitlist →
          </a>
        </div>
        <button onClick={onClose} className="text-[#555] hover:text-black transition-colors flex-shrink-0 mt-0.5">
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
         style={{ background: '#F4F4F0', fontFamily: 'system-ui, Inter, sans-serif' }}>

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
          0%, 100% { box-shadow: 4px 4px 0px #000; }
          50%       { box-shadow: 6px 6px 0px #000; }
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
      </div>

      <div className="max-w-7xl mx-auto bg-[#F4F4F0] border-2 border-black shadow-[6px_6px_0px_#000] rounded-none overflow-hidden">

        {/* Flat top bar */}
        <div className="h-1.5 bg-[#FF6B35] border-b-2 border-black" />

        {/* ── NAV ── */}
        <nav className="sticky top-0 z-50 bg-[#F4F4F0] border-b-2 border-black">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
            <a href="/" className="flex items-center gap-2">
              <span className="text-lg font-black tracking-tight text-black">UNIFY</span>
              <span className="text-[10px] font-black px-2 py-0.5 rounded-none bg-[#FFF3D6] border-2 border-black text-black">GH</span>
            </a>
            <div className="hidden md:flex items-center gap-6 text-sm text-[#555] font-medium">
              <a href="/" className="hover:text-black transition-colors">Home</a>
              <a href="/hubs" className="hover:text-black transition-colors">Hubs</a>
              <a href="/match" className="relative text-black font-semibold">
                Match
                <span className="absolute -bottom-0.5 left-0 right-0 h-0.5 rounded-none bg-[#FF6B35]" />
              </a>
            </div>
            <a href="/#waitlist" className="inline-flex items-center gap-1.5 bg-[#FF6B35] hover:bg-[#E55A22] text-black font-black text-xs px-4 py-2.5 rounded-none border-2 border-black shadow-[4px_4px_0px_#000] transition-all hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_#000]">
              Get Early Access <ArrowRight size={14} />
            </a>
          </div>
        </nav>

        {/* ── HERO ── */}
        <section className="pt-16 md:pt-24 pb-12 px-6 text-center">
          <div className="max-w-3xl mx-auto space-y-6">
            <div className="anim-float inline-flex items-center gap-2 bg-[#FFE8DC] border-2 border-black text-black text-xs font-bold px-4 py-1.5 rounded-none anim-fade-up">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-none bg-[#FF6B35] opacity-75" />
                <span className="relative inline-flex rounded-none h-2 w-2 bg-[#FF6B35]" />
              </span>
              847 freshers matched so far
            </div>

            <h1 className="anim-fade-up delay-100 text-4xl sm:text-5xl lg:text-6xl font-black tracking-tight leading-tight text-black">
              Find your roommate{' '}
              <span className="text-[#FF6B35]">before</span>{' '}
              orientation.
            </h1>

            <p className="anim-fade-up delay-200 text-lg text-[#555] max-w-xl mx-auto leading-relaxed">
              Browse freshers from your school and course. Connect before campus chaos starts.
            </p>

            <div className="anim-fade-up delay-300 flex justify-center pt-2">
              <div className="h-1 w-24 rounded-none bg-red-600" />
            </div>
          </div>
        </section>

        {/* ── FILTERS ── */}
        <section className="px-6 pb-10">
          <div className="max-w-7xl mx-auto space-y-4">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-xs text-[#555] uppercase tracking-wider font-semibold mr-1 flex items-center gap-1">
                <Filter size={12} /> School
              </span>
              {SCHOOLS.map(s => (
                <button
                  key={s}
                  onClick={() => setSchoolFilter(s)}
                  className={`text-sm px-4 py-1.5 rounded-none border-2 border-black transition-all duration-150 ${
                    schoolFilter === s
                      ? 'bg-[#FF6B35] text-black font-semibold'
                      : 'bg-white text-black hover:bg-[#FFE8DC]'
                  }`}
                >
                  {s}
                </button>
              ))}
            </div>

            <div className="flex flex-wrap items-center gap-2">
              <span className="text-xs text-[#555] uppercase tracking-wider font-semibold mr-1 flex items-center gap-1">
                <Users2 size={12} /> Habits
              </span>
              {HABITS.map(h => (
                <button
                  key={h}
                  onClick={() => setHabitsFilter(h)}
                  className={`text-sm px-4 py-1.5 rounded-none border-2 border-black transition-all duration-150 ${
                    habitsFilter === h
                      ? 'bg-[#FF6B35] text-black font-semibold'
                      : 'bg-white text-black hover:bg-[#FFE8DC]'
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
                <p className="text-[#555] text-lg max-w-sm mx-auto leading-relaxed">
                  No freshers match your filters yet. Be the first to join from your school!
                </p>
                <a href="/#waitlist" className="inline-flex items-center gap-1.5 bg-[#FF6B35] hover:bg-[#E55A22] text-black font-black text-sm px-5 py-2.5 rounded-none border-2 border-black transition-all hover:-translate-y-0.5 shadow-[4px_4px_0px_#000] hover:shadow-[6px_6px_0px_#000]">
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
          <div className="max-w-2xl mx-auto text-center bg-white border-2 border-black shadow-[4px_4px_0px_#000] rounded-none px-8 py-14">
            <div className="flex justify-center mb-6">
              <div className="h-1 w-16 rounded-none bg-red-600" />
            </div>
            <h2 className="text-3xl sm:text-4xl font-black text-black mb-4">
              Ready to find your match?
            </h2>
            <p className="text-[#555] text-base leading-relaxed max-w-md mx-auto mb-8">
              Join thousands of Ghana freshers already connecting on UNIFY before orientation week.
            </p>
            <a href="/#waitlist" className="inline-flex items-center gap-2 bg-[#FF6B35] hover:bg-[#E55A22] text-black font-black text-base px-8 py-3.5 rounded-none border-2 border-black shadow-[4px_4px_0px_#000] transition-all hover:-translate-y-0.5 hover:shadow-[6px_6px_0px_#000]">
              Join the waitlist <ArrowRight size={16} />
            </a>
          </div>
        </section>

        {/* ── FOOTER ── */}
        <footer className="bg-white border-t-2 border-black px-6 pt-8 pb-6">
          <div className="max-w-7xl mx-auto text-center text-sm text-[#555]">
            © 2026 UNIFY · Ghana 🇬🇭 · Built for freshers
          </div>
          <div className="max-w-6xl mx-auto mt-4 h-[3px] rounded-none bg-red-600" />
        </footer>

      </div>

      {toast && <Toast name={toast} onClose={() => setToast(null)} />}
    </div>
  );
}
