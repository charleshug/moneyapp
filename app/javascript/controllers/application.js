import { Application } from "@hotwired/stimulus"
import Sortable from 'stimulus-sortable'


const application = Application.start()
application.register('sortable', Sortable)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

import { Alert, Autosave, Dropdown, Modal, Tabs, Popover, Toggle, Slideover } from "tailwindcss-stimulus-components"
// application.register('alert', Alert)
// application.register('autosave', Autosave)
application.register('dropdown', Dropdown)
// application.register('modal', Modal)
application.register('tabs', Tabs)
// application.register('popover', Popover)
// application.register('toggle', Toggle)
// application.register('slideover', Slideover)

export { application }
