import { useState } from 'react'
import AnimatedSection from '../components/AnimatedSection'
import ProjectCard from '../components/ProjectCard'
import { projects } from '../data/projects'
import './Projects.css'

const LOCATIONS = [
  { value: 'all', label: 'Të gjitha' },
  { value: 'Velania', label: 'Velania' },
  { value: 'Prishtina e Re', label: 'Prishtina e Re' },
]

const STATUSES = [
  { value: 'all', label: 'Të gjitha' },
  { value: 'te-perfunduara', label: 'Të përfunduara' },
  { value: 'ne-ndertim', label: 'Në ndërtim' },
  { value: 'ne-planifikim', label: 'Në planifikim' },
]

export default function Projects() {
  const [location, setLocation] = useState('all')
  const [status, setStatus] = useState('all')

  const filtered = projects.filter((p) => {
    const locOk = location === 'all' || p.location === location
    const statusOk = status === 'all' || p.status === status
    return locOk && statusOk
  })

  return (
    <div className="projects-page">
      <div className="page-hero">
        <div className="container">
          <AnimatedSection>
            <p className="page-hero__label">Portofoli ynë</p>
            <h1 className="page-hero__title">Projektet<br /><em>rezidenciale</em></h1>
            <p className="page-hero__sub">
              Gjashtë projekte unike në dy lokacionet kryesore të Prishtinës — secili me karakter dhe vizion të vet.
            </p>
          </AnimatedSection>
        </div>
      </div>

      <div className="projects-page__filters">
        <div className="container projects-page__filters-inner">
          <div className="projects-page__filter-group">
            <span className="projects-page__filter-label">Lokacioni:</span>
            <div className="projects-page__filter-btns">
              {LOCATIONS.map((l) => (
                <button
                  key={l.value}
                  className={`projects-page__filter-btn ${location === l.value ? 'active' : ''}`}
                  onClick={() => setLocation(l.value)}
                >
                  {l.label}
                </button>
              ))}
            </div>
          </div>

          <div className="projects-page__filter-group">
            <span className="projects-page__filter-label">Statusi:</span>
            <div className="projects-page__filter-btns">
              {STATUSES.map((s) => (
                <button
                  key={s.value}
                  className={`projects-page__filter-btn ${status === s.value ? 'active' : ''}`}
                  onClick={() => setStatus(s.value)}
                >
                  {s.label}
                </button>
              ))}
            </div>
          </div>

          <span className="projects-page__count">
            {filtered.length} projekt{filtered.length !== 1 ? 'e' : ''}
          </span>
        </div>
      </div>

      <section className="projects-page__grid-section">
        <div className="container">
          {filtered.length > 0 ? (
            <div className="projects-page__grid">
              {filtered.map((p, i) => (
                <AnimatedSection key={p.id} delay={i * 70}>
                  <ProjectCard project={p} />
                </AnimatedSection>
              ))}
            </div>
          ) : (
            <div className="projects-page__empty">
              <p>Nuk u gjet asnjë projekt për filtrat e zgjedhur.</p>
              <button
                className="btn btn-outline"
                onClick={() => { setLocation('all'); setStatus('all') }}
              >
                Pastro filtrat
              </button>
            </div>
          )}
        </div>
      </section>
    </div>
  )
}
