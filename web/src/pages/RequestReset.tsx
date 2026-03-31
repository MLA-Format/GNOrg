import NewLineEntry from '../components/NewLineEntry.tsx'
import { Link } from 'react-router-dom';
import { useState } from 'react';

export default function ResetLogin() {

    // Setting use states.
    const [email, setEmail] = useState("");
    const [error, setError] = useState("");
    const [submitted, setSubmitted] = useState(false);

    // Handle submitting password reset request.
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            // Call password reset request api.
            const response = await fetch("http://localhost:3000/request-password-reset", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email })
            });

            // Check password reset request api.
            if (!response.ok) {
                const data = await response.json();
                setError(data.message === "EMAIL_NOT_FOUND" ? "No account found with that email." : "Something went wrong, please try again.");
                return;
            }

            setSubmitted(true);
        } catch {
            setError("Something went wrong, please try again.");
        }
    }

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
            <form
                onSubmit={handleSubmit}
                className="bg-[#1e2130] text-white rounded-2xl w-full max-w-[520px] mx-4 shadow-2xl flex flex-col overflow-hidden"
                style={{ border: '1px solid rgba(255,255,255,0.1)' }}
            >
                <div className="p-14 flex flex-col gap-6">
                    <div className="w-10 h-10 rounded-md bg-[#2a2d3e] border border-[#ffffff20]" />

                    <div className="flex flex-col gap-1">
                        <h1 className="text-2xl font-bold tracking-tight text-white">Reset password</h1>
                        <p className="text-sm text-gray-300">Enter your email and we'll send you a reset link</p>
                    </div>

                    {submitted ? (
                        <div className="flex items-center gap-2 bg-[#e8f56e]/10 border border-[#e8f56e]/20 rounded-lg px-4 py-3">
                            <svg width="14" height="14" viewBox="0 0 14 14" fill="none" className="shrink-0">
                                <circle cx="7" cy="7" r="6" stroke="#e8f56e" strokeWidth="1.5"/>
                                <path d="M4.5 7l2 2 3-3" stroke="#e8f56e" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                            </svg>
                            <p className="text-[#e8f56e] text-xs">Reset link sent — check your inbox.</p>
                        </div>
                    ) : (
                        <>
                            <div className="flex flex-col gap-1.5">
                                <label className="text-xs font-semibold text-gray-300 uppercase tracking-widest">Email</label>
                                <NewLineEntry
                                    title="email"
                                    placeholder="you@example.com"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    className="bg-[#13151f] border border-[#ffffff20] rounded-lg px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-[#e8f56e] focus:ring-1 focus:ring-[#e8f56e] transition-all w-full"
                                />
                            </div>

                            {error && (
                                <div className="flex items-center gap-2 bg-red-500/10 border border-red-500/20 rounded-lg px-4 py-3">
                                    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" className="shrink-0">
                                        <circle cx="7" cy="7" r="6" stroke="#f87171" strokeWidth="1.5"/>
                                        <path d="M7 4v3M7 9.5v.5" stroke="#f87171" strokeWidth="1.5" strokeLinecap="round"/>
                                    </svg>
                                    <p className="text-red-400 text-xs">{error}</p>
                                </div>
                            )}

                            <button
                                type="submit"
                                className="w-full bg-[#e8f56e] hover:bg-[#f0f8a0] active:bg-[#d4e050] transition-colors text-[#0a0f2e] text-sm font-bold py-3 rounded-lg cursor-pointer tracking-wide shadow-lg"
                            >
                                Send Reset Link
                            </button>
                        </>
                    )}

                    <p className="text-center text-xs text-gray-300">
                        Remembered it?{' '}
                        <Link to="/login" className="text-[#e8f56e] hover:text-[#f0f8a0] transition-colors font-medium">
                            Sign in
                        </Link>
                    </p>
                </div>
            </form>
        </div>
    );
}