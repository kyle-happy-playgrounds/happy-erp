//import { Controller } from "@hotwired/stimulus"

//export default class extends Controller {
  //connect() {
    //this.element.textContent = "Hello World!"
  //}
//}
//^^^^^^
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

	static values = {
    customer: Object,
    company: Object,
	quote: Object
  }
  static targets = [ "address_source", "ship_same_bill", "shipping_street1", "shipping_street2", "shipping_city", "shipping_state","shipping_zipcode", "mailing_street1", "mailing_street2", "mailing_city", "mailing_state","mailing_zipcode", "taxRate","taxTotal", "taxAmount", "taxable", "total", "totalTaxAmount"]

  connect() {
	this.updateAddress()
    this.toggleAddress()
	  //console.log("QuoteHeaderConnect1", this.element)
	  //console.log("QuoteHeaderConnect2", this.sourceTarget)
	  //console.log("QuoteHeaderConnect3", this.sourceTargets)
	  //console.log("QuoteHeaderConnect4", this.element[this.identifier])
	  //document.querySelector('#linetotal').total.total()
    this.setTotalTaxAmount()
  }

  //subtot() {
//	  console.log("subtot", this.sourceTargets)
  //}

  updateAddress(){
	const selection = this.address_sourceTarget.value
    const input = this.mailing_street1Target
	const mailingFields = [this.mailing_street1Target, this.mailing_street2Target, this.mailing_zipcodeTarget,
	this.mailing_cityTarget, this.mailing_stateTarget]
	const shippingFields = [this.shipping_street1Target, this.shipping_street2Target, this.shipping_zipcodeTarget,
	this.shipping_cityTarget, this.shipping_stateTarget]

    if (selection === 'Customer Address') {
      this.mailing_street1Target.value = this.customerValue.mailing_street1
	  this.mailing_street2Target.value = this.customerValue.mailing_street2
	  this.mailing_zipcodeTarget.value = this.customerValue.mailing_zipcode
	  this.mailing_cityTarget.value = this.customerValue.mailing_city
	  this.mailing_stateTarget.value = this.customerValue.mailing_state
      mailingFields.forEach(f => f.readOnly = true)
    } else if (selection === 'Company Address') {
      this.mailing_street1Target.value = this.companyValue.customer_street1
	  this.mailing_street2Target.value = this.companyValue.customer_street2
	  this.mailing_zipcodeTarget.value = this.companyValue.customer_zipcode
	  this.mailing_cityTarget.value = this.companyValue.customer_city
	  this.mailing_stateTarget.value = this.companyValue.customer_state
      mailingFields.forEach(f => f.readOnly = true)
    }

	const isSame = mailingFields.every((val, index) => val.value === shippingFields[index].value)
	this.ship_same_billTarget.checked = isSame
	
  }

  toggleAddress() {

	  //console.log("toggleAddress top", this.ship_same_billTarget.value);

    if (this.ship_same_billTarget.checked) {
	    //console.log("value true", this.ship_same_billTarget.value);
        this.shipping_street1Target.value = this.mailing_street1Target.value;
        this.shipping_street2Target.value = this.mailing_street2Target.value;
        this.shipping_cityTarget.value = this.mailing_cityTarget.value;
        this.shipping_stateTarget.value = this.mailing_stateTarget.value;
        this.shipping_zipcodeTarget.value = this.mailing_zipcodeTarget.value;
    }
//    else {
	    //console.log("value false", this.ship_same_billTarget.value);
        //this.shipping_street1Target.value = "";
        //this.shipping_street2Target.value = "";
        //this.shipping_cityTarget.value = "";
        //this.shipping_stateTarget.value = "";
        //this.shipping_zipcodeTarget.value = "";
    //}

  }

	calcTaxAmountRemove() {
		var taxable = this.taxAmountTargets

    		var taxableLen = taxable.length
          	console.log("taxableLen", taxableLen);

    		var i=0;
    		var taxableAmount=0;
    		for (i=0; i < taxableLen; i++) {
          	     console.log("taxable", taxable[i].value);
		     if (taxable[i].value) {
          	      taxableAmount = taxableAmount + (parseFloat(taxable[i].value.replace(/,/g,'')));
		     }
          	     console.log("cost", taxableAmount);
     		}

                this.totalTaxAmountTarget.value = taxableAmount.toFixed(2);

                this.taxTotalTarget.value = (taxableAmount * (this.taxRateTarget.value / 100)).toFixed(2);
	}

	setTotalTaxAmount() {
       			console.log("this", this.taxableTarget.checked)
		// took below out and tax looks like it is working

    		//if (this.taxableTarget.checked) {
			//var tempTotal = (parseFloat(this.totalTarget.value.replace(/,/g, '')))
       			//this.taxAmountTarget.value = this.tempTotal
       			//this.taxAmountTarget.value = this.totalTarget.value
       			//console.log("tempTotal", tempTotal)
       			//console.log("taxtop", this.taxAmountTarget.value)
       			//console.log("checkedtop", this.taxableTarget)
       			//console.log("totaltarget", this.totalTarget)
    		//} else {
       		//	this.taxAmountTarget.value = 0
       		//	console.log("inelsesetTotalTax", this.totalTarget.value)
	   	//}


		var taxable = this.taxAmountTargets
    		var total = this.totalTargets

          	console.log("taxable", taxable);
          	console.log("total", total);

    		var taxableLen = taxable.length
          	console.log("taxableLen", taxableLen);

    		var i=0;
    		var taxableAmount=0;
    		for (i=0; i < taxableLen; i++) {
          	     console.log("taxable", taxable[i].value);
		     if (taxable[i].value) {
          	      taxableAmount = taxableAmount + (parseFloat(taxable[i].value.replace(/,/g,'')));
		     }
          	     console.log("cost", taxableAmount);
     		}

                this.totalTaxAmountTarget.value = taxableAmount.toFixed(2);

                this.taxTotalTarget.value = (taxableAmount * (this.taxRateTarget.value / 100)).toFixed(2);

          	console.log("finalcost", taxableAmount);
          	console.log("taxrateTarget", this.taxRateTarget);

		//this.tax_calculate(taxableAmount);
		

    		//console.log(this.application.getControllerForElementAndIdentifier(this.element, "total"));

	}

	tax_calculate() {
          	console.log("taxRate", this.taxRateTarget.value);
    		if (this.taxRateTarget.value > 0) {
                this.taxTotalTarget.value = ((parseFloat(this.totalTaxAmountTarget.value.replace(/,/g,''))) * (this.taxRateTarget.value / 100)).toFixed(2);
		}
	}


	format_number(field) {
	//console.log(field.toLocaleString());
	//console.log(parseFloat(field).toLocaleString());
	//console.log(typeof field);
	
	var fieldType = (typeof field)

	var DecimalSeparator = Number("1.2").toLocaleString().substr(1,1);

	var AmountWithCommas = field.toLocaleString();


	var arParts = String(AmountWithCommas).split(DecimalSeparator);
	var intPart = arParts[0];
	var decPart = (arParts.length > 1 ? arParts[1] : '');
	decPart = (decPart + '00').substr(0,2);

      return  (intPart + DecimalSeparator + decPart);
  }

}
