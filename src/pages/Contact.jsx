import { useState } from 'react'
import AnimatedSection from '../components/AnimatedSection'
import './Contact.css'

const INFO = [
  {
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
    ),
    label: 'Adresa',
    value: 'Rr. Nëna Terezë 40\nPrishtinë 10000, Kosovë',
  },
  {
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.81a19.79 19.79 0 01-3.07-8.67A2 2 0 012.18 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.1a16 16 0 006 6l.42-.42a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"/></svg>
    ),
    label: 'Telefoni',
    value: '+383 44 000 000\n+383 44 111 111',
  },
  {
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
    ),
    label: 'Email',
    value: 'info@dulonshpk.com\nshitjet@dulonshpk.com',
  },
  {
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
    ),
    label: 'Orari i punës',
    value: 'E Hënë – E Premte: 09:00 – 18:00\nE Shtunë: 10:00 – 14:00',
  },
]

export default function Contact() {
  const [form, setForm] = useState({
    name: '', phone: '', email: '', interest: '', message: '',
  })
  const [sent, setSent] = useState(false)

  const handleChange = (e) => {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }))
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    setSent(true)
  }

  return (
    <div className="contact-page">
      <div className="page-hero">
        <div className="container">
          <AnimatedSection>
            <p className="page-hero__label">Na shkruani</p>
            <h1 className="page-hero__title">Le të <em>flasim</em></h1>
            <p className="page-hero__sub">
              Jemi të disponueshëm çdo ditë pune për t'ju ndihmuar të gjeni banesinë tuaj të përsosur ose për t'ju dhënë çdo informacion rreth projekteve tona.
            </p>
          </AnimatedSection>
        </div>
      </div>

      <section className="contact-main">
        <div className="container contact-main__inner">
          {/* Info sidebar */}
          <AnimatedSection className="contact-info">
            <h2 className="contact-info__title">Informacionet<br />e kontaktit</h2>
            <div className="divider" />
            <div className="contact-info__items">
              {INFO.map((item) => (
                <div key={item.label} className="contact-info-item">
                  <div className="contact-info-item__icon">{item.icon}</div>
                  <div className="contact-info-item__text">
                    <span className="contact-info-item__label">{item.label}</span>
                    {item.value.split('\n').map((line, i) => (
                      <span key={i} className="contact-info-item__value">{line}</span>
                    ))}
                  </div>
                </div>
              ))}
            </div>

            {/* Map placeholder */}
            <div className="contact-map-placeholder">
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
              <span>Rr. Nëna Terezë 40, Prishtinë</span>
            </div>
          </AnimatedSection>

          {/* Form */}
          <AnimatedSection className="contact-form-wrap" delay={100}>
            {sent ? (
              <div className="contact-form-success">
                <div className="contact-form-success__icon">
                  <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                </div>
                <h3>Faleminderit!</h3>
                <p>Mesazhi juaj u dërgua me sukses. Ekipi ynë do t'ju kontaktojë brenda 24 orëve.</p>
                <button className="btn btn-outline" onClick={() => setSent(false)}>
                  Dërgo mesazh tjetër
                </button>
              </div>
            ) : (
              <>
                <h2 className="contact-form-title">Dërgoni mesazh</h2>
                <form className="contact-form" onSubmit={handleSubmit}>
                  <div className="contact-form__row">
                    <div className="contact-form-group">
                      <label htmlFor="cf-name">Emri i plotë *</label>
                      <input
                        id="cf-name"
                        type="text"
                        name="name"
                        value={form.name}
                        onChange={handleChange}
                        placeholder="Emri juaj"
                        required
                      />
                    </div>
                    <div className="contact-form-group">
                      <label htmlFor="cf-phone">Telefoni *</label>
                      <input
                        id="cf-phone"
                        type="tel"
                        name="phone"
                        value={form.phone}
                        onChange={handleChange}
                        placeholder="+383 4X XXX XXX"
                        required
                      />
                    </div>
                  </div>

                  <div className="contact-form-group">
                    <label htmlFor="cf-email">Email</label>
                    <input
                      id="cf-email"
                      type="email"
                      name="email"
                      value={form.email}
                      onChange={handleChange}
                      placeholder="email@juaj.com"
                    />
                  </div>

                  <div className="contact-form-group">
                    <label htmlFor="cf-interest">Interesi juaj</label>
                    <select
                      id="cf-interest"
                      name="interest"
                      value={form.interest}
                      onChange={handleChange}
                    >
                      <option value="">— Zgjidhni projektin —</option>
                      <option value="velania-1">Rezidenca Velania I</option>
                      <option value="velania-2">Rezidenca Velania II</option>
                      <option value="velania-gardens">Velania Gardens</option>
                      <option value="prishre-tower">Prishtina e Re Tower</option>
                      <option value="panorama">Panorama Residence</option>
                      <option value="prishre-villas">Prishtina e Re Villas</option>
                      <option value="other">Informacion i përgjithshëm</option>
                    </select>
                  </div>

                  <div className="contact-form-group">
                    <label htmlFor="cf-message">Mesazhi *</label>
                    <textarea
                      id="cf-message"
                      name="message"
                      value={form.message}
                      onChange={handleChange}
                      rows={5}
                      placeholder="Shkruani këtu pyetjet, interesat ose çdo gjë tjetër që dëshironi të na komunikoni..."
                      required
                    />
                  </div>

                  <button type="submit" className="btn btn-primary contact-form__submit">
                    Dërgo Mesazhin
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                  </button>
                </form>
              </>
            )}
          </AnimatedSection>
        </div>
      </section>
    </div>
  )
}
