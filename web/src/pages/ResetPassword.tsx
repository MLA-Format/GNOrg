import NewLineEntry from '../components/NewLineEntry.tsx'
import { Link, useParams, useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';

export default function ResetPassword() {

    // Setting use states and const vars.
    const { token } = useParams();
    const navigate = useNavigate();
    const [password1, setPassword1] = useState("");
    const [password2, setPassword2] = useState("");
    const [error, setError] = useState("");
    const [success, setSuccess] = useState(false);
    const [countdown, setCountdown] = useState(5);

    // Handle submitting the password change.
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (error || !password1 || password1 !== password2) return;
        try {

            // Call password change api.
            const response = await fetch(`http://localhost:3000/reset-password/${token}`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ password: password1 })
            });

            // Check password change api.
            if (!response.ok) {
                const data = await response.json();
                setError(data.message === "RESET_TOKEN_EXPIRED" ? "This reset link has expired." : "Invalid or already used reset link.");
                return;
            }

            setSuccess(true);
        } catch {
            setError("Something went wrong, please try again.");
        }
    }

    // Check that both passwords match.
    useEffect(() => {
        if (password2 && password1 !== password2)
            setError("Password mismatch");
        else
            setError("");
    }, [password1, password2]);

    // Redirect use on successful reset.
    useEffect(() => {
        if (!success) return;
        if (countdown === 0) { navigate("/login"); return; }
        const t = setTimeout(() => setCountdown(c => c - 1), 1000);
        return () => clearTimeout(t);
    }, [success, countdown, navigate]);

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
                        <h1 className="text-2xl font-bold tracking-tight text-white">New password</h1>
                        <p className="text-sm text-gray-300">Choose a strong password for your account</p>
                    </div>

                    {success ? (
                        <div className="flex items-center gap-2 bg-[#e8f56e]/10 border border-[#e8f56e]/20 rounded-lg px-4 py-3">
                            <svg width="14" height="14" viewBox="0 0 14 14" fill="none" className="shrink-0">
                                <circle cx="7" cy="7" r="6" stroke="#e8f56e" strokeWidth="1.5"/>
                                <path d="M4.5 7l2 2 3-3" stroke="#e8f56e" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                            </svg>
                            <p className="text-[#e8f56e] text-xs">Password reset successful. Redirecting to login in {countdown}s...</p>
                        </div>
                    ) : (
                        <>
                            <div className="flex flex-col gap-4">
                                <div className="flex flex-col gap-1.5">
                                    <label className="text-xs font-semibold text-gray-300 uppercase tracking-widest">New Password</label>
                                    <NewLineEntry
                                        title="password1"
                                        type="password"
                                        placeholder="••••••••"
                                        value={password1}
                                        onChange={(e) => setPassword1(e.target.value)}
                                        className="bg-[#13151f] border border-[#ffffff20] rounded-lg px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-[#e8f56e] focus:ring-1 focus:ring-[#e8f56e] transition-all w-full"
                                    />
                                </div>

                                <div className="flex flex-col gap-1.5">
                                    <label className="text-xs font-semibold text-gray-300 uppercase tracking-widest">Confirm Password</label>
                                    <NewLineEntry
                                        title="password2"
                                        type="password"
                                        placeholder="••••••••"
                                        value={password2}
                                        onChange={(e) => setPassword2(e.target.value)}
                                        className={`bg-[#13151f] border rounded-lg px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none transition-all w-full ${
                                            password2 && password1 !== password2
                                                ? 'border-red-500 focus:border-red-500 focus:ring-1 focus:ring-red-500'
                                                : password2 && password1 === password2
                                                ? 'border-[#e8f56e] focus:border-[#e8f56e] focus:ring-1 focus:ring-[#e8f56e]'
                                                : 'border-[#ffffff20] focus:border-[#e8f56e] focus:ring-1 focus:ring-[#e8f56e]'
                                        }`}
                                    />
                                </div>
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
                                Reset Password
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