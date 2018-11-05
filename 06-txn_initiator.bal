import ballerina/io;
import ballerina/log;
import ballerina/math;
import ballerina/http;
import ballerina/runtime;

endpoint http:Listener initiatorEP {
    port: 9090
};

string host = "127.0.0.1";
int port = 8889;

@http:ServiceConfig {
    basePath: "/transaction"
}
service InitiatorService bind initiatorEP {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    init(endpoint conn, http:Request req) {
        http:Response res = new;
        log:printInfo("Initiating transaction...");
 
        transaction {
            boolean successful = callBusinessService("/stockquote2/update2", "AMZN");
            if (!successful) {
                io:println("###### Call to participant unsuccessful Aborting");
                res.statusCode = 500;
                abort;
            }
        }
        var result = conn->respond(res);
        match result {
            error err => log:printError("Could not send response back to client", err = err);
            () => log:printInfo("");
        }
    }
}

function callBusinessService(string pathSegment, string symbol) returns boolean {
    endpoint BizClientEP ep {
        url: "http://" + host + ":" + port
    };
    float price = math:randomInRange(200, 250) + math:random();
    json bizReq = { symbol: symbol, price: price };
    var result = ep->updateStock(pathSegment, bizReq);
    match result {
        error => return false;
        json => return true;
    }
}

// BizClient connector

type BizClientConfig record {
    string url;
};

type BizClientEP object {

    http:Client httpClient;

    function init(BizClientConfig conf) {
        endpoint http:Client httpEP { url: conf.url, timeoutMillis: 1000 };
        self.httpClient = httpEP;
    }

    function getCallerActions() returns (BizClient) {
        BizClient client = new;
        client.clientEP = self;
        return client;
    }
};

type BizClient object {
        
    BizClientEP clientEP;

    function updateStock(string pathSegment, json bizReq) returns json|error {
        endpoint http:Client httpClient = self.clientEP.httpClient;
        http:Request req = new;
        req.setJsonPayload(bizReq);
        var result = httpClient->post(pathSegment, req);
        http:Response res = check result;
        log:printInfo("Got response from bizservice");
        json jsonRes = check res.getJsonPayload();
        return jsonRes;
    }
};
