import './globals.css';

export const metadata = {
  title: 'UNIFY — Find Your Campus Fam | Built for Ghana Freshers',
  description: "The ZeeMee for Ghana. Find your roommate, link with coursemates, and tap into your official campus hub before matriculation.",
  openGraph: {
    type: 'website',
    url: 'https://unify-lake.vercel.app/',
    title: "UNIFY — Don't pull up to campus alone, fr.",
    description: "Find your roommate, link with coursemates, and join your official campus hub before matriculation. Built for Ghana's Class of '30.",
    images: [{ url: 'https://unify-lake.vercel.app/og', width: 1200, height: 630 }],
  },
  twitter: {
    card: 'summary_large_image',
    url: 'https://unify-lake.vercel.app/',
    title: "UNIFY — Don't pull up to campus alone, fr.",
    description: "Find your roommate, link with coursemates, and join your official campus hub before matriculation.",
    images: ['https://unify-lake.vercel.app/og'],
  },
  icons: {
    icon: '/favicon.svg',
    apple: '/apple-touch-icon.svg',
  },
};

export const viewport = {
  themeColor: '#FAF3E8',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@700;900&family=Barlow:wght@400;600&display=swap" rel="stylesheet" />
      </head>
      <body className="antialiased bg-[#FAF3E8]" style={{ fontFamily: "'Barlow', system-ui, sans-serif" }}>
        {children}
      </body>
    </html>
  );
}
