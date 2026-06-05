export default function ReferralInfoPage() {
  return (
    <main className="min-h-screen bg-[#D1D5DB] flex items-center justify-center p-6">
      <div className="w-full max-w-lg mx-auto bg-white rounded-[32px] shadow-[0_40px_100px_-20px_rgba(0,0,0,0.15)] border border-[#E5E7EB] overflow-hidden">
        {/* Blue top bar */}
        <div className="h-1.5 bg-[#0066FF]" />

        <div className="p-10 text-center">
          {/* Logo */}
          <div className="flex items-center justify-center gap-2 mb-6">
            <span className="text-2xl font-black tracking-tight text-[#111827]">UNIFY</span>
            <span className="text-xs font-bold px-2 py-0.5 rounded-full bg-[#0066FF]/10 border border-[#0066FF]/25 text-[#0066FF]">GH</span>
          </div>

          {/* Ghana flag stripe */}
          <div className="w-24 h-1 rounded-full mx-auto mb-10 bg-gradient-to-r from-red-600 via-amber-400 to-green-600" />

          <h1 className="text-3xl font-black text-[#111827] mb-3">Share UNIFY with your friends</h1>
          <p className="text-[#6B7280] text-base leading-relaxed mb-12">
            Every fresher who joins through your link moves you up the waitlist. More friends = earlier access.
          </p>

          {/* Steps */}
          <div className="flex flex-col gap-4 mb-12 text-left">
            {[
              { icon: '🔗', title: 'Share your link', desc: 'Every UNIFY member gets a unique referral link to share with their SHS classmates.' },
              { icon: '👥', title: 'Friend joins', desc: 'When a friend signs up via your link, they get added to the waitlist with your code.' },
              { icon: '⚡️', title: 'You both get early access', desc: 'Referrals boost your position. More referrals = earlier campus hub access.' },
            ].map(({ icon, title, desc }) => (
              <div key={title} className="flex gap-4 items-start bg-[#F9FAFB] border border-[#E5E7EB] rounded-2xl p-5 hover:-translate-y-0.5 transition-transform shadow-[0_4px_12px_rgba(0,0,0,0.04)]">
                <span className="text-2xl shrink-0 mt-0.5">{icon}</span>
                <div>
                  <p className="font-black text-sm text-[#111827] mb-1">{title}</p>
                  <p className="text-xs text-[#6B7280] leading-relaxed">{desc}</p>
                </div>
              </div>
            ))}
          </div>

          <a href="/" className="inline-flex items-center gap-2 px-6 py-3 rounded-full font-bold text-sm bg-[#1F2937] text-white hover:bg-[#111827] transition-all hover:-translate-y-0.5">
            ← Back to UNIFY
          </a>

          <p className="text-[#9CA3AF] text-xs mt-6">Free · No spam · Ghana university freshers only</p>
        </div>
      </div>
    </main>
  );
}
