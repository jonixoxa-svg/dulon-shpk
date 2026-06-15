import { Link } from 'react-router-dom'
import './Footer.css'

export default function Footer() {
  return (
    <footer className="footer">
      <div className="footer__top">
        <div className="container footer__top-inner">
          <div className="footer__brand">
            <div className="footer__logo">
              <span className="footer__logo-main">DULON</span>
              <span className="footer__logo-sub">SH.P.K</span>
            </div>
            <p className="footer__tagline">
              Ndërtojmë shtëpinë tënde të ëndrrave<br />në zemër të Prishtinës.
            </p>
            <div className="footer__social">
              <a href="#" aria-label="Facebook" className="footer__social-link">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18 2h-3a5 5 0 00-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 011-1h3z"/></svg>
              </a>
              <a href="#" aria-label="Instagram" className="footer__social-link">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1112.63 8 4 4 0 0116 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
              </a>
              <a href="#" aria-label="LinkedIn" className="footer__social-link">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M16 8a6 6 0 016 6v7h-4v-7a2 2 0 00-2-2 2 2 0 00-2 2v7h-4v-7a6 6 0 016-6zM2 9h4v12H2z"/><circle cx="4" cy="4" r="2"/></svg>
              </a>
            </div>
          </div>

          <div className="footer__col">
            <h4 className="footer__col-title">Navigimi</h4>
            <ul>
              <li><Link to="/">Ballina</Link></li>
              <li><Link to="/projektet">Projektet</Link></li>
              <li><Link to="/konceptet">Konceptet</Link></li>
              <li><Link to="/rreth-nesh">Rreth Nesh</Link></li>
              <li><Link to="/kontakti">Kontakti</Link></li>
            </ul>
          </div>

          <div className="footer__col">
            <h4 className="footer__col-title">Projektet</h4>
            <ul>
              <li><Link to="/projektet/rezidenca-velania-i">Rezidenca Velania I</Link></li>
              <li><Link to="/projektet/rezidenca-velania-ii">Rezidenca Velania II</Link></li>
              <li><Link to="/projektet/prishtina-re-tower">Prishtina e Re Tower</Link></li>
              <li><Link to="/projektet/panorama-residence">Panorama Residence</Link></li>
              <li><Link to="/projektet">Të gjitha projektet →</Link></li>
            </ul>
          </div>

          <div className="footer__col">
            <h4 className="footer__col-title">Kontakti</h4>
            <ul className="footer__contact-list">
              <li>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                Rr. Nëna Terezë 40, Prishtinë 10000, Kosovë
              </li>
              <li>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.81a19.79 19.79 0 01-3.07-8.67A2 2 0 012.18 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.1a16 16 0 006 6l.42-.42a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"/></svg>
                +383 44 000 000
              </li>
              <li>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                info@dulonshpk.com
              </li>
              <li>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                E Hënë – E Premte: 09:00 – 18:00
              </li>
            </ul>
          </div>
        </div>
      </div>

      <div className="footer__bottom">
        <div className="container footer__bottom-inner">
          <p>© {new Date().getFullYear()} Dulon Sh.p.k. Të gjitha të drejtat e rezervuara.</p>
          <div className="footer__bottom-links">
            <a href="#">Politika e Privatësisë</a>
            <a href="#">Kushtet e Shërbimit</a>
          </div>
        </div>
      </div>
    </footer>
  )
}
