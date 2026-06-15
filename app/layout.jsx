import './globals.css';
import VercelAnalytics from './analytics';

export const metadata = {
  title: 'UNIFY — Campus Identity & Announcement Platform',
  description: 'UNIFY gives every student a verified campus identity and every university a direct channel to reach them. Built for Ghanaian universities.',
  openGraph: {
    type: 'website',
    url: 'https://unify-lake.vercel.app/',
    title: 'UNIFY — Campus Identity & Announcement Platform',
    description: 'Verified campus identity and official announcements for Ghanaian universities.',
    images: [{ url: 'https://unify-lake.vercel.app/og', width: 1200, height: 630 }],
  },
  twitter: {
    card: 'summary_large_image',
    url: 'https://unify-lake.vercel.app/',
    title: 'UNIFY — Campus Identity & Announcement Platform',
    description: 'Verified campus identity and official announcements for Ghanaian universities.',
    images: ['https://unify-lake.vercel.app/og'],
  },
  icons: {
    icon: '/favicon.svg',
    apple: '/apple-touch-icon.svg',
  },
};

export const viewport = {
  themeColor: '#ffffff',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
      </head>
      <body className="antialiased bg-white" style={{ fontFamily: "system-ui, sans-serif" }}>
        {children}
        <VercelAnalytics />
      </body>
    </html>
  );
}
