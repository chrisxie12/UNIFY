'use client';

import { useState } from 'react';
import { ChevronDown } from 'lucide-react';

const FAQS = [
  { q: 'What is UNIFY?', a: "UNIFY is Ghana's peer-to-peer university transition network. It helps freshers find roommates, link with coursemates, and join their official campus hub — all before matriculation day." },
  { q: 'When do campus hubs go live?', a: "We notify you 48 hours before your school hub opens. KNUST, UG Legon, UCC, and UPSA hubs are launching first in 2026. You'll get a message the moment yours is ready." },
  { q: 'Is UNIFY free for freshers?', a: "100% free. No subscription, no hidden charges, no premium tier. We're building this for Ghana's freshers — not to extract money from students already stretched thin." },
  { q: 'How does roommate matching work?', a: "You fill in your habits — neatness, sleep schedule, study preferences, hostel area — and our engine pairs you with compatible freshers. No brokers, no random guessing, no group chat chaos." },
  { q: 'Which universities are supported?', a: "We're launching with KNUST, UG Legon, UCC, UPSA, UDS, and GCTU. More schools will be added before the 2026/2027 academic year. If your school isn't listed, join the waitlist and we'll notify you." },
  { q: "How do I verify I'm a real student?", a: "You can verify using your admission letter or student ID. Verification is optional at signup but required before accessing private hub channels." },
  { q: 'Can I change my school after signing up?', a: "Yes — contact us at unify@email.com and we'll update your profile. Note that hub access is tied to your verified school." },
  { q: 'Is my data private?', a: "Your profile is only visible to verified freshers in your campus hub. We never sell your data. You control what's shown publicly." },
];

function FAQItem({ faq }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="border-b border-white/10 last:border-0">
      <button
        onClick={() => setOpen(!open)}
        aria-expanded={open}
        className="w-full text-left flex items-center justify-between gap-4 py-5 group"
      >
        <span className="font-semibold text-white/80 group-hover:text-amber-400 transition-colors text-sm md:text-base">{faq.q}</span>
        <span className={`flex-shrink-0 w-7 h-7 rounded-full border flex items-center justify-center transition-all duration-300 ${open ? 'rotate-180 bg-[#FF6B35] border-[#FF6B35]' : 'border-[#FF6B35]/40 bg-white/5'}`}>
          <ChevronDown className={`w-4 h-4 transition-colors duration-300 ${open ? 'text-white' : 'text-[#FF6B35]'}`} />
        </span>
      </button>
      <div style={{ display: 'grid', gridTemplateRows: open ? '1fr' : '0fr', transition: 'grid-template-rows 350ms cubic-bezier(0.16,1,0.3,1)' }}>
        <div style={{ overflow: 'hidden' }}>
          <p className="text-white/60 text-sm leading-relaxed pb-5">{faq.a}</p>
        </div>
      </div>
    </div>
  );
}

export default function FAQPage() {
  return (
    <div className="min-h-screen" style={{ background: '#0D1B3E' }}>
      <nav className="px-6 py-4 flex items-center justify-between max-w-7xl mx-auto border-b border-white/10">
        <a href="/" className="flex items-center gap-2">
          <span className="text-xl font-black text-white tracking-tight">UNIFY</span>
          <span className="text-[10px] font-black px-2 py-0.5 rounded-full bg-amber-400/10 border border-amber-400/20 text-amber-400">GH</span>
        </a>
        <a href="/" className="text-sm font-semibold text-white/50 hover:text-white transition-colors">← Back to home</a>
      </nav>
      <div className="max-w-3xl mx-auto px-6 pt-14 pb-10 text-center">
        <div className="inline-flex items-center gap-2 bg-[#FF6B35]/10 border border-[#FF6B35]/20 text-[#FF6B35] text-xs font-bold px-4 py-2 rounded-full mb-6">Frequently Asked Questions</div>
        <h1 className="text-4xl md:text-5xl font-black text-white leading-tight mb-4">Got Questions?<br />We've Got Answers.</h1>
        <p className="text-white/60 text-base max-w-xl mx-auto">Everything you need to know about UNIFY before your first day on campus.</p>
      </div>
      <div className="max-w-3xl mx-auto px-6 pb-24">
        <div className="rounded-3xl border border-white/10 px-6 md:px-10 bg-[#162347]">
          {FAQS.map((faq, i) => <FAQItem key={i} faq={faq} />)}
        </div>
        <div className="mt-10 text-center">
          <p className="text-white/50 text-sm mb-4">Still have questions?</p>
          <a href="mailto:unify@email.com" className="inline-flex items-center gap-2 bg-[#FF6B35] hover:bg-[#E55A22] text-white font-black text-sm px-7 py-3.5 rounded-full shadow-[0_4px_14px_rgba(123,47,190,0.35)] transition-colors">Email us →</a>
        </div>
      </div>
    </div>
  );
}
