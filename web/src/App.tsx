import { BrowserRouter, Routes, Route } from 'react-router-dom'
import LoginPage from './pages/login.tsx'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
      </Routes>
    </BrowserRouter>
  );
}