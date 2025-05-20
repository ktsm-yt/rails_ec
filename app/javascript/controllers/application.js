import { Application } from "@hotwired/stimulus"
import CheckoutFormController from './checkout_form_controller'
import "./controllers"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

application.register('checkout-form', CheckoutFormController)

export { application }
