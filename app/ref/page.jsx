export default function ReferralInfoPage() {
  return (
    <main className="relative min-h-screen flex items-center justify-center p-6"
          style={{ background: 'linear-gradient(135deg, #EEF1F8 0%, #D1D5DB 50%, #E8EEFF 100%)' }}>

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

      <div className="anim-scale-in w-full max-w-lg mx-auto bg-white/75 backdrop-blur-2xl border border-white/60 shadow-[0_40px_100px_rgba(0,66,255,0.10),0_0_0_1px_rgba(255,255,255,0.5)] rounded-[32px] overflow-hidden">
        {/* Blue top bar */}
        <div className="h-1.5 bg-[#0066FF]" />

        <div className="p-10 text-center">
          {/* Logo */}
          <div className="anim-fade-up flex items-center justify-center gap-2 mb-6">
            <span className="text-2xl font-black tracking-tight text-[#111827]">UNIFY</span>
            <span className="text-xs font-bold px-2 py-0.5 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/25 text-[#0066FF]">GH</span>
          </div>

          {/* Ghana flag stripe */}
          <div className="w-24 h-1 rounded-full mx-auto mb-10 bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />

          <h1 className="anim-fade-up delay-100 text-3xl font-black text-[#111827] mb-3">Share UNIFY with your friends</h1>
          <p className="anim-fade-up delay-200 text-[#6B7280] text-base leading-relaxed mb-12">
            Every fresher who joins through your link moves you up the waitlist. More friends = earlier access.
          </p>

          {/* Steps */}
          <div className="flex flex-col gap-4 mb-12 text-left">
            {[
              { icon: '🔗', title: 'Share your link', desc: 'Every UNIFY member gets a unique referral link to share with their SHS classmates.', delay: 'delay-100' },
              { icon: '👥', title: 'Friend joins', desc: 'When a friend signs up via your link, they get added to the waitlist with your code.', delay: 'delay-200' },
              { icon: '⚡️', title: 'You both get early access', desc: 'Referrals boost your position. More referrals = earlier campus hub access.', delay: 'delay-300' },
            ].map(({ icon, title, desc, delay }) => (
              <div key={title} className={`anim-fade-up ${delay} flex gap-4 items-start bg-white/65 backdrop-blur-xl border border-white/75 shadow-[0_8px_32px_rgba(0,0,0,0.08),inset_0_1px_0_rgba(255,255,255,0.8)] rounded-2xl p-5 hover:bg-white/80 hover:-translate-y-0.5 transition-all duration-300`}>
                <span className="text-2xl shrink-0 mt-0.5">{icon}</span>
                <div>
                  <p className="font-black text-sm text-[#111827] mb-1">{title}</p>
                  <p className="text-xs text-[#6B7280] leading-relaxed">{desc}</p>
                </div>
              </div>
            ))}
          </div>

          <a href="/" className="anim-fade-up delay-400 anim-glow inline-flex items-center gap-2 px-6 py-3 rounded-full font-bold text-sm bg-[#1F2937] text-white hover:bg-[#111827] transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(31,41,55,0.35)]">
            ← Back to UNIFY
          </a>

          <p className="text-[#9CA3AF] text-xs mt-6">Free · No spam · Ghana university freshers only</p>
        </div>
      </div>
    </main>
  );
}
