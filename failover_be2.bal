import ballerina/http;
import ballerina/log;
import ballerina/runtime;

@http:ServiceConfig {
    basePath: "/mock"
}
service<http:Service> mock bind {port: 8081} {
    @http:ResourceConfig {
        methods: ["POST", "PUT", "GET"],
        path: "/"
    }
    mockResource(endpoint caller, http:Request req) {
        http:Response outResponse = new;
        outResponse.setPayload("Mock service invoked.");
        caller->respond(outResponse) but {
                    error e => log:printError(
                        "Error sending response from mock service", err = e)
                    };
    }
}
