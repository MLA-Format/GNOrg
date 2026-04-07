import AuthCard from '../components/NewAuthCard';
import ErrorBanner from '../components/NewErrorBanner';
import NewLineEntry from '../components/NewLineEntry';
import { Link, useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';

export default function Login() {

    // Setting use states and const vars.
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const navigate = useNavigate();

    // If a valid token is already stored, skip login.
    useEffect(() => {
        const token = localStorage.getItem("token");
        if (!token) return;

        try {
            const { exp } = JSON.parse(atob(token.split(".")[1]));
            if (exp * 1000 > Date.now()) navigate("/dashboard");
            else localStorage.removeItem("token");
        } catch {
            localStorage.removeItem("token");
        }
    }, [navigate]);

    // Handle submitting login.
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            // Call login api.
            const response = await fetch(`${import.meta.env.VITE_API_URL}/login`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ username, password })
            });

            // Check login api response.
            if (!response.ok) {
                const data = await response.json();
                setError(data.message);
                return;
            }

            // Store token and redirect user to dashboard.
            const data = await response.json();
            localStorage.setItem("token", data.token);
            navigate("/dashboard");
        } catch {
            setError("Login failed due to internal error. Please try again later.");
        }
    };

    return (
        <AuthCard title="Welcome back" subtitle="Sign in to continue to your account" onSubmit={handleSubmit}>
            <div className="flex flex-col gap-4">
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
                    <div className="flex items-center justify-between">
                        <label className="text-xs font-semibold text-gray-300 uppercase tracking-widest">Password</label>
                        <Link to="/reset-login" className="text-xs text-[#e8f56e] hover:text-[#f0f8a0] transition-colors">
                            Forgot password?
                        </Link>
                    </div>
                    <NewLineEntry
                        title="password"
                        type="password"
                        placeholder="••••••••"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="bg-[#13151f] border border-[#ffffff20] rounded-lg px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-[#e8f56e] focus:ring-1 focus:ring-[#e8f56e] transition-all w-full"
                    />
                </div>
            </div>

            {error && <ErrorBanner message={error} />}

            <button
                type="submit"
                className="w-full bg-[#e8f56e] hover:bg-[#f0f8a0] active:bg-[#d4e050] transition-colors text-[#0a0f2e] text-sm font-bold py-3 rounded-lg cursor-pointer tracking-wide shadow-lg"
            >
                Sign in
            </button>

            <p className="text-center text-xs text-gray-300">
                Don't have an account?{' '}
                <Link to="/register" className="text-[#e8f56e] hover:text-[#f0f8a0] transition-colors font-medium">
                    Create one
                </Link>
            </p>
        </AuthCard>
    );
}