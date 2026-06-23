import { useEffect } from 'react'
import { Link, useLocation } from 'react-router-dom'
import AnimatedSection from '../components/AnimatedSection'
import { concepts } from '../data/concepts'
import { projects } from '../data/projects'
import './Concepts.css'

export default function Concepts() {
  const location = useLocation()

  useEffect(() => {
    const id = location.state?.concept
    if (!id) return
    const el = document.getElementById(id)
    if (!el) return
    const timer = setTimeout(() => {
      el.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }, 150)
    return () => clearTimeout(timer)
  }, [location])

  return (
    <div className="concepts-page">
      <div className="page-hero">
        <div className="container">
          <AnimatedSection>
            <p className="page-hero__label">Filozofia jonë</p>
            <h1 className="page-hero__title">Katër mënyra<br />për të <em>jetuar</em></h1>
            <p className="page-hero__sub">
              Çdo projekt i Dulon Sh.p.k zhvillohet sipas njërit nga katër konceptet tona kryesore — secili me vizion, estetikë dhe filozofi jetese të veçantë.
            </p>
          </AnimatedSection>
        </div>
      </div>

      <div className="concepts-page__list">
        {concepts.map((concept, i) => {
          const relatedProjects = projects.filter((p) => p.concept === concept.id)
          const isEven = i % 2 === 0

          return (
            <section
              key={concept.id}
              id={concept.id}
              className={`concept-block ${isEven ? 'concept-block--normal' : 'concept-block--reverse'}`}
            >
              <div className="container concept-block__inner">
                <AnimatedSection className="concept-block__image-col">
                  <div className="concept-block__image-wrap">
                    <img
                      src={concept.image}
                      alt={concept.name}
                      className="concept-block__image"
                      loading="lazy"
                    />
                    <div
                      className="concept-block__accent-strip"
                      style={{ background: concept.accentColor }}
                    />
                  </div>
                </AnimatedSection>

                <AnimatedSection className="concept-block__text-col" delay={120}>
                  <span className="section-label" style={{ color: concept.accentColor }}>
                    {concept.tagline}
                  </span>
                  <h2 className="concept-block__title">{concept.name}</h2>
                  <div className="divider" style={{ background: concept.accentColor }} />
                  <p className="concept-block__desc">{concept.description}</p>

                  <ul className="concept-block__features">
                    {concept.features.map((f) => (
                      <li key={f} className="concept-block__feature">
                        <span
                          className="concept-block__feature-dot"
                          style={{ background: concept.accentColor }}
                        />
                        {f}
                      </li>
                    ))}
                  </ul>

                  {relatedProjects.length > 0 && (
                    <div className="concept-block__projects">
                      <span className="concept-block__projects-label">Projektet:</span>
                      <div className="concept-block__project-links">
                        {relatedProjects.map((p) => (
                          <Link
                            key={p.id}
                            to={`/projektet/${p.slug}`}
                            className="concept-block__project-link"
                          >
                            {p.name} →
                          </Link>
                        ))}
                      </div>
                    </div>
                  )}
                </AnimatedSection>
              </div>
            </section>
          )
        })}
      </div>

      {/* CTA */}
      <section className="concepts-cta">
        <div className="container concepts-cta__inner">
          <AnimatedSection>
            <h2 className="concepts-cta__title">Gjetët konceptin<br />tuaj?</h2>
            <p className="concepts-cta__sub">
              Eksploroni projektet tona dhe gjeni hapësinë<br />që reflekton stilin tuaj të jetesës.
            </p>
            <div className="concepts-cta__actions">
              <Link to="/projektet" className="btn btn-primary">Shiko Projektet</Link>
              <Link to="/kontakti" className="btn btn-outline">Na Kontakto</Link>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </div>
  )
}
