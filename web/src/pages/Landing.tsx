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
        description: "Attach genres, player counts, and custom tags. Find exactly the right game in seconds."
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

const container: React.CSSProperties = {
    maxWidth: '1400px',
    margin: '0 auto',
    padding: '0 8rem',
};

export default function LandingPage() {
    return (
        <div className="min-h-screen bg-white" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            <style>{`
                @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=DM+Serif+Display&display=swap');
                .hero-heading { font-family: 'DM Serif Display', serif; }
                .fade-in { animation: fadeUp 0.6s ease both; }
                .fade-in-2 { animation: fadeUp 0.6s 0.15s ease both; }
                .fade-in-3 { animation: fadeUp 0.6s 0.3s ease both; }
                @keyframes fadeUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }
                .hero-title { font-size: 3.5rem; line-height: 1.08; }
                .hero-sub { font-size: 1.05rem; }
                @media (max-width: 768px) {
                    .container-pad { padding: 0 2rem !important; }
                    .hero-title { font-size: 2.2rem !important; }
                }
            `}</style>

            {/* Nav */}
            <nav style={{ borderBottom: '1px solid #e8e8e8' }}>
                <div style={container} className="container-pad flex items-center justify-between py-5">
                    <div className="flex items-center gap-3">
                        <img src={logo} alt="GNOrg logo" style={{ width: 40, height: 40 }} />
                        <span className="text-xl font-bold tracking-tight" style={{ color: '#0a0f2e' }}>
                            GN<span style={{ color: '#8aab00' }}>Org</span>
                        </span>
                    </div>
                    <div className="flex items-center gap-3">
                        <Link
                            to="/login"
                            className="text-sm font-medium px-4 py-2 rounded-lg transition-colors"
                            style={{ color: '#0a0f2e' }}
                            onMouseEnter={e => (e.currentTarget.style.background = '#f0f0f0')}
                            onMouseLeave={e => (e.currentTarget.style.background = 'transparent')}
                        >
                            Sign in
                        </Link>
                        <Link
                            to="/register"
                            className="text-sm font-bold px-5 py-2.5 rounded-lg transition-colors"
                            style={{ background: '#0a0f2e', color: '#e8f56e' }}
                            onMouseEnter={e => (e.currentTarget.style.background = '#1e2130')}
                            onMouseLeave={e => (e.currentTarget.style.background = '#0a0f2e')}
                        >
                            Get started
                        </Link>
                    </div>
                </div>
            </nav>

            {/* Hero */}
            <section>
                <div style={{ ...container, paddingTop: 'clamp(3rem, 8vw, 7rem)', paddingBottom: 'clamp(3rem, 8vw, 7rem)' }} className="container-pad">
                    <h1 className="hero-heading hero-title fade-in mb-6" style={{ color: '#0a0f2e' }}>
                        Your entire game collection, always at hand.
                    </h1>
                    <p className="hero-sub fade-in-2 leading-relaxed mb-10" style={{ color: '#444', maxWidth: '460px' }}>
                        GNOrg lets you catalog every board game you own, tag it by genre and player count, and find the right one for any night — without digging through the closet.
                    </p>
                    <div className="fade-in-3 flex items-center gap-5">
                        <Link
                            to="/register"
                            className="text-sm font-bold px-7 py-4 rounded-xl transition-colors"
                            style={{ background: '#0a0f2e', color: '#e8f56e' }}
                            onMouseEnter={e => (e.currentTarget.style.background = '#1e2130')}
                            onMouseLeave={e => (e.currentTarget.style.background = '#0a0f2e')}
                        >
                            Create free account
                        </Link>
                        <Link
                            to="/login"
                            className="text-sm font-medium transition-colors"
                            style={{ color: '#0a0f2e', textDecoration: 'underline', textUnderlineOffset: '4px' }}
                        >
                            Already have an account?
                        </Link>
                    </div>
                </div>
            </section>

            {/* Divider */}
            <div style={container} className="container-pad">
                <div style={{ height: '1px', background: '#e8e8e8' }} />
            </div>

            {/* Features */}
            <section>
                <div style={{ ...container, paddingTop: 'clamp(2.5rem, 5vw, 5rem)', paddingBottom: 'clamp(2.5rem, 5vw, 5rem)' }} className="container-pad">
                    <p className="text-xs font-semibold tracking-widest uppercase mb-14" style={{ color: '#666' }}>How it works</p>
                    <div className="grid md:grid-cols-3 grid-cols-1 gap-14" style={{ rowGap: '3rem' }}>
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

            {/* Divider */}
            <div style={container} className="container-pad">
                <div style={{ height: '1px', background: '#e8e8e8' }} />
            </div>

            {/* Stats */}
            <section>
                <div style={{ ...container, paddingTop: 'clamp(2rem, 4vw, 4rem)', paddingBottom: 'clamp(2rem, 4vw, 4rem)' }} className="container-pad">
                    <div className="grid md:grid-cols-3 grid-cols-1 gap-8 text-center">
                        {[
                            { value: "Unlimited", label: "Games in your library" },
                            { value: "Any device", label: "Access from anywhere" },
                            { value: "Free", label: "No cost, no catch" },
                        ].map(({ value, label }) => (
                            <div key={label} className="flex flex-col gap-2">
                                <span className="hero-heading text-4xl" style={{ color: '#0a0f2e' }}>{value}</span>
                                <span className="text-sm font-medium" style={{ color: '#555' }}>{label}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer style={{ borderTop: '1px solid #e8e8e8' }}>
                <div style={container} className="container-pad flex items-center justify-between py-8">
                    <div className="flex items-center gap-2.5">
                        <img src={logo} alt="GNOrg logo" style={{ width: 28, height: 28 }} />
                        <span className="text-sm font-bold" style={{ color: '#0a0f2e' }}>GN<span style={{ color: '#8aab00' }}>Org</span></span>
                    </div>
                    <span className="text-xs font-medium" style={{ color: '#888' }}>© {new Date().getFullYear()} GNOrg</span>
                </div>
            </footer>
        </div>
    );
}