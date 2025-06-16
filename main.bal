import ballerina/ftp;
import ballerina/io;
import ballerina/log;
import ballerina/sql;

listener ftp:Listener retailerService = new (protocol = ftp:SFTP, host = ftpHost, port = ftpPort, auth = {
    credentials: {
        username: ftpUsername,
        password: ftpPassword
    }
}, path = ftpInvoiceLocation, fileNamePattern = ftpFilePattern, pollingInterval = ftpPollingInterval);

service ftp:Service on retailerService {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {
            log:printInfo("file received");
            foreach ftp:FileInfo addedFile in event.addedFiles {
                log:printInfo(string `received ${addedFile.name}`);
                stream<byte[] & readonly, io:Error?> fileStream = check ftpClient->get(addedFile.pathDecoded);

                string content = "";
                check fileStream.forEach(function(byte[] & readonly data) {
                    string|error chunk = string:fromBytes(data);
                    if chunk is string {
                        content += chunk;
                    }
                });
                Invoice invoice = check fromEdiString(content);
                InvoiceDetails invoiceDetails = transform(invoice);
                do {
                    sql:ExecutionResult sqlExecutionresult = check mysqlClient->execute(`INSERT INTO Invoices (invoiceId, amount, paymentStatus)
VALUES (${invoiceDetails.invoiceId}, ${invoiceDetails.amount}, ${invoiceDetails.paymentStatus})`);
                    if sqlExecutionresult.affectedRowCount == 1 {
                        log:printInfo("Successfully inserted the details for invoice" + invoiceDetails.invoiceId.toString());
                    } else {
                        log:printError("Error while inserting invoice details for invoice " + invoiceDetails.invoiceId.toString());
                    }
                } on fail error err {
                    log:printError("Error while inserting invoice details for invoice " + invoiceDetails.invoiceId.toString() + ": " + err.message());
                }

                log:printInfo(string `invoiceid ${invoiceDetails.invoiceId ?: ""} added to database`);
                log:printInfo(string `invoice content: ${content}`);
            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
