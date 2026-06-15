import { useEffect, useRef } from 'react'
import { Link } from 'react-router-dom'
import AnimatedSection from '../components/AnimatedSection'
import ProjectCard from '../components/ProjectCard'
import { getFeaturedProjects } from '../data/projects'
import { concepts } from '../data/concepts'
import './Home.css'

const HERO_IMAGE = 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=1920&q=85'

const STATS = [
  { value: '11+', label: 'Vjet eksperiencë' },
  { value: '200+', label: 'Banesa të ndërtuara' },
  { value: '6', label: 'Projekte aktive' },
  { value: '100%', label: 'Klientë të kënaqur' },
]

export default function Home() {
  const heroRef = useRef(null)
  const featuredProjects = getFeaturedProjects().slice(0, 3)

  useEffect(() => {
    const hero = heroRef.current
    if (!hero) return
    const onScroll = () => {
      const y = window.scrollY
      hero.style.transform = `translateY(${y * 0.35}px)`
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <div className="home">
      {/* ── Hero ── */}
      <section className="hero">
        <div className="hero__bg-wrap">
          <img ref={heroRef} src={HERO_IMAGE} alt="" className="hero__bg" aria-hidden="true" />
          <div className="hero__overlay" />
        </div>
        <div className="hero__content container">
          <AnimatedSection>
            <span className="hero__label">Prishtinë · Kosovë</span>
            <h1 className="hero__title">
              Jeto sipas<br />
              <em>standardit</em><br />
              tënd
            </h1>
            <p className="hero__subtitle">
              Komplekse rezidenciale premium në Velania<br className="hero__br" /> dhe Prishtina e Re
            </p>
            <div className="hero__actions">
              <Link to="/projektet" className="btn btn-light">Shiko Projektet</Link>
              <Link to="/kontakti" className="btn btn-outline-light">Na Kontakto</Link>
            </div>
          </AnimatedSection>
        </div>
        <div className="hero__scroll-hint" aria-hidden="true">
          <div className="hero__scroll-line" />
          <span>Zbulo</span>
        </div>
      </section>

      {/* ── Stats ── */}
      <section className="home-stats">
        <div className="container home-stats__inner">
          {STATS.map((s, i) => (
            <AnimatedSection key={s.label} delay={i * 80} className="home-stats__item">
              <span className="home-stats__value">{s.value}</span>
              <span className="home-stats__label">{s.label}</span>
            </AnimatedSection>
          ))}
        </div>
      </section>

      {/* ── Featured Projects ── */}
      <section className="home-projects">
        <div className="container">
          <AnimatedSection className="home-projects__header">
            <span className="section-label">Projektet tona</span>
            <h2 className="home-projects__title">Zgjidhjet<br />rezidenciale<br /><em>premium</em></h2>
            <p className="home-projects__sub">
              Zbuloni koleksionin tonë të projekteve<br />rezidenciale në Prishtinë.
            </p>
            <Link to="/projektet" className="btn btn-outline home-projects__all-link">
              Të gjitha projektet →
            </Link>
          </AnimatedSection>

          <div className="home-projects__grid">
            {featuredProjects.map((p, i) => (
              <AnimatedSection key={p.id} delay={i * 100}>
                <ProjectCard project={p} />
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* ── About Teaser ── */}
      <section className="home-about">
        <div className="container home-about__inner">
          <AnimatedSection className="home-about__text">
            <span className="section-label">Rreth nesh</span>
            <h2 className="home-about__title">Mbi një dekadë<br /><em>ekselencë</em><br />ndërtimore</h2>
            <div className="divider" />
            <p>
              Dulon Sh.p.k është kompani ndërtimi e themeluar në vitin 2013 me mision të qartë: të ndërtojë hapësira jetese të cilësisë ndërkombëtare në Prishtinë. Me ekipin tonë të arkitektëve, inxhinierëve dhe specialistëve të brendshëm, çdo projekt trajtohet si një vepër unike.
            </p>
            <p>
              Nga Velania deri tek Prishtina e Re, projektet tona kombinojnë dizajnin bashkëkohor me materialin e cilësisë më të lartë dhe respektimin rigoroz të afateve të dorëzimit.
            </p>
            <Link to="/rreth-nesh" className="btn btn-primary" style={{ marginTop: '1.5rem' }}>
              Mëso më shumë
            </Link>
          </AnimatedSection>

          <AnimatedSection className="home-about__image-wrap" delay={150}>
            <img
              src="/images/dulon/dulon-02.jpg"
              alt="Rezidenca Dulon"
              className="home-about__image"
              loading="lazy"
            />
            <div className="home-about__badge">
              <span className="home-about__badge-value">2013</span>
              <span className="home-about__badge-label">Themeluar</span>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* ── Concepts Teaser ── */}
      <section className="home-concepts">
        <div className="container">
          <AnimatedSection className="home-concepts__header">
            <span className="section-label">Konceptet tona</span>
            <h2 className="home-concepts__title">Jetesa e<br /><em>dizajnuar</em><br />për ty</h2>
          </AnimatedSection>

          <div className="home-concepts__grid">
            {concepts.map((c, i) => (
              <AnimatedSection key={c.id} delay={i * 90} className="home-concepts__card">
                <div
                  className="home-concepts__card-img"
                  style={{ backgroundImage: `url(${c.image})` }}
                />
                <div className="home-concepts__card-body">
                  <span className="home-concepts__card-tag" style={{ color: c.accentColor }}>
                    {c.tagline}
                  </span>
                  <h3 className="home-concepts__card-name">{c.name}</h3>
                  <p className="home-concepts__card-desc">{c.description}</p>
                </div>
              </AnimatedSection>
            ))}
          </div>

          <AnimatedSection className="home-concepts__cta-wrap">
            <Link to="/konceptet" className="btn btn-outline">Shiko të gjitha konceptet</Link>
          </AnimatedSection>
        </div>
      </section>

      {/* ── CTA Banner ── */}
      <section className="home-cta">
        <div
          className="home-cta__bg"
          style={{ backgroundImage: `url(https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1600&q=80)` }}
          aria-hidden="true"
        />
        <div className="home-cta__overlay" aria-hidden="true" />
        <div className="container home-cta__content">
          <AnimatedSection>
            <span className="section-label section-label--light">Gati të filloni?</span>
            <h2 className="home-cta__title">Gjeni banesinë<br />tuaj të ëndrrave</h2>
            <p className="home-cta__sub">
              Ekipi ynë i shitjeve është i disponueshëm çdo ditë<br />për t'ju ndihmuar të gjeni zgjidhjen e duhur.
            </p>
            <div className="home-cta__actions">
              <Link to="/projektet" className="btn btn-light">Shiko Projektet</Link>
              <Link to="/kontakti" className="btn btn-outline-light">Cakto Takim</Link>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </div>
  )
}
