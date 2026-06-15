import { Link } from 'react-router-dom'
import { statusMap } from '../data/projects'
import './ProjectCard.css'

export default function ProjectCard({ project, delay = 0 }) {
  const status = statusMap[project.status]

  return (
    <Link
      to={`/projektet/${project.slug}`}
      className="project-card"
      style={delay ? { transitionDelay: `${delay}ms` } : undefined}
    >
      <div className="project-card__image-wrap">
        <img
          src={project.coverImage}
          alt={project.name}
          className="project-card__image"
          loading="lazy"
        />
        <span className={`status-badge ${status.cls} project-card__badge`}>
          {status.label}
        </span>
      </div>

      <div className="project-card__body">
        <div className="project-card__meta">
          <span className="project-card__location">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
            {project.locationLabel}
          </span>
          <span className="project-card__concept">{project.conceptLabel}</span>
        </div>

        <h3 className="project-card__name">{project.name}</h3>
        <p className="project-card__desc">{project.shortDesc}</p>

        <div className="project-card__footer">
          <div className="project-card__stats">
            <span>
              <strong>{project.totalApartments}</strong> banesa
            </span>
            <span>
              <strong>{project.floors}</strong> kate
            </span>
            <span>
              <strong>{project.types.length}</strong> tipologji
            </span>
          </div>
          <span className="project-card__cta">
            Shiko projektin
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
          </span>
        </div>
      </div>
    </Link>
  )
}
