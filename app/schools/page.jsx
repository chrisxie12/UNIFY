'use client';

import { useState } from 'react';
import { MapPin, GraduationCap, ArrowRight, Search } from 'lucide-react';

const SCHOOLS = [
  { id: 'knust', name: 'KNUST', full: 'Kwame Nkrumah University of Science & Technology', location: 'Kumasi, Ashanti Region', type: 'Public University', founded: 1952, freshers: '420 freshers waiting', colors: ['#006400', '#FFD700'], initials: 'KN', faculties: ['Engineering', 'Science', 'Business', 'Social Sciences', 'Art & Built Environment'] },
  { id: 'ug', name: 'UG Legon', full: 'University of Ghana', location: 'Legon, Accra', type: 'Public University', founded: 1948, freshers: '310 freshers waiting', colors: ['#003366', '#C0A000'], initials: 'UG', faculties: ['Arts', 'Social Sciences', 'Law', 'Medicine', 'Sciences', 'Business'] },
  { id: 'ucc', name: 'UCC', full: 'University of Cape Coast', location: 'Cape Coast, Central Region', type: 'Public University', founded: 1962, freshers: '185 freshers waiting', colors: ['#8B0000', '#FFD700'], initials: 'UC', faculties: ['Education', 'Sciences', 'Social Sciences', 'Arts', 'Nursing'] },
  { id: 'upsa', name: 'UPSA', full: 'University of Professional Studies, Accra', location: 'Accra, Greater Accra', type: 'Public University', founded: 1965, freshers: '92 freshers waiting', colors: ['#1a1a6e', '#CC0000'], initials: 'UP', faculties: ['Business Administration', 'Applied Sciences', 'Law', 'Management Studies'] },
  { id: 'uds', name: 'UDS', full: 'University for Development Studies', location: 'Tamale, Northern Region', type: 'Public University', founded: 1992, freshers: '67 freshers waiting', colors: ['#004d00', '#FF8C00'], initials: 'UD', faculties: ['Agriculture', 'Applied Sciences', 'Medicine', 'Business', 'Education'] },
  { id: 'gctu', name: 'GCTU', full: 'Ghana Communication Technology University', location: 'Accra, Greater Accra', type: 'Public University', founded: 1973, freshers: '54 freshers waiting', colors: ['#00008B', '#C0C0C0'], initials: 'GC', faculties: ['ICT', 'Engineering', 'Business', 'Communication Studies'] },
  { id: 'ashesi', name: 'Ashesi', full: 'Ashesi University', location: 'Berekuso, Eastern Region', type: 'Private University', founded: 2002, freshers: '38 freshers waiting', colors: ['#8B0000', '#C0C0C0'], initials: 'AU', faculties: ['Engineering', 'Business Administration', 'Computer Science', 'MIS'] },
  { id: 'central', name: 'Central Univ.', full: 'Central University', location: 'Miotso, Greater Accra', type: 'Private University', founded: 1988, freshers: '29 freshers waiting', colors: ['#4B0082', '#FFD700'], initials: 'CU', faculties: ['Business', 'Theology', 'Law', 'Computing & Information Systems'] },
  { id: 'vvu', name: 'VVU', full: 'Valley View University', location: 'Oyibi, Greater Accra', type: 'Private University', founded: 1979, freshers: '22 freshers waiting', colors: ['#1a5276', '#E67E22'], initials: 'VV', faculties: ['Business', 'Health Sciences', 'Education', 'Theology'] },
  { id: 'uew', name: 'UEW', full: 'University of Education, Winneba', location: 'Winneba, Central Region', type: 'Public University', founded: 1992, freshers: '41 freshers waiting', colors: ['#006400', '#CC0000'], initials: 'UE', faculties: ['Education', 'Science Education', 'Arts Education', 'Business Education'] },
  { id: 'gimpa', name: 'GIMPA', full: 'Ghana Institute of Management and Public Administration', location: 'Achimota, Accra', type: 'Public University', founded: 1961, freshers: '18 freshers waiting', colors: ['#003366', '#FF8C00'], initials: 'GI', faculties: ['Management', 'Public Administration', 'Law', 'Technology Innovation'] },
  { id: 'atu', name: 'ATU', full: 'Accra Technical University', location: 'Accra, Greater Accra', type: 'Public Technical University', founded: 1949, freshers: '33 freshers waiting', colors: ['#00008B', '#006400'], initials: 'AT', faculties: ['Engineering', 'Applied Arts', 'Business', 'Built Environment'] },
];

