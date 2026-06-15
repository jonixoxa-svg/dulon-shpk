import { HashRouter as Router, Routes, Route, useLocation } from 'react-router-dom'
import { useEffect } from 'react'
import Navbar from './components/Navbar'
import Footer from './components/Footer'
import Home from './pages/Home'
import Projects from './pages/Projects'
import ProjectDetail from './pages/ProjectDetail'
import Concepts from './pages/Concepts'
import About from './pages/About'
import Contact from './pages/Contact'

function ScrollToTop() {
  const { pathname } = useLocation()
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'instant' })
  }, [pathname])
  return null
}

export default function App() {
  return (
    <Router>
      <ScrollToTop />
      <Navbar />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/projektet" element={<Projects />} />
        <Route path="/projektet/:slug" element={<ProjectDetail />} />
        <Route path="/konceptet" element={<Concepts />} />
        <Route path="/rreth-nesh" element={<About />} />
        <Route path="/kontakti" element={<Contact />} />
      </Routes>
      <Footer />
    </Router>
  )
}
