import { BrowserRouter, Routes, Route } from 'react-router-dom'
import LoginPage from './pages/login.tsx'
import UserReg from './pages/UserReg.tsx';
import LandingPage from './pages/Landing.tsx'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<UserReg/>} />
        <Route path="/" element={<LandingPage />} />
      </Routes>
    </BrowserRouter>
  );
}