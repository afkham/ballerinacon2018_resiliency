import ballerina/http;
import ballerina/log;
import ballerina/runtime;
endpoint http:Listener backendEP {
    port: 8080
};
endpoint http:FailoverClient foBackendEP {
    timeoutMillis: 5000,
    failoverCodes: [501, 502, 503],
    targets: [
        { url: "http://localhost:3000/mock1" },
        { url: "http://localhost:8080/echo" },
        { url: "http://localhost:8081/mock" }
    ]};
    
@http:ServiceConfig {
    basePath: "/fo"
}
service<http:Service> failoverDemoService bind { port: 9090 } {
    @http:ResourceConfig {
        methods: ["GET", "POST"],
        path: "/"
    }
    invokeEndpoint(endpoint caller, http:Request request) {
        var backendRes = foBackendEP->get("/", message = request);
        match backendRes {
            http:Response response => {
                caller->respond(response) but {
                    error e => log:printError("Error sending response", err = e)
                };
            }
            error responseError => {
                http:Response response = new;
                response.statusCode = 500;
                response.setPayload(responseError.message);
                caller->respond(response) but {
                    error e => log:printError("Error sending response", err = e)
                };
            }
        }
    }
}
