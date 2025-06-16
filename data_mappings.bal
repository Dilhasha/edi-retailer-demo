function transform(Invoice invoice) returns InvoiceDetails => {
    amount: invoice?.header?.amount,
    invoiceId: invoice?.header?.invoiceId
};