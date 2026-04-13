import { Link } from 'react-router-dom';
import logo from '../assets/gnorg-logo.png';

const features = [
    {
        icon: (
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <rect x="2" y="3" width="16" height="13" rx="2" stroke="#0a0f2e" strokeWidth="1.5"/>
                <path d="M6 7h8M6 10h5" stroke="#0a0f2e" strokeWidth="1.5" strokeLinecap="round"/>
            </svg>
        ),
        title: "Build your library",
        description: "Add every game you own. No limits, no subscriptions — your full collection in one place."
    },
    {
        icon: (
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="10" r="7.5" stroke="#0a0f2e" strokeWidth="1.5"/>
                <path d="M7 10l2 2 4-4" stroke="#0a0f2e" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
        ),
        title: "Tag and filter",
        description: "Attach genres and player counts. Find exactly the right game in seconds."
    },
    {
        icon: (
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <path d="M10 2v4M10 14v4M2 10h4M14 10h4" stroke="#0a0f2e" strokeWidth="1.5" strokeLinecap="round"/>
                <circle cx="10" cy="10" r="3" stroke="#0a0f2e" strokeWidth="1.5"/>
            </svg>
        ),
        title: "Always ready",
        description: "Open your collection from any device before game night. No more digging through the closet."
    },
];

export default function LandingPage() {
    return (
        <div className="min-h-screen bg-white landing">
            <style>{`
                .landing .hero-title { font-size: 3.5rem; line-height: 1.1; font-weight: 700; }
                .landing .container { max-width: 1400px; margin: 0 auto; padding: 0 8rem; }
                .landing .fade-in { animation: fadeUp 0.6s ease both; }
                .landing .fade-in-2 { animation: fadeUp 0.6s 0.15s ease both; }
                .landing .fade-in-3 { animation: fadeUp 0.6s 0.3s ease both; }
                .landing .divider { margin: 0 8rem; height: 1px; background: #e8e8e8; }
                @keyframes fadeUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }
                .landing .nav-link:hover { background: #f0f0f0; }
                .landing .btn-primary:hover { background: #1e2130 !important; }
                @media (max-width: 768px) {
                    .landing .container { padding: 0 1.5rem; }
                    .landing .divider { margin: 0 1.5rem; }
                    .landing .hero-title { font-size: 1.8rem; }
                }
            `}</style>

            {/* Nav */}
            <nav style={{ borderBottom: '1px solid #e8e8e8' }}>
                <div className="container flex items-center justify-between py-5">
                    <div className="flex items-center gap-3">
                        <img src={logo} alt="GNOrg logo" style={{ width: 40, height: 40 }} />
                        <span className="text-xl font-bold tracking-tight" style={{ color: '#0a0f2e' }}>
                            GN<span style={{ color: '#8aab00' }}>Org</span>
                        </span>
                    </div>
                    <div className="flex items-center gap-3">
                        <Link to="/login" className="nav-link text-sm font-medium px-4 py-2 rounded-lg transition-colors" style={{ color: '#0a0f2e' }}>
                            Sign in
                        </Link>
                        <Link to="/register" className="btn-primary text-sm font-bold px-5 py-2.5 rounded-lg transition-colors" style={{ background: '#0a0f2e', color: '#e8f56e' }}>
                            Get started
                        </Link>
                    </div>
                </div>
            </nav>

            {/* Hero */}
            <section>
                <div className="container" style={{ paddingTop: 'clamp(3rem, 8vw, 7rem)', paddingBottom: 'clamp(3rem, 8vw, 7rem)' }}>
                    <h1 className="hero-title fade-in mb-6" style={{ color: '#0a0f2e' }}>
                        Your entire game collection,<br />always at hand.
                    </h1>
                    <p className="fade-in-2 leading-relaxed mb-10" style={{ color: '#444', maxWidth: '460px', fontSize: '1rem' }}>
                        GNOrg lets you catalog every board game you own, tag it by genre and player count, and find the right one for any night — without digging through the closet.
                    </p>
                    <div className="fade-in-3 flex items-center gap-5 flex-wrap">
                        <Link to="/register" className="btn-primary text-sm font-bold px-7 py-4 rounded-xl transition-colors" style={{ background: '#0a0f2e', color: '#e8f56e' }}>
                            Create free account
                        </Link>
                        <Link to="/login" className="text-sm font-medium" style={{ color: '#0a0f2e', textDecoration: 'underline', textUnderlineOffset: '4px' }}>
                            Already have an account?
                        </Link>
                    </div>
                </div>
            </section>

            <div className="divider" />

            {/* Features */}
            <section>
                <div className="container" style={{ paddingTop: 'clamp(2.5rem, 5vw, 5rem)', paddingBottom: 'clamp(2.5rem, 5vw, 5rem)' }}>
                    <h2 className="sr-only">Features</h2>
                    <p className="text-xs font-semibold tracking-widest uppercase mb-14" style={{ color: '#444' }}>How it works</p>
                    <div className="grid md:grid-cols-3 grid-cols-1" style={{ gap: '3rem' }}>
                        {features.map(({ icon, title, description }) => (
                            <div key={title} className="flex flex-col gap-4">
                                <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#f5f9d0', border: '1px solid #dde88a' }}>
                                    {icon}
                                </div>
                                <h3 className="text-base font-bold" style={{ color: '#0a0f2e' }}>{title}</h3>
                                <p className="text-sm leading-relaxed" style={{ color: '#555' }}>{description}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            <div className="divider" />

            {/* Stats */}
            <section>
                <div className="container" style={{ paddingTop: 'clamp(2rem, 4vw, 4rem)', paddingBottom: 'clamp(2rem, 4vw, 4rem)' }}>
                    <div className="grid md:grid-cols-3 grid-cols-1 gap-8 text-center">
                        {[
                            { value: "Any device", label: "Access from anywhere" },
                            { value: "Free", label: "No cost, no catch" },
                        ].map(({ value, label }) => (
                            <div key={label} className="flex flex-col gap-2">
                                <span className="text-4xl font-bold" style={{ color: '#0a0f2e' }}>{value}</span>
                                <span className="text-sm font-medium" style={{ color: '#555' }}>{label}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer style={{ borderTop: '1px solid #e8e8e8' }}>
                <div className="container flex items-center justify-between py-8">
                    <div className="flex items-center gap-2.5">
                        <img src={logo} alt="GNOrg logo" style={{ width: 28, height: 28 }} />
                        <span className="text-sm font-bold" style={{ color: '#0a0f2e' }}>GN<span style={{ color: '#8aab00' }}>Org</span></span>
                    </div>
                    <span className="text-xs font-medium" style={{ color: '#555' }}>© {new Date().getFullYear()} GNOrg</span>
                </div>
            </footer>
        </div>
    );
}