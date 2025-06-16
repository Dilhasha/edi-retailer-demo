
import ballerina/edi;

# Convert EDI string to Ballerina Invoice record.
# 
# + ediText - EDI string to be converted
# + return - Ballerina record or error
public isolated function fromEdiString(string ediText) returns Invoice|error {
    edi:EdiSchema ediSchema = check edi:getSchema(schemaJson);
    json dataJson = check edi:fromEdiString(ediText, ediSchema);
    return dataJson.cloneWithType();
}

# Convert Ballerina Invoice record to EDI string.
# 
# + data - Ballerina record to be converted
# + return - EDI string or error
public isolated function toEdiString(Invoice data) returns string|error {
    edi:EdiSchema ediSchema = check edi:getSchema(schemaJson);
    return edi:toEdiString(data, ediSchema);    
} 

# Get the EDI schema.
# 
# + return - EDI schema or error
public isolated function getSchema() returns edi:EdiSchema|error {
    return edi:getSchema(schemaJson);
}

# Convert EDI string to Ballerina Invoice record with schema.
# 
# + ediText - EDI string to be converted
# + schema - EDI schema
# + return - Ballerina record or error
public isolated function fromEdiStringWithSchema(string ediText, edi:EdiSchema schema) returns Invoice|error {
    json dataJson = check edi:fromEdiString(ediText, schema);
    return dataJson.cloneWithType();
}

# Convert Ballerina Invoice record to EDI string with schema.
# 
# + data - Ballerina record to be converted
# + ediSchema - EDI schema
# + return - EDI string or error
public isolated function toEdiStringWithSchema(Invoice data, edi:EdiSchema ediSchema) returns string|error {
    return edi:toEdiString(data, ediSchema);    
}

public type Header_Type record {|
   string code = "HDR";
   string invoiceId;
   string orderId;
   string organization?;
   string date;
   float amount;
|};

public type Items_Type record {|
   string code = "ITM";
   string item;
   int quantity;
   float unitPrice;
   float total;
|};

public type Invoice record {|
   Header_Type? header?;
   Items_Type[] items = [];
|};



final readonly & json schemaJson = {"name":"Invoice", "delimiters":{"segment":"~", "field":"*", "component":":", "repetition":"^"}, "segments":[{"code":"HDR", "tag":"header", "fields":[{"tag":"code", "required":true}, {"tag":"invoiceId", "required":true}, {"tag":"orderId", "required":true}, {"tag":"organization"}, {"tag":"date", "required":true}, {"tag":"amount", "dataType":"float", "required":true}]}, {"code":"ITM", "tag":"items", "maxOccurances":-1, "fields":[{"tag":"code", "required":true}, {"tag":"item", "required":true}, {"tag":"quantity", "dataType":"int", "required":true}, {"tag":"unitPrice", "dataType":"float", "required":true}, {"tag":"total", "dataType":"float", "required":true}]}]};
    