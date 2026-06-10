export default function ReferralInfoPage() {
  return (
    <main className="relative min-h-screen flex items-center justify-center p-6"
          style={{ background: '#0F0E17' }}>

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
        <div className="absolute -top-1/4 -right-1/4 w-[700px] h-[700px] rounded-full bg-[#7B2FBE]/[0.10] blur-[120px]" />
        <div className="absolute -bottom-1/4 -left-1/4 w-[600px] h-[600px] rounded-full bg-[#00F5D4]/[0.05] blur-[100px]" />
        <div className="absolute top-1/3 left-1/3 w-[400px] h-[400px] rounded-full bg-amber-400/[0.04] blur-[80px]" />
      </div>

      <div className="anim-scale-in w-full max-w-lg mx-auto bg-[#1A1827] border border-white/10 shadow-[0_40px_100px_rgba(123,47,190,0.20)] rounded-[32px] overflow-hidden">
        {/* Gradient top bar */}
        <div className="h-1.5 bg-gradient-to-r from-[#7B2FBE] via-amber-400 to-[#00F5D4]" />

        <div className="p-10 text-center">
          {/* Logo */}
          <div className="anim-fade-up flex items-center justify-center gap-2 mb-6">
            <span className="text-2xl font-black tracking-tight text-white">UNIFY</span>
            <span className="text-xs font-bold px-2 py-0.5 rounded-full bg-amber-400/10 border border-amber-400/25 text-amber-400">GH</span>
          </div>

          {/* Ghana flag stripe */}
          <div className="w-24 h-1 rounded-full mx-auto mb-10 bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />

          <h1 className="anim-fade-up delay-100 text-3xl font-black text-white mb-3">Share UNIFY with your friends</h1>
          <p className="anim-fade-up delay-200 text-white/60 text-base leading-relaxed mb-12">
            Every fresher who joins through your link moves you up the waitlist. More friends = earlier access.
          </p>

          {/* Steps */}
          <div className="flex flex-col gap-4 mb-12 text-left">
            {[
              { icon: '🔗', title: 'Share your link', desc: 'Every UNIFY member gets a unique referral link to share with their SHS classmates.', delay: 'delay-100' },
              { icon: '👥', title: 'Friend joins', desc: 'When a friend signs up via your link, they get added to the waitlist with your code.', delay: 'delay-200' },
              { icon: '⚡️', title: 'You both get early access', desc: 'Referrals boost your position. More referrals = earlier campus hub access.', delay: 'delay-300' },
            ].map(({ icon, title, desc, delay }) => (
              <div key={title} className={`anim-fade-up ${delay} flex gap-4 items-start bg-white/5 border border-white/10 rounded-2xl p-5 hover:border-[#7B2FBE]/40 hover:-translate-y-0.5 transition-all duration-300`}>
                <span className="text-2xl shrink-0 mt-0.5">{icon}</span>
                <div>
                  <p className="font-black text-sm text-white mb-1">{title}</p>
                  <p className="text-xs text-white/60 leading-relaxed">{desc}</p>
                </div>
              </div>
            ))}
          </div>

          <a href="/" className="anim-fade-up delay-400 anim-glow inline-flex items-center gap-2 px-6 py-3 rounded-full font-bold text-sm bg-[#7B2FBE] text-white hover:bg-[#6A1FA8] transition-all hover:-translate-y-0.5 shadow-[0_4px_14px_rgba(123,47,190,0.4)]">
            ← Back to UNIFY
          </a>

          <p className="text-white/30 text-xs mt-6">Free · No spam · Ghana university freshers only</p>
        </div>
      </div>
    </main>
  );
}
