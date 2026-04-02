import AuthCard from '../components/NewAuthCard';
import ErrorBanner from '../components/NewErrorBanner';
import StatusBanner from '../components/NewStatusBanner';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';

type Status = "loading" | "success" | "error";

export default function VerifyEmail() {

    // Setting use states and other const vars.
    const { token } = useParams();
    const navigate = useNavigate();
    const [status, setStatus] = useState<Status>("loading");
    const [countdown, setCountdown] = useState(5);

    // Call verify email api on mount.
    useEffect(() => {
        const verify = async () => {
            try {
                const response = await fetch(`http://localhost:3000/verify-email/${token}`, {
                    method: "GET"
                });

                if (response.ok) {
                    // Store auth token so login page auto-redirects to dashboard.
                    const data = await response.json();
                    localStorage.setItem("token", data.token);
                    setStatus("success");
                } else {
                    setStatus("error");
                }
            } catch {
                setStatus("error");
            }
        };
        verify();
    }, [token]);

    // Redirect to login on success, which will auto-redirect to dashboard.
    useEffect(() => {
        if (status !== "success") return;
        if (countdown === 0) { navigate("/login"); return; }
        const t = setTimeout(() => setCountdown(c => c - 1), 1000);
        return () => clearTimeout(t);
    }, [status, countdown, navigate]);

    return (
        <AuthCard title="Email verification" subtitle="Verifying your account, please wait">
            {status === "loading" && <StatusBanner type="loading" message="Verifying your email..." />}
            {status === "success" && <StatusBanner type="success" message={`Email verified! Redirecting to dashboard in ${countdown}s...`} />}
            {status === "error" && <ErrorBanner message="Invalid or expired verification link." />}

            <p className="text-center text-xs text-gray-300">
                <Link to="/login" className="text-[#e8f56e] hover:text-[#f0f8a0] transition-colors font-medium">
                    Back to sign in
                </Link>
            </p>
        </AuthCard>
    );
}