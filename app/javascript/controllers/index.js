// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

const context = require.context(".", true, /_controller\.(js|ts)$/)
application.load(definitionsFromContext(context))
