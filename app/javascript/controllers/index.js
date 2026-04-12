import { Application } from "@hotwired/stimulus"
import ScrollAnimationController from "./scroll_animation_controller"

export const application = Application.start()
application.register("scroll-animation", ScrollAnimationController)