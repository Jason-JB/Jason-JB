/* add loop and other code here ... in this simple exercise we are not
   going to concern ourselves with minimizing globals, etc */
const tax_rate = 0.10;
const shipping_threshold = 1000;

/* running total for subtotals */
var subtotal = 0;

for (var i=0; i<titles.length; i++) {
    let total = calculateTotal(quantities[i],prices[i]);
    subtotal += total;
    outputCartRow(filenames[i],titles[i],quantities[i],prices[i],total);
}

var tax = calculateTax(subtotal,tax_rate);
var shipping = calculateShipping(subtotal,shipping_threshold);
var grand = calculateGrandTotal(subtotal,tax,shipping);