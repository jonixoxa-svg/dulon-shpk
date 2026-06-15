import { useEffect, useRef } from 'react'

export function useScrollAnimation(threshold = 0.12) {
  const ref = useRef(null)

  useEffect(() => {
    const el = ref.current
    if (!el) return

    // Reveal immediately when motion is reduced or the API is unavailable,
    // so content is never left hidden.
    const prefersReduced =
      window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (prefersReduced || typeof IntersectionObserver === 'undefined') {
      el.classList.add('visible')
      return
    }

    // If the element is already in view (or scrolled past — e.g. after a
    // hot reload or restored scroll position), reveal it right away.
    // A fresh IntersectionObserver only fires while an element is
    // intersecting, so elements above the viewport would otherwise stay
    // permanently hidden.
    if (el.getBoundingClientRect().top < window.innerHeight) {
      el.classList.add('visible')
      return
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          el.classList.add('visible')
          observer.unobserve(el)
        }
      },
      { threshold, rootMargin: '0px 0px -40px 0px' }
    )

    observer.observe(el)
    return () => observer.disconnect()
  }, [threshold])

  return ref
}
