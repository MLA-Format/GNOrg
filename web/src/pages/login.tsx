import './Login.css'
import NewLineEntry from '../components/NewLineEntry.tsx'
import { Link } from 'react-router-dom';

export default function Login() {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");

    const handleSubmit = async () => { }

    return (
        <div>
            <h1>User login</h1>
            <p>Username</p>
            <NewLineEntry title="username" value={username} onChange={(e) => setUsername(e.target.value)} />
            <p>Password</p>
            <NewLineEntry title="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
            {error && <p style={{color: "red"}}>{error}</p>}
            <button onClick={handleSubmit}>Login</button>
            <Link to="/register">Don't have an account?</Link>
        </div>
    );
}