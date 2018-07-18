import ballerina/http;
import ballerina/log;
import ballerina/runtime;

@http:ServiceConfig {
    basePath: "/echo"
}
service<http:Service> echo bind {port: 8080} {
    @http:ResourceConfig {
        methods: ["POST", "PUT", "GET"],
        path: "/"
    }
    echoResource(endpoint caller, http:Request req) {
        http:Response outResponse = new;
        runtime:sleep(30000);        
        outResponse.setPayload("echo Resource is invoked");
        caller->respond(outResponse) but {
                    error e => log:printError(
                        "Error sending response from echo service", err = e)
                    };
    }
}
