import './globals.css';

export const metadata = {
  title: 'UNIFY — Ghana\'s Student Network',
  description: 'Find your roommate, connect with coursemates, and join your campus hub before freshers week. Built for KNUST, UG, UCC and 180+ schools across Ghana.',
  keywords: 'KNUST, University of Ghana, UCC, freshers, roommate, Ghana students, campus hub',
  openGraph: {
    title: 'UNIFY — Know someone before you reach campus.',
    description: 'Ghana\'s peer-to-peer university transition network. Free forever.',
    url: 'https://unify-lake.vercel.app',
    siteName: 'UNIFY',
    locale: 'en_GH',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'UNIFY — Ghana\'s Student Network',
    description: 'Find your roommate and coursemates before freshers week. KNUST, UG, UCC & 180+ schools.',
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
