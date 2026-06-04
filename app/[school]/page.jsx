import UnifyLanding from '@/components/UnifyLanding';

const VALID = ['knust', 'ug', 'ucc', 'upsa', 'uds', 'gctu'];

const SCHOOL_META = {
  knust: { title: 'UNIFY for KNUST — Fresher Network', description: 'Find your KNUST roommate, link with coursemates, and join the official Brunei & Kotei hub before matriculation.' },
  ug:   { title: 'UNIFY for UG Legon — Fresher Network', description: 'Find your Volta or Limann roommate, link with coursemates, and join the official Legon Class of \'30 hub.' },
  ucc:  { title: 'UNIFY for UCC — Fresher Network', description: 'Find your Casford roommate, link with coursemates, and join the official UCC Class of \'30 hub.' },
  upsa: { title: 'UNIFY for UPSA — Fresher Network', description: 'Connect with UPSA Business and Law freshers and secure your spot in the official Class of \'30 hub.' },
  uds:  { title: 'UNIFY for UDS — Fresher Network', description: 'Connect with UDS freshers across Tamale, Wa, and Navrongo campuses before lectures begin.' },
  gctu: { title: 'UNIFY for GCTU — Fresher Network', description: 'Connect with GCTU Tech and Business freshers and secure your spot in the official hub.' },
};

export async function generateStaticParams() {
  return VALID.map((school) => ({ school }));
}

export async function generateMetadata({ params }) {
  const meta = SCHOOL_META[params.school];
  if (!meta) return {};
  return {
    title: meta.title,
    description: meta.description,
    openGraph: { title: meta.title, description: meta.description },
    twitter: { title: meta.title, description: meta.description },
  };
}

export default function SchoolPage({ params }) {
  if (!VALID.includes(params.school)) return null;
  return <UnifyLanding schoolId={params.school} />;
}
