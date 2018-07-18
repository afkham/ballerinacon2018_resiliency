import ballerina/http;
import ballerina/log;
import ballerina/runtime;

endpoint http:Client backendClientEP {
    url: "http://localhost:8081",
    timeoutMillis: 2000
};

@http:ServiceConfig {
    basePath: "/timeout"
}
service<http:Service> TimeoutDemoService bind { port: 9090 } {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    invokeEndpoint(endpoint caller, http:Request request) {
        var backendResponse = backendClientEP->get("/hello", message = request);
        match backendResponse {            
            http:Response response => {
                caller->respond(response) but {
                    error e => log:printError("Error sending response", err = e)
                };            
            }
            error responseError => {
                log:printError("Error!!!");
                http:Response errorResponse = new;
                errorResponse.statusCode = 500;
                errorResponse.setPayload(responseError.message);                
                caller->respond(errorResponse) but {
                    error e => log:printError("Error sending response", err = e)
                };
            }
        }
    }
}
