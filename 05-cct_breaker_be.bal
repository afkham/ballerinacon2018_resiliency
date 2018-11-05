import ballerina/http;
import ballerina/log;
import ballerina/runtime;

public int counter = 1;

@http:ServiceConfig { basePath: "/hello" }
service<http:Service> helloWorld bind { port: 8080 } {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    sayHello(endpoint caller, http:Request req) {
        if (counter % 5 == 0) {
            runtime:sleep(5000);  // Simulating a delay

            http:Response res = new;
            res.setPayload("Hello World!!! - 1");
            caller->respond(res) but {
                    error e => log:printError("Error sending response from mock service", err = e)
                    };
        } else if (counter % 5 == 3) {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload("Internal error occurred while processing the request.");
            caller->respond(res) but {
                        error e => log:printError("Error sending response from mock service", err = e)
                        };
        } else {
            http:Response res = new;
            res.setPayload("Hello World!!! - 2");
            caller->respond(res) but {
                        error e => log:printError(
                            "Error sending response from mock service", err = e)
                        };
        }
        counter = counter + 1;
    }
}
