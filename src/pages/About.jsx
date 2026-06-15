import { Link } from 'react-router-dom'
import AnimatedSection from '../components/AnimatedSection'
import './About.css'

const VALUES = [
  {
    icon: '◈',
    title: 'Cilësia mbi çdo gjë',
    desc: 'Çdo material, çdo detalj, çdo punë — zgjedhim gjithmonë standardin më të lartë të disponueshëm.',
  },
  {
    icon: '◎',
    title: 'Transparenca',
    desc: 'Komunikim i qartë dhe i ndershëm me klientët tanë në çdo hap të procesit, nga kontrata deri tek dorëzimi.',
  },
  {
    icon: '◇',
    title: 'Afate të respektuara',
    desc: '100% e projekteve tona janë dorëzuar brenda afatit të premtuar ose para tij — pa exception.',
  },
  {
    icon: '◉',
    title: 'Inovacion arkitekturor',
    desc: 'Bashkëpunojmë me arkitektë të shquar rajonalë dhe ndërkombëtarë për dizajne të jashtëzakonshëm.',
  },
]

const TEAM = [
  {
    name: 'Artan Kelmendi',
    role: 'Drejtor Ekzekutiv & Themelues',
    image: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&q=80',
    desc: '20 vjet eksperiencë në ndërtim dhe zhvillim rezidencial.',
  },
  {
    name: 'Valbona Berisha',
    role: 'Drejtoreshë Arkitekturës',
    image: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400&q=80',
    desc: 'Arkitekte me diploma nga Milano, eksperte e dizajnit premium.',
  },
  {
    name: 'Liridon Gashi',
    role: 'Drejtor Teknik',
    image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
    desc: 'Inxhinier ndërtimi me 15 vjet eksperiencë në projektet komplekse.',
  },
  {
    name: 'Rina Morina',
    role: 'Drejtoreshë Shitjesh',
    image: 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&q=80',
    desc: 'Specialiste e tregtisë imobiliare me portofol mbi 150 transaksionesh.',
  },
]

export default function About() {
  return (
    <div className="about-page">
      <div className="page-hero">
        <div className="container">
          <AnimatedSection>
            <p className="page-hero__label">Kush jemi</p>
            <h1 className="page-hero__title">Ndërtojmë<br /><em>shtëpi</em>,<br />jo vetëm ndërtesa</h1>
            <p className="page-hero__sub">
              Dulon Sh.p.k është kompania ndërtimore e themeluar me pasion të ndërtojë vendet ku familjet kosovare do të jetojnë momentet e tyre më të çmuara.
            </p>
          </AnimatedSection>
        </div>
      </div>

      {/* ── Story ── */}
      <section className="about-story">
        <div className="container about-story__inner">
          <AnimatedSection className="about-story__text">
            <span className="section-label">Historia jonë</span>
            <h2 className="about-story__title">Nga një vizion<br />tek <em>200+ shtëpi</em></h2>
            <div className="divider" />
            <p>
              Themeluar në vitin 2013 nga Artan Kelmendi, Dulon Sh.p.k filloi me një projekt modest 12-apartamentësh në Velania. Sot, mbi një dekadë më vonë, jemi ndërtuar si kompania ndërtimore me standardet më të larta rezidenciale në Prishtinë.
            </p>
            <p>
              Çdo projekt që kemi realizuar ka qenë një sfidë e re dhe një mundësi për të rritur skedarin e cilësisë. Bashkëpunimi me arkitektë ndërkombëtarë, materialet e importuara dhe një ekip i dedikuar nga çdo drejtim — këto janë themelet e suksesit tonë.
            </p>
            <p>
              Misioni ynë mbetet i pandryshueshëm: të ndërtojmë hapësira jetese ku njerëzit dëshirojnë të jetojnë, të rriten dhe të krijojnë kujtime.
            </p>
          </AnimatedSection>

          <AnimatedSection className="about-story__image-col" delay={120}>
            <div className="about-story__images">
              <img
                src="/images/dulon/dulon-10.jpg"
                alt="Dulon Sh.p.k — projekt"
                className="about-story__img-main"
                loading="lazy"
              />
              <img
                src="/images/dulon/dulon-13.jpg"
                alt="Dulon Sh.p.k — flamujt e projektit"
                className="about-story__img-secondary"
                loading="lazy"
              />
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* ── Stats ── */}
      <section className="about-stats">
        <div className="container about-stats__inner">
          {[
            { value: '2013', label: 'Viti i themelimit' },
            { value: '200+', label: 'Banesa të ndërtuara' },
            { value: '6', label: 'Projekte aktive/të planifikuara' },
            { value: '11+', label: 'Vjet eksperiencë' },
          ].map((s, i) => (
            <AnimatedSection key={s.label} delay={i * 70} className="about-stats__item">
              <span className="about-stats__value">{s.value}</span>
              <span className="about-stats__label">{s.label}</span>
            </AnimatedSection>
          ))}
        </div>
      </section>

      {/* ── Values ── */}
      <section className="about-values">
        <div className="container">
          <AnimatedSection className="about-values__header">
            <span className="section-label">Vlerat tona</span>
            <h2 className="about-values__title">Çfarë na <em>bën të veçantë</em></h2>
          </AnimatedSection>

          <div className="about-values__grid">
            {VALUES.map((v, i) => (
              <AnimatedSection key={v.title} delay={i * 80} className="about-value-card">
                <span className="about-value-card__icon">{v.icon}</span>
                <h3 className="about-value-card__title">{v.title}</h3>
                <p className="about-value-card__desc">{v.desc}</p>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* ── Team ── */}
      <section className="about-team">
        <div className="container">
          <AnimatedSection className="about-team__header">
            <span className="section-label">Ekipi ynë</span>
            <h2 className="about-team__title">Njerëzit pas <em>projekteve</em></h2>
          </AnimatedSection>

          <div className="about-team__grid">
            {TEAM.map((member, i) => (
              <AnimatedSection key={member.name} delay={i * 90} className="about-team-card">
                <div className="about-team-card__image-wrap">
                  <img
                    src={member.image}
                    alt={member.name}
                    className="about-team-card__image"
                    loading="lazy"
                  />
                </div>
                <div className="about-team-card__body">
                  <h3 className="about-team-card__name">{member.name}</h3>
                  <p className="about-team-card__role">{member.role}</p>
                  <p className="about-team-card__desc">{member.desc}</p>
                </div>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* ── CTA ── */}
      <section className="about-cta">
        <div className="container about-cta__inner">
          <AnimatedSection>
            <h2 className="about-cta__title">Gati të punojmë<br />bashkë?</h2>
            <p className="about-cta__sub">
              Kontaktoni ekipin tonë për të diskutuar projektin tuaj të ardhshëm.
            </p>
            <div className="about-cta__actions">
              <Link to="/kontakti" className="btn btn-primary">Na Kontakto</Link>
              <Link to="/projektet" className="btn btn-outline">Shiko Projektet</Link>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </div>
  )
}
