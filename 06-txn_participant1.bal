import ballerina/io;
import ballerina/log;
import ballerina/http;

endpoint http:Listener participantEP {
    host:"localhost",
    port:8889
};

type StockQuoteUpdateRequest record {
    string symbol;
    float price;
};

@http:ServiceConfig {
    basePath:"/stockquote2"
}
service<http:Service> StockquoteService2 bind participantEP {

    @http:ResourceConfig {
        path:"/update2",
        body: "stockQuoteUpdate"
    }
    updateStockQuote2 (endpoint conn, http:Request req, StockQuoteUpdateRequest stockQuoteUpdate) {
        endpoint http:Client participant2EP {
            url:"http://localhost:8890/p2"
        };
        log:printInfo("Received update stockquote request2");
        http:Response res = new;
        transaction {
            string msg = io:sprintf("Update stock quote request received. symbol:%j, price:%j",
                                    untaint stockQuoteUpdate.symbol, untaint stockQuoteUpdate.price);
            log:printInfo(msg);

            string pathSeqment = io:sprintf("/update/%j/%j", untaint stockQuoteUpdate.symbol, untaint stockQuoteUpdate.price);
            var result = participant2EP->get(pathSeqment);
            json jsonRes;
            match result {
                http:Response => {
                    res.statusCode = 200;
                    jsonRes = {"message":"updated stock"};
                }
                error err => {
                    res.statusCode = 500;
                    jsonRes = {"message":"update failed"};
                }
            }
            res.setJsonPayload(jsonRes);
            if (res.statusCode == 500) {
                io:println("###### Call to participant2 unsuccessful Aborting");
                 abort;
            }
        }
        var result2 = conn -> respond(res);
        match result2 {
            error err => log:printError("Could not send response back to initiator", err = err);
            () => log:printInfo("");
        }
    }
}
