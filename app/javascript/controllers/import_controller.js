import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "companyName", "businessPhone","street1",
     "street2", "city", "state", "zipcode"
  ]

  static values = {
    company: Object
  }

  import_info() {
    const c = this.companyValue
    this.companyNameTarget.value = c.company_name || ""
    this.businessPhoneTarget.value = c.business_phone || ""
    this.street1Target.value = c.customer_street1 || ""
    this.street2Target.value = c.customer_street2 || ""
    this.cityTarget.value = c.customer_city || ""
    this.stateTarget.value = c.customer_state || ""
    this.zipcodeTarget.value = c.customer_zipcode || ""
  }
}
