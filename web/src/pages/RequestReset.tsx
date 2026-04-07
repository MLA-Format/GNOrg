import AuthCard from '../components/NewAuthCard';
import ErrorBanner from '../components/NewErrorBanner';
import StatusBanner from '../components/NewStatusBanner';
import NewLineEntry from '../components/NewLineEntry';
import { Link } from 'react-router-dom';
import { useState } from 'react';
import { API_BASE } from '../api';

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
            const response = await fetch(`${import.meta.env.VITE_API_URL}/request-password-reset`, {
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
    };

    return (
        <AuthCard title="Reset password" subtitle="Enter your email and we'll send you a reset link" onSubmit={handleSubmit}>
            {submitted ? (
                <StatusBanner type="success" message="Reset link sent — check your inbox." />
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

                    {error && <ErrorBanner message={error} />}

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
        </AuthCard>
    );
}