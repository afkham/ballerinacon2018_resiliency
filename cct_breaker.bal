import ballerina/http;
import ballerina/log;

endpoint http:Client backendClientEP {
    url: "http://localhost:8080",
    circuitBreaker: {

        // Failure calculation window.
        rollingWindow: {
            // Time period for which the failure threshold is calculated.
            timeWindowMillis: 10000,

            // The granularity at which the time window slides.
            bucketSizeMillis: 2000,
            requestVolumeThreshold: 0
        },

        // The threshold for request failures.
        // When this threshold exceeds, the circuit trips.
        // This is the ratio between failures and total requests.
        failureThreshold: 0.4,

        // The time period(in milliseconds) to wait before
        // attempting to make another request to the backend service.
        resetTimeMillis: 20000,
        statusCodes: [400, 404, 500]
    },    
    timeoutMillis: 2000
};
@http:ServiceConfig {
    basePath: "/cb"
}
service<http:Service> circuitbreaker bind { port: 9090 } {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    invokeEndpoint(endpoint caller, http:Request request) {
        var backendRes = backendClientEP->forward("/hello", request);
        match backendRes {            
            http:Response res => {
                caller->respond(res) but {
                    error e => log:printError("Error sending response", err = e)
                };
            }
            error responseError => {
                http:Response response = new;
                http:CircuitBreakerClient cbClient = 
                                   check <http:CircuitBreakerClient>backendClientEP.getCallerActions(); 
                http:CircuitState currentState = cbClient.getCurrentState();
                if (currentState == http:CB_OPEN_STATE || currentState == http:CB_HALF_OPEN_STATE) {
                    response.setPayload("Circuit open. This is a cached response");
                } else {
                    response.setPayload("Failed");
                    response.statusCode = 500;
                }

                caller->respond(response) but {
                    error e => log:printError("Error sending response", err = e)
                };
            }
        }
    }
}
