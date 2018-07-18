import ballerina/http;
import ballerina/log;
import ballerina/runtime;

endpoint http:Client backendClientEP {
    url: "http://localhost:8080",
    retryConfig: {
        interval: 1000, // Retry interval in milliseconds
        count: 3, // Number of retry attempts before giving up
        backOffFactor: 2 // Multiplier of the retry interval to exponentailly increase retry interval
    },    
    timeoutMillis: 1000
};

@http:ServiceConfig {
    basePath: "/retry"
}
service<http:Service> retryDemoService bind { port: 9090 } {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    invokeEndpoint(endpoint caller, http:Request request) {
        var backendResponse = backendClientEP->get("/hello", message = untaint request);
        match backendResponse {            
            http:Response response => {
                caller->respond(response) but {
                    error e => log:printError("Error sending response", err = e)
                };            
            }
            error responseError => {
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
public int counter = 0;

@http:ServiceConfig { basePath: "/hello" }
service<http:Service> mockHelloService bind { port: 8080 } {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    sayHello(endpoint caller, http:Request req) {
        counter = counter + 1;
        if (counter % 4 != 0) {
            log:printInfo("Simulating a delay...");

            // Simulate a delay
            runtime:sleep(5000);       

            http:Response res = new;
            res.setPayload("Hello World!!!");
            caller->respond(res) but {
                error e => log:printError("Error sending response from mock service", err = e)
            };
        } else {
            log:printInfo("No delay.");
            http:Response res = new;
            res.setPayload("Hello World!!!");
            caller->respond(res) but {
                error e => log:printError("Error sending response from mock service", err = e) };
        }
    }
}
