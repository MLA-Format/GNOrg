import { Link, useParams } from 'react-router-dom';
import { useState, useEffect } from 'react';

type Status = "loading" | "success" | "error";

export default function VerifyEmail() {

    // Setting use states and other const vars.
    const { token } = useParams();
    const [status, setStatus] = useState<Status>("loading");
    const [countdown, setCountdown] = useState(5);

    useEffect(() => {
        const verify = async () => {
            try {
                const response = await fetch(`http://localhost:3000/verify-email/${token}`, {
                    method: "GET"
                });
                setStatus(response.ok ? "success" : "error");
            } catch {
                setStatus("error");
            }
        };
        verify();
    }, [token]);

    useEffect(() => {
        if (status !== "success") return;
        if (countdown === 0) return;
        const t = setTimeout(() => setCountdown(c => c - 1), 1000);
        return () => clearTimeout(t);
    }, [status, countdown]);

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
                    <div className="w-10 h-10 rounded-md bg-[#2a2d3e] border border-[#ffffff20]" />

                    <div className="flex flex-col gap-1">
                        <h1 className="text-2xl font-bold tracking-tight text-white">Email verification</h1>
                        <p className="text-sm text-gray-300">Verifying your account, please wait</p>
                    </div>

                    {status === "loading" && (
                        <div className="flex items-center gap-2 bg-[#ffffff08] border border-[#ffffff15] rounded-lg px-4 py-3">
                            <svg className="animate-spin shrink-0" width="14" height="14" viewBox="0 0 14 14" fill="none">
                                <circle cx="7" cy="7" r="5.5" stroke="#ffffff30" strokeWidth="1.5"/>
                                <path d="M7 1.5A5.5 5.5 0 0 1 12.5 7" stroke="#e8f56e" strokeWidth="1.5" strokeLinecap="round"/>
                            </svg>
                            <p className="text-gray-300 text-xs">Verifying your email...</p>
                        </div>
                    )}

                    {status === "success" && (
                        <div className="flex items-center gap-2 bg-[#e8f56e]/10 border border-[#e8f56e]/20 rounded-lg px-4 py-3">
                            <svg width="14" height="14" viewBox="0 0 14 14" fill="none" className="shrink-0">
                                <circle cx="7" cy="7" r="6" stroke="#e8f56e" strokeWidth="1.5"/>
                                <path d="M4.5 7l2 2 3-3" stroke="#e8f56e" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                            </svg>
                            <p className="text-[#e8f56e] text-xs">Email verified! Redirecting to login in {countdown}s...</p>
                        </div>
                    )}

                    {status === "error" && (
                        <div className="flex items-center gap-2 bg-red-500/10 border border-red-500/20 rounded-lg px-4 py-3">
                            <svg width="14" height="14" viewBox="0 0 14 14" fill="none" className="shrink-0">
                                <circle cx="7" cy="7" r="6" stroke="#f87171" strokeWidth="1.5"/>
                                <path d="M7 4v3M7 9.5v.5" stroke="#f87171" strokeWidth="1.5" strokeLinecap="round"/>
                            </svg>
                            <p className="text-red-400 text-xs">Invalid or expired verification link.</p>
                        </div>
                    )}

                    <p className="text-center text-xs text-gray-300">
                        <Link to="/login" className="text-[#e8f56e] hover:text-[#f0f8a0] transition-colors font-medium">
                            Back to sign in
                        </Link>
                    </p>
                </div>
            </div>
        </div>
    );
}