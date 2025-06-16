
type InvoiceDetails record {|
    string|() invoiceId;
    float|() amount;
    boolean paymentStatus = false;
|};
