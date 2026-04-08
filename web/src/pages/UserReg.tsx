import NewLineEntry from '../components/NewLineEntry.tsx'
import StatusBanner from '../components/NewStatusBanner';
import logo from '../assets/gnorg-logo.png';
import { Link } from 'react-router-dom';
import { useState, useEffect } from 'react'
import { API_BASE } from '../api';

export default function UserReg() {

    // Setting use states.
    const [email, setEmail] = useState("");
    const [username, setUsername] = useState("");
    const [password1, setPassword1] = useState("");
    const [password2, setPassword2] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const [success, setSuccess] = useState(false);

    const ERROR_MESSAGES: Record<string, string> = {
        USER_TAKEN: "That username is already taken.",
        EMAIL_TAKEN: "An account with that email already exists.",
        PASSWORD_TOO_SHORT: "Password must be at least 8 characters.",
    };

    // Handle submitting registration.
    const handleSubmit = async () => {
        if (error || !email || !username || !password1 || !password2) return;
        setLoading(true);
        try {
            // Call user registration api.
            const response = await fetch(`${API_BASE}/register`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email, username, password: password1 })
            });

            // Check user registration api response.
            if (!response.ok) {
                const data = await response.json().catch(() => ({}));
                setError(ERROR_MESSAGES[data.message] ?? "Something went wrong, please try again.");
                return;
            }

            setSuccess(true);
        } catch {
            setError("Something went wrong, please try again.");
        } finally {
            setLoading(false);
        }
    }

    // Check email is a valid email format using regex and that both entered
    // passwords match.
    useEffect(() => {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (email && !emailRegex.test(email)) {
            setError("Please enter a valid email");
            return;
        }

        if (password2 && password1 !== password2)
            setError("Password mismatch");
        else
            setError("");
    }, [email, password1, password2])

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
            <div
                className="bg-[#1e2130] text-white rounded-2xl w-full max-w-[520px] mx-4 shadow-2xl flex flex-col overflow-hidden"
                style={{ border: '1px solid rgba(255,255,255,0.1)' }}
            >
                <div className="p-14 flex flex-col gap-6">

                    {/* Logo */}
                    <img src={logo} alt="GNOrg" className="w-10 h-10" />

                    {/* Header */}
                    <div className="flex flex-col gap-1">
                        <h1 className="text-2xl font-bold tracking-tight text-white">Create account</h1>
                        <p className="text-sm text-gray-300">Fill in your details to get started</p>
                    </div>

                    {/* Fields */}
                    <div className="flex flex-col gap-4">
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

                        <div className="flex flex-col gap-1.5">
                            <label className="text-xs font-semibold text-gray-300 uppercase tracking-widest">Username</label>
                            <NewLineEntry
                                title="username"
                                placeholder="your_username"
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                className="bg-[#13151f] border border-[#ffffff20] rounded-lg px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-[#e8f56e] focus:ring-1 focus:ring-[#e8f56e] transition-all w-full"
                            />
                        </div>

                        <div className="flex flex-col gap-1.5">
                            <label className="text-xs font-semibold text-gray-300 uppercase tracking-widest">Password</label>
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

                    {/* Success */}
                    {success && (
                        <StatusBanner type="success" message="Account created! Check your inbox for a verification email before signing in." />
                    )}

                    {/* Error */}
                    {!success && error && (
                        <div className="flex items-center gap-2 bg-red-500/10 border border-red-500/20 rounded-lg px-4 py-3">
                            <svg width="14" height="14" viewBox="0 0 14 14" fill="none" className="shrink-0">
                                <circle cx="7" cy="7" r="6" stroke="#f87171" strokeWidth="1.5"/>
                                <path d="M7 4v3M7 9.5v.5" stroke="#f87171" strokeWidth="1.5" strokeLinecap="round"/>
                            </svg>
                            <p className="text-red-400 text-xs">{error}</p>
                        </div>
                    )}

                    {/* Submit */}
                    {!success && (
                        <button
                            onClick={handleSubmit}
                            disabled={loading}
                            className="w-full bg-[#e8f56e] hover:bg-[#f0f8a0] active:bg-[#d4e050] disabled:opacity-60 disabled:cursor-not-allowed transition-colors text-[#0a0f2e] text-sm font-bold py-3 rounded-lg cursor-pointer tracking-wide shadow-lg"
                        >
                            {loading ? "Creating account..." : "Create Account"}
                        </button>
                    )}

                    {/* Footer */}
                    <p className="text-center text-xs text-gray-300">
                        Already have an account?{' '}
                        <Link to="/login" className="text-[#e8f56e] hover:text-[#f0f8a0] transition-colors font-medium">
                            Sign in
                        </Link>
                    </p>
                </div>
            </div>
        </div>
    );
}