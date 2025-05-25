import { Application } from "@hotwired/stimulus"
import CheckoutFormController from './checkout_form_controller'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

application.register('checkout-form', CheckoutFormController)

export { application }
