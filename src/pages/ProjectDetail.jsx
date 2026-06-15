import { useState } from 'react'
import { useParams, Link, Navigate } from 'react-router-dom'
import AnimatedSection from '../components/AnimatedSection'
import { getProjectBySlug, statusMap } from '../data/projects'
import './ProjectDetail.css'

export default function ProjectDetail() {
  const { slug } = useParams()
  const project = getProjectBySlug(slug)
  const [activeImg, setActiveImg] = useState(0)
  const [formState, setFormState] = useState({ name: '', phone: '', email: '', message: '' })
  const [sent, setSent] = useState(false)

  if (!project) return <Navigate to="/projektet" replace />

  const status = statusMap[project.status]

  const handleSubmit = (e) => {
    e.preventDefault()
    setSent(true)
  }

  const handleChange = (e) => {
    setFormState((prev) => ({ ...prev, [e.target.name]: e.target.value }))
  }

  return (
    <div className="detail-page">
      {/* ── Gallery Hero ── */}
      <section className="detail-gallery">
        <div className="detail-gallery__main">
          <img
            src={project.images[activeImg]}
            alt={`${project.name} — fotografi ${activeImg + 1}`}
            className="detail-gallery__main-img"
          />
          <div className="detail-gallery__overlay">
            <span className={`status-badge ${status.cls}`}>{status.label}</span>
          </div>
        </div>
        {project.images.length > 1 && (
          <div className="detail-gallery__thumbs">
            {project.images.map((img, i) => (
              <button
                key={i}
                className={`detail-gallery__thumb ${i === activeImg ? 'active' : ''}`}
                onClick={() => setActiveImg(i)}
                aria-label={`Fotografi ${i + 1}`}
              >
                <img src={img.replace('w=1400', 'w=300')} alt="" loading="lazy" />
              </button>
            ))}
          </div>
        )}
      </section>

      {/* ── Content ── */}
      <div className="detail-content container">
        <div className="detail-content__main">
          {/* Breadcrumb */}
          <nav className="detail-breadcrumb" aria-label="Breadcrumb">
            <Link to="/projektet">Projektet</Link>
            <span>›</span>
            <span>{project.name}</span>
          </nav>

          <AnimatedSection>
            <div className="detail-header">
              <div>
                <p className="detail-location">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                  {project.locationLabel}
                </p>
                <h1 className="detail-title">{project.name}</h1>
              </div>
              <div className="detail-header-meta">
                <div className="detail-meta-item">
                  <span className="detail-meta-label">Totali</span>
                  <span className="detail-meta-value">{project.totalApartments} banesa</span>
                </div>
                <div className="detail-meta-item">
                  <span className="detail-meta-label">Kate</span>
                  <span className="detail-meta-value">{project.floors} kate</span>
                </div>
                <div className="detail-meta-item">
                  <span className="detail-meta-label">Viti</span>
                  <span className="detail-meta-value">{project.year}</span>
                </div>
              </div>
            </div>
          </AnimatedSection>

          {/* Description */}
          <AnimatedSection delay={60}>
            <div className="detail-description">
              {project.description.split('\n\n').map((para, i) => (
                <p key={i}>{para}</p>
              ))}
            </div>
          </AnimatedSection>

          {/* Amenities */}
          <AnimatedSection delay={80}>
            <div className="detail-amenities">
              <h2 className="detail-section-title">Komoditetet</h2>
              <div className="detail-amenities__grid">
                {project.amenities.map((a) => (
                  <div key={a} className="detail-amenity-item">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    {a}
                  </div>
                ))}
              </div>
            </div>
          </AnimatedSection>

          {/* Apartment Types */}
          <AnimatedSection delay={100}>
            <div className="detail-types">
              <h2 className="detail-section-title">Tipologjitë e apartamenteve</h2>
              <div className="detail-types__table">
                <div className="detail-types__head">
                  <span>Tipologjia</span>
                  <span>Sipërfaqja</span>
                  <span>Çmimi nga</span>
                  <span>Sasia</span>
                </div>
                {project.types.map((t) => (
                  <div key={t.type} className="detail-types__row">
                    <span className="detail-types__type">{t.type}</span>
                    <span>{t.size}</span>
                    <span className="detail-types__price">{t.priceFrom}</span>
                    <span>{t.count} njësi</span>
                  </div>
                ))}
              </div>
            </div>
          </AnimatedSection>

          {/* Floor Plans placeholder */}
          <AnimatedSection delay={120}>
            <div className="detail-floorplans">
              <h2 className="detail-section-title">Planet e kateve</h2>
              {project.floorPlans && project.floorPlans.length > 0 ? (
                <div className="detail-floorplans__grid">
                  {project.floorPlans.map((fp, i) => (
                    <img
                      key={fp}
                      src={fp}
                      alt={`${project.name} — plan i banesës ${i + 1}`}
                      className="detail-floorplans__img"
                      loading="lazy"
                    />
                  ))}
                </div>
              ) : (
                <div className="detail-floorplans__placeholder">
                  <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                  <p>Planet e kateve janë të disponueshme me kërkesë.</p>
                  <Link to="/kontakti" className="btn btn-outline">Kërko planet</Link>
                </div>
              )}
            </div>
          </AnimatedSection>

          {/* Map placeholder */}
          <AnimatedSection delay={140}>
            <div className="detail-map">
              <h2 className="detail-section-title">Vendndodhja</h2>
              <div className="detail-map__placeholder">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <p>{project.locationLabel}</p>
              </div>
            </div>
          </AnimatedSection>
        </div>

        {/* ── Sidebar: Contact form ── */}
        <aside className="detail-sidebar">
          <div className="detail-contact-card">
            <h3 className="detail-contact-card__title">
              Interesohu për këtë projekt
            </h3>
            <p className="detail-contact-card__sub">
              Ekipi ynë i shitjeve do t'ju kontaktojë brenda 24 orëve.
            </p>

            {sent ? (
              <div className="detail-contact-card__success">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                <p>Faleminderit! Do t'ju kontaktojmë së shpejti.</p>
              </div>
            ) : (
              <form className="detail-contact-card__form" onSubmit={handleSubmit}>
                <div className="detail-form-group">
                  <label htmlFor="name">Emri i plotë *</label>
                  <input
                    id="name"
                    type="text"
                    name="name"
                    value={formState.name}
                    onChange={handleChange}
                    placeholder="Emri juaj"
                    required
                  />
                </div>
                <div className="detail-form-group">
                  <label htmlFor="phone">Telefoni *</label>
                  <input
                    id="phone"
                    type="tel"
                    name="phone"
                    value={formState.phone}
                    onChange={handleChange}
                    placeholder="+383 4X XXX XXX"
                    required
                  />
                </div>
                <div className="detail-form-group">
                  <label htmlFor="email">Email</label>
                  <input
                    id="email"
                    type="email"
                    name="email"
                    value={formState.email}
                    onChange={handleChange}
                    placeholder="email@juaj.com"
                  />
                </div>
                <div className="detail-form-group">
                  <label htmlFor="message">Mesazhi</label>
                  <textarea
                    id="message"
                    name="message"
                    value={formState.message}
                    onChange={handleChange}
                    rows={3}
                    placeholder="Tipologjia e interesit, pyetje..."
                  />
                </div>
                <button type="submit" className="btn btn-primary" style={{ width: '100%', justifyContent: 'center' }}>
                  Dërgo Kërkesën
                </button>
              </form>
            )}

            <div className="detail-contact-card__direct">
              <a href="tel:+38344000000" className="detail-contact-direct-link">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.81a19.79 19.79 0 01-3.07-8.67A2 2 0 012.18 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.1a16 16 0 006 6l.42-.42a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"/></svg>
                +383 44 000 000
              </a>
              <span className="detail-contact-hours">E Hënë–Premte, 09:00–18:00</span>
            </div>
          </div>
        </aside>
      </div>
    </div>
  )
}
