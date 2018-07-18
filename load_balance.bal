import ballerina/http;
import ballerina/log;
endpoint http:Listener backendEP {
    port: 8080
};
endpoint http:LoadBalanceClient lbBackendEP {
    targets: [
        { url: "http://localhost:8080/mock1" },
        { url: "http://localhost:8080/mock2" },
        { url: "http://localhost:8080/mock3" }
    ],
    algorithm: http:ROUND_ROBIN,
    timeoutMillis: 5000
};

@http:ServiceConfig {
    basePath: "/lb"
}
service<http:Service> loadBalancerDemoService bind { port: 9090 } {
    @http:ResourceConfig {
        path: "/"
    }
    invokeEndpoint(endpoint caller, http:Request req) {
        http:Request outRequest = new;
        json requestPayload = { "name": "Ballerina" };
        outRequest.setPayload(requestPayload);
        var response = lbBackendEP->post("/", outRequest);
        match response {
            http:Response resp => {
                caller->respond(resp) but {
                    error e => log:printError("Error sending response", err = e)
                };
            }
            error responseError => {
                http:Response outResponse = new;
                outResponse.statusCode = 500;
                outResponse.setPayload(responseError.message);
                caller->respond(outResponse) but {
                    error e => log:printError("Error sending response", err = e)
                };
            }
        }
    }
}

@http:ServiceConfig { basePath: "/mock1" }
service mock1 bind backendEP {
    @http:ResourceConfig {
        path: "/"
    }
    mock1Resource(endpoint caller, http:Request req) {
        http:Response outResponse = new;
        outResponse.setPayload("Response from mock1 service.");
        caller->respond(outResponse) but {
                        error e => log:printError(
                           "Error sending response from mock service", err = e)
                        };
    }
}

@http:ServiceConfig { basePath: "/mock2" }
service mock2 bind backendEP {
    @http:ResourceConfig {
        path: "/"
    }
    mock2Resource(endpoint caller, http:Request req) {
        http:Response outResponse = new;
        outResponse.setPayload("Response from mock2 service.");
        caller->respond(outResponse) but {
                        error e => log:printError(
                           "Error sending response from mock service", err = e)
                        };
    }
}

@http:ServiceConfig { basePath: "/mock3" }
service mock3 bind backendEP {
    @http:ResourceConfig {
        path: "/"
    }
    mock3Resource(endpoint caller, http:Request req) {
        http:Response outResponse = new;
        outResponse.setPayload("Response from mock3 service.");
        caller->respond(outResponse) but {
                        error e => log:printError(
                           "Error sending response from mock service", err = e)
                        };
    }
}
