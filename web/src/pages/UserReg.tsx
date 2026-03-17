import './UserReg.css'
import NewLineEntry from '../components/NewLineEntry.tsx'
import { Link } from 'react-router-dom';
import { useState, useEffect } from 'react'

export default function UserReg() {

    const [email, setEmail] = useState("");
    const [username, setUsername] = useState("");
    const [password1, setPassword1] = useState("");
    const [password2, setPassword2] = useState("");
    const [error, setError] = useState("");

    const handleSubmit = async () => {
        if (error) return;
        try {
            const response = await fetch("http://localhost:3000/register", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email, username, password: password1 })
            });

            if (!response.ok) {
                const data = await response.json();
                setError(data.message);
                return;
            }

            // redirect to login on success
        } catch (err) {
            setError("Something went wrong, please try again");
        }
    }

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
        <div>
            <h1>User Registration</h1>
            <p>Email</p>
            <NewLineEntry title="email" value={email} onChange={(e) => setEmail(e.target.value)}/>
            <p>Username</p>
            <NewLineEntry title="username" value={username} onChange={(e) => setUsername(e.target.value)}/>
            <p>Password</p>
            <NewLineEntry title="password1" type="password" value={password1} onChange={(e) => setPassword1(e.target.value)}/>
            <p>Re-enter password</p>
            <NewLineEntry title="password2" type="password" value={password2} onChange={(e) => setPassword2(e.target.value)}/>
            {error && <p style={{color: "red"}}>{error}</p>}
            <button onClick={handleSubmit}>Register</button>
            <Link to="/login">Already have an account?</Link>
        </div>
    );
}