import './Login.css'
import NewLineEntry from '../components/NewLineEntry.tsx'
import { Link } from 'react-router-dom';

export default function Login() {
    return (
        <div>
            <h1>User login</h1>
            <p>Username</p>
            <NewLineEntry title="username" />
            <p>Password</p>
            <NewLineEntry title="password" />
            <button>Login</button>
            <Link to="/register">Don't have an account?</Link>
        </div>
    );
}