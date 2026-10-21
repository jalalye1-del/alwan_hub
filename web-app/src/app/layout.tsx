import type { Metadata, Viewport } from 'next';
import '@/styles/globals.css';

export const metadata: Metadata = {
  title: 'منصة ألوان - Alwan Hub | ألوان تنبض بالحياة',
  description: 'منصة ألوان الإعلامية الصوتية - بث مباشر، برامج، بودكاست، كتب صوتية، استراحة، ألعاب والمزيد',
  keywords: ['ألوان', 'إذاعة', 'بودكاست', 'بث مباشر', 'FM', 'يمن', 'radios', 'podcast'],
  authors: [{ name: 'Alwan Hub' }],
  openGraph: {
    title: 'منصة ألوان - Alwan Hub',
    description: 'ألوان تنبض بالحياة - منصة إعلامية صوتية متكاملة',
    type: 'website',
    locale: 'ar_YE',
    siteName: 'Alwan Hub',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'منصة ألوان - Alwan Hub',
    description: 'ألوان تنبض بالحياة',
  },
  icons: {
    icon: '/favicon/favicon.ico',
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: '#1565C0',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl">
      <head>
        <link
          rel="preload"
          href="/fonts/mahmoud-bold-ultra.ttf"
          as="font"
          type="font/ttf"
          crossOrigin="anonymous"
        />
      </head>
      <body className="min-h-screen bg-gray-50 antialiased">
        {children}
      </body>
    </html>
  );
}
