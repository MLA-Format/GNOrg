import logo from '../assets/gnorg-logo.png';
import { Link } from 'react-router-dom';

interface AuthCardProps {
    title: string;
    subtitle: string;
    children: React.ReactNode;
    onSubmit?: (e: React.FormEvent) => void;
}

export default function AuthCard({ title, subtitle, children, onSubmit }: AuthCardProps) {

    const inner = (
        <div className="p-14 flex flex-col gap-6">
            {/* Logo */}
            <Link to="/"><img src={logo} alt="GNOrg" className="w-10 h-10" /></Link>

            {/* Header */}
            <div className="flex flex-col gap-1">
                <h1 className="text-2xl font-bold tracking-tight text-white">{title}</h1>
                <p className="text-sm text-gray-300">{subtitle}</p>
            </div>

            {/* Page-specific content */}
            {children}
        </div>
    );

    const cardClass = "bg-[#1e2130] text-white rounded-2xl w-full max-w-[520px] mx-4 shadow-2xl flex flex-col overflow-hidden";
    const cardStyle = { border: '1px solid rgba(255,255,255,0.1)' };

    return (
        <div
            className="min-h-screen flex items-center justify-center md:pr-[30%]"
            style={{
                background: `linear-gradient(
                    120deg,
                    #e8f56e 0%,
                    #e8f56e 70%,
                    #f0f8a0 70%,
                    #f0f8a0 72%,
                    #f7fcd0 72%,
                    #f7fcd0 74%,
                    #ffffff 74%,
                    #ffffff 76%,
                    #c0c8d8 76%,
                    #c0c8d8 78%,
                    #7080a0 78%,
                    #7080a0 80%,
                    #0a0f2e 80%,
                    #0a0f2e 100%
                )`
            }}
        >
            {onSubmit ? (
                <form onSubmit={onSubmit} className={cardClass} style={cardStyle}>
                    {inner}
                </form>
            ) : (
                <div className={cardClass} style={cardStyle}>
                    {inner}
                </div>
            )}
        </div>
    );
}