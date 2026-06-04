import './globals.css';

export const metadata = {
  title: 'UNIFY — Ghana\'s Student Network',
  description: 'Find your roommate, connect with coursemates, and join your campus hub before freshers week. Built for KNUST, UG, UCC and 180+ schools across Ghana.',
  keywords: 'KNUST, University of Ghana, UCC, freshers, roommate, Ghana students, campus hub',
  openGraph: {
    title: "Don't pull up to campus alone, fr. — UNIFY",
    description: 'Ghana\'s fresher network. Find your roommate, link with coursemates, and join your campus hub before matriculation. Free forever.',
    url: 'https://unify-lake.vercel.app',
    siteName: 'UNIFY',
    locale: 'en_GH',
    type: 'website',
    images: [{ url: 'https://unify-lake.vercel.app/og', width: 1200, height: 630, alt: 'UNIFY — Ghana\'s Fresher Network' }],
  },
  twitter: {
    card: 'summary_large_image',
    title: "Don't pull up to campus alone, fr. — UNIFY",
    description: 'Ghana\'s fresher network. KNUST, UG Legon, UCC, UPSA & more.',
    images: ['https://unify-lake.vercel.app/og'],
  },
  icons: {
    icon: '/favicon.svg',
  },
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="bg-[#050d20] text-white antialiased font-sans">
        {children}
      </body>
    </html>
  );
}
