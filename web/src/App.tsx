import { BrowserRouter, Routes, Route } from 'react-router-dom'
import LoginPage from './pages/login.tsx'
import UserReg from './pages/UserReg.tsx'
import ResetLogin from './pages/RequestReset.tsx'
import ResetPassword from './pages/ResetPassword.tsx'
import VerifyEmail from './pages/EmailVerified.tsx'

export default function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/login" element={<LoginPage />} />
                <Route path="/register" element={<UserReg />} />
                <Route path="/reset-login" element={<ResetLogin />} />
                <Route path="/reset-password/:token" element={<ResetPassword />} />
                <Route path="/verify-email/:token" element={<VerifyEmail />} />
            </Routes>
        </BrowserRouter>
    );
}