import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const targets = this.element.querySelectorAll("[data-animate]")

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible")
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.15 })

    targets.forEach(el => observer.observe(el))
  }
}
