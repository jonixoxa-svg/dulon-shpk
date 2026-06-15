import { useState, useEffect } from 'react'
import { Link, NavLink, useLocation } from 'react-router-dom'
import './Navbar.css'

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)
  const [menuOpen, setMenuOpen] = useState(false)
  const location = useLocation()
  const isHome = location.pathname === '/'

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 60)
    window.addEventListener('scroll', onScroll, { passive: true })
    onScroll()
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    setMenuOpen(false)
    document.body.style.overflow = ''
  }, [location])

  const toggleMenu = () => {
    const next = !menuOpen
    setMenuOpen(next)
    document.body.style.overflow = next ? 'hidden' : ''
  }

  const solid = scrolled || !isHome

  return (
    <header className={`navbar ${solid ? 'navbar--solid' : ''} ${menuOpen ? 'navbar--menu-open' : ''}`}>
      <div className="navbar__inner container">
        <Link to="/" className="navbar__logo">
          <span className="navbar__logo-main">DULON</span>
          <span className="navbar__logo-sub">SH.P.K</span>
        </Link>

        <nav className="navbar__links" aria-label="Navigimi kryesor">
          <NavLink to="/" end>Ballina</NavLink>
          <NavLink to="/projektet">Projektet</NavLink>
          <NavLink to="/konceptet">Konceptet</NavLink>
          <NavLink to="/rreth-nesh">Rreth Nesh</NavLink>
          <NavLink to="/kontakti" className="navbar__contact-link">Kontakti</NavLink>
        </nav>

        <button
          className={`navbar__hamburger ${menuOpen ? 'is-open' : ''}`}
          onClick={toggleMenu}
          aria-label={menuOpen ? 'Mbyll menynë' : 'Hap menynë'}
          aria-expanded={menuOpen}
        >
          <span />
          <span />
          <span />
        </button>
      </div>

      <div className={`navbar__mobile-menu ${menuOpen ? 'is-open' : ''}`} aria-hidden={!menuOpen}>
        <nav>
          <NavLink to="/" end onClick={toggleMenu}>Ballina</NavLink>
          <NavLink to="/projektet" onClick={toggleMenu}>Projektet</NavLink>
          <NavLink to="/konceptet" onClick={toggleMenu}>Konceptet</NavLink>
          <NavLink to="/rreth-nesh" onClick={toggleMenu}>Rreth Nesh</NavLink>
          <NavLink to="/kontakti" onClick={toggleMenu}>Kontakti</NavLink>
        </nav>
      </div>
    </header>
  )
}
