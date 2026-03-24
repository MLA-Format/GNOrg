import './Login.css'
import NewLineEntry from '../components/NewLineEntry.tsx'
import { Link, useNavigate } from 'react-router-dom';
import { useState } from 'react';

export default function Login() {

    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const navigate = useNavigate();
    
    const handleSubmit = async (e: React.SubmitEvent) => {
        e.preventDefault();
        try {
            const response = await fetch("http://localhost:3000/login", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ username, password})
            });

            if (!response.ok) {
                const data = await response.json();
                setError(data.message);
                return;
            }
            navigate("/dashboard");
        } catch {
            setError("Login failed due to internal error. Please try again later.")
        }
    }

    return (
            <form onSubmit={handleSubmit}>
                <p>Username</p>
                <NewLineEntry title="username" value={username} onChange={(e) => setUsername(e.target.value)} />
                <p>Password</p>
                <NewLineEntry title="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
                {error && <p style={{color: "red"}}>{error}</p>}
                <button type="submit">Login</button>
                <Link to="/register">Don't have an account?</Link>
            </form>
    );
}