import { useScrollAnimation } from '../hooks/useScrollAnimation'

export default function AnimatedSection({ children, className = '', delay = 0, threshold }) {
  const ref = useScrollAnimation(threshold)
  return (
    <div
      ref={ref}
      className={`anim-section ${className}`}
      style={delay ? { transitionDelay: `${delay}ms` } : undefined}
    >
      {children}
    </div>
  )
}
