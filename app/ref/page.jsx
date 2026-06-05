export default function ReferralInfoPage() {
  return (
    <main
      className="relative min-h-screen flex items-center justify-center px-4 py-16"
      style={{ backgroundColor: '#050d20', color: '#fff' }}
    >
      {/* Background gradient blobs */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden -z-10">
        <div style={{ position:'absolute', top:'-20%', right:'-10%', width:'600px', height:'600px', background:'radial-gradient(circle, rgba(251,191,36,0.08) 0%, transparent 70%)', borderRadius:'50%' }} />
        <div style={{ position:'absolute', bottom:'-10%', left:'-10%', width:'500px', height:'500px', background:'radial-gradient(circle, rgba(59,130,246,0.07) 0%, transparent 70%)', borderRadius:'50%' }} />
        <div style={{ position:'absolute', top:'40%', left:'40%', width:'400px', height:'400px', background:'radial-gradient(circle, rgba(16,185,129,0.05) 0%, transparent 70%)', borderRadius:'50%' }} />
      </div>
      <div className="w-full max-w-lg mx-auto text-center">
        {/* Logo */}
        <div className="flex items-center justify-center gap-2 mb-6">
          <span className="text-2xl font-black tracking-tight text-amber-400">
            UNIFY
          </span>
          <span
            className="text-xs font-bold px-2 py-0.5 rounded-full border border-amber-400/40 text-amber-400"
            style={{ background: 'rgba(251,191,36,0.1)' }}
          >
            GH
          </span>
        </div>

        {/* Ghana flag stripe */}
        <div
          className="w-24 h-1 rounded-full mx-auto mb-10"
          style={{
            background: 'linear-gradient(to right, #CE1126, #FCD116, #006B3F)',
          }}
        />

        <h1 className="text-3xl font-black mb-3">
          Share UNIFY with your friends
        </h1>
        <p className="text-slate-400 text-base leading-relaxed mb-12">
          Every fresher who joins through your link moves you up the waitlist.
          More friends = earlier access.
        </p>

        {/* Steps */}
        <div className="flex flex-col gap-4 mb-12 text-left">
          {[
            {
              icon: '🔗',
              title: 'Share your link',
              desc: 'Every UNIFY member gets a unique referral link to share.',
            },
            {
              icon: '👥',
              title: 'Friend joins',
              desc: 'When a friend signs up via your link, they get added to the waitlist with your code.',
            },
            {
              icon: '⚡️',
              title: 'You both get early access',
              desc: 'Referrals boost your position. More referrals = earlier campus hub access.',
            },
          ].map(({ icon, title, desc }) => (
            <div
              key={title}
              className="flex gap-4 items-start rounded-xl border border-white/10 p-4"
              style={{ background: 'rgba(255,255,255,0.06)', backdropFilter: 'blur(4px)' }}
            >
              <span className="text-2xl shrink-0 mt-0.5">{icon}</span>
              <div>
                <p className="font-bold text-sm text-white mb-1">{title}</p>
                <p className="text-xs text-slate-400 leading-relaxed">{desc}</p>
              </div>
            </div>
          ))}
        </div>

        <a
          href="/"
          className="inline-block px-6 py-3 rounded-xl font-bold text-sm transition-all duration-150"
          style={{ background: '#FBBF24', color: '#050d20' }}
        >
          ← Back to UNIFY
        </a>
      </div>
    </main>
  );
}
