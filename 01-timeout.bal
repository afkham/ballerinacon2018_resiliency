import ballerina/http;
import ballerina/log;
import ballerina/runtime;

endpoint http:Client backendClientEP {
    url: "http://localhost:8080",
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
        var backendResponse = backendClientEP->get("/hello", message = untaint request);
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

@http:ServiceConfig { basePath: "/hello" }
service<http:Service> mockHelloService bind { port: 8080 } {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    sayHello(endpoint caller, http:Request req) {

        // Simulate a delay
        runtime:sleep(5000);       

        http:Response res = new;
        res.setPayload("Hello World!!!");
        caller->respond(res) but {
            error e => log:printError("Error sending response from mock service", err = e)
        };
    }
}