function SchoolCard({ school }) {
  return (
    <div className="rounded-none border-2 border-[#FF6B35] shadow-[4px_4px_0px_#FF6B35] bg-[#162347] hover:shadow-[6px_6px_0px_#FF6B35] transition-all duration-200 overflow-hidden flex flex-col">
      {/* Gradient banner */}
      <div className="h-20 relative flex items-center px-5" style={{ background: `linear-gradient(135deg, ${school.colors[0]}, ${school.colors[1]})` }}>
        <span className="absolute right-4 top-2 text-[56px] font-black pointer-events-none select-none leading-none" style={{ color: 'rgba(255,255,255,0.13)' }}>{school.initials}</span>
        <div className="relative z-10">
          <span className="text-xs font-bold px-2 py-0.5 rounded-none bg-white/20 text-white border border-white/40">{school.type}</span>
        </div>
      </div>
      <div className="p-5 flex-1 flex flex-col">
        <div className="flex items-center gap-2 mb-1">
          <h3 className="font-black text-white text-base">{school.name}</h3>
        </div>
        <p className="text-white/50 text-xs mb-3 truncate">{school.full}</p>
        <div className="flex items-center gap-1.5 text-white/40 text-xs mb-1">
          <MapPin className="w-3 h-3 text-amber-400 shrink-0" />{school.location}
        </div>
        <div className="flex items-center gap-1.5 text-white/40 text-xs mb-4">
          <GraduationCap className="w-3 h-3 text-[#A8C4FF] shrink-0" />Est. {school.founded}
        </div>
        <div className="flex flex-wrap gap-1.5 mb-4 flex-1">
          {school.faculties.slice(0, 3).map(f => (
            <span key={f} className="text-[10px] font-semibold bg-[#FF6B35]/10 text-[#FF6B35] px-2 py-0.5 rounded-none border border-[#FF6B35]/30">{f}</span>
          ))}
          {school.faculties.length > 3 && <span className="text-[10px] font-semibold bg-white/5 text-white/40 px-2 py-0.5 rounded-none border border-white/10">+{school.faculties.length - 3} more</span>}
        </div>
        <div className="flex items-center justify-between pt-3 border-t border-white/10">
          <div className="flex items-center gap-1.5">
            <span className="relative flex h-1.5 w-1.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-none bg-[#A8C4FF] opacity-40" />
              <span className="relative inline-flex rounded-none h-1.5 w-1.5 bg-[#A8C4FF]" />
            </span>
            <span className="text-[11px] font-semibold text-white/50">{school.freshers}</span>
          </div>
          <a href="/hubs" className="inline-flex items-center gap-1 text-xs font-black text-[#A8C4FF] hover:text-white transition-colors rounded-none border-2 border-white px-2 py-0.5">
            Join Hub <ArrowRight className="w-3 h-3" />
          </a>
        </div>
      </div>
    </div>
  );
}

export default function SchoolsPage() {
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState('All');
  const types = ['All', 'Public University', 'Private University', 'Public Technical University'];
  const filtered = SCHOOLS.filter(s => {
    const matchQ = !query || s.name.toLowerCase().includes(query.toLowerCase()) || s.full.toLowerCase().includes(query.toLowerCase()) || s.location.toLowerCase().includes(query.toLowerCase());
    const matchF = filter === 'All' || s.type === filter;
    return matchQ && matchF;
  });

  return (
    <div className="min-h-screen" style={{ background: '#0D1B3E' }}>
      <nav className="px-6 py-4 flex items-center justify-between max-w-7xl mx-auto border-b-2 border-[#FF6B35]">
        <a href="/" className="flex items-center gap-2">
          <span className="text-xl font-black text-white tracking-tight">UNIFY</span>
          <span className="text-[10px] font-black px-2 py-0.5 rounded-none border border-[#FF6B35]/40 text-[#FF6B35]">GH</span>
        </a>
        <div className="hidden md:flex items-center gap-6">
          <a href="/hubs" className="text-sm font-semibold text-white/50 hover:text-white">Hubs</a>
          <a href="/match" className="text-sm font-semibold text-white/50 hover:text-white">Match</a>
          <a href="/faq" className="text-sm font-semibold text-white/50 hover:text-white">FAQ</a>
        </div>
      </nav>
      <div className="max-w-4xl mx-auto px-6 pt-14 pb-10 text-center">
        <div className="inline-flex items-center gap-2 bg-[#FF6B35]/10 border-2 border-[#FF6B35]/40 text-[#FF6B35] text-xs font-bold px-4 py-2 rounded-none mb-6 tracking-widest uppercase">Ghana University Directory</div>
        <h1 className="text-4xl md:text-5xl font-black text-white leading-tight mb-4 uppercase tracking-tight" style={{ fontFamily: "'Barlow Condensed', sans-serif" }}>Find Your School.<br />Claim Your Spot.</h1>
        <p className="text-white/60 text-base max-w-xl mx-auto mb-8">Browse {SCHOOLS.length} Ghanaian universities. Join your campus hub before orientation week.</p>
        <div className="flex items-center gap-2 bg-[#162347] border-2 border-[#FF6B35] rounded-none px-4 py-3 max-w-lg mx-auto">
          <Search className="w-4 h-4 text-white/30 shrink-0" />
          <input type="text" placeholder="Search school, city, or programme…" value={query} onChange={e => setQuery(e.target.value)} className="flex-1 bg-transparent text-white text-sm outline-none placeholder:text-white/30" />
        </div>
      </div>
      <div className="max-w-7xl mx-auto px-6 mb-8">
        <div className="flex gap-2 flex-wrap">
          {types.map(t => (
            <button key={t} onClick={() => setFilter(t)} className={`text-xs font-bold px-4 py-2 rounded-none border-2 transition-all ${filter === t ? 'bg-[#FF6B35] border-[#FF6B35] text-white shadow-[2px_2px_0px_rgba(255,255,255,0.3)]' : 'bg-white/5 border-white/10 text-white/60 hover:border-[#FF6B35] hover:text-[#FF6B35]'}`}>{t}</button>
          ))}
        </div>
      </div>
      <div className="max-w-7xl mx-auto px-6 pb-24">
        {filtered.length === 0 ? (
          <div className="text-center py-20 text-white/40"><p className="text-2xl mb-2">No schools found</p><p className="text-sm">Try a different search term or filter.</p></div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
            {filtered.map(s => <SchoolCard key={s.id} school={s} />)}
          </div>
        )}
        <div className="mt-14 text-center">
          <p className="text-white/50 text-sm mb-5">Your school not listed? We're adding more before the 2026 intake.</p>
          <a href="/" className="inline-flex items-center gap-2 bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-sm px-7 py-3.5 rounded-none border-2 border-white shadow-[3px_3px_0px_rgba(255,255,255,0.3)] transition-colors">Join the Waitlist <ArrowRight className="w-4 h-4" /></a>
        </div>
      </div>
    </div>
  );
}
