  %dw 2.6

/*
 * Purpose: A generic dwl module with generic functions to extract information from commonly available contextual information across apps
 * such token, uriParams, queryParams, headers etc and print the extracted information in a consistent manner in logger components.
 */

import getAuthTokenAsObject, printJWTTokenAsObject from functions::authFunc

fun logVars(logData) = {variables: logData}

fun logPayload(logData) = {payload: logData}

/*
 * Generic function to log attributes of a HTTP request
 * Intended for usage in logger components of initial flows with source as HTTP listener to below aspects
 *  - uriParams, queryParams, headers
 */
fun logAttributes(obj: Object | Null): Object | Null = {
	(attributes: {
		(uriParams: obj.uriParams) if !isEmpty(obj.uriParams),
		(queryParams: obj.queryParams) if !isEmpty(obj.queryParams),
		(httpMethod: obj.method) if !isEmpty(obj.method),
		(rawRequestUri: obj.rawRequestUri) if !isEmpty(obj.rawRequestUri),
		(token: getAuthTokenAsObject(obj.headers.authorization) - 'signature') if (!isEmpty(obj.headers.authorization))
	}) if(!isEmpty(obj))
}

// Generic function to log the token object without signature
fun logAccessToken(token) = {(token: printJWTTokenAsObject(token) - 'signature') if(!isEmpty(token))}

// Generic function to log the decoded token object, if not empty
fun logDecodedToken(token) = {(token: token) if(!isEmpty(token))}

// Generic function to output the array of failedValidations if not empty
fun logFailedValidations(failedValidations) = {(failedValidations: failedValidations) if(!isEmpty(failedValidations))} 

/*
 * Generic function to output the input query if not empty, masking any sensitive data
 * Intended for usage in logger components positioned prior to query component of Salesforce connector
 */
fun logUserInfo(userInfo): Object | Null = {(userInfoResponseKeys: keysOf(userInfo)) if(!isEmpty(userInfo))}

fun maskSensitiveData(data: String): String | Null = 
    data 
        replace /PHN__c = '.*'/ with "PHN__c = '****'"
        replace /MSP_Number__pc = '.*'/ with "MSP_Number__pc = '****'"

/*
 * Generic function to output the input query if not empty, masking any sensitive data
 * Intended for usage in logger components positioned prior to query component of Salesforce connector
 */
fun logSalesforceQuery(query: String | Null): Object | Null = {(query: maskSensitiveData(query)) if(!isEmpty(query))}
fun logSalesforceQuery(query: Object | Null): Object | Null = {(query: query) if(!isEmpty(query))}

/*
 * Generic function to output the input data if not empty
 * Intended for usage in logger components positioned right after a query/create/update component of Salesforce connector 
 */
fun logSalesforceResponse(data): Object | Null = {(data: data) if(!isEmpty(data))}

/*
 * Generic function to construct a custom error object to print in logger entry
 * Takes in oob error object as input 
 */
fun logError(e: Object | Null): Object | Null = 
	if (isEmpty(e)) null
	else {
		error: {
			description: e.description default null,
			detailedDescription: e.detailedDescription default null,
			errorType: '$(e.errorType.namespace):$(e.errorType.identifier)' default null,
		//	cause: e.cause default null,
			errorMessage: e.errorMessage.payload
		}
	}

// Generic function to output the input message string
fun printLogEntry(message: String | Null): String | Null = {timestamp: now(), message: message}

fun printLogEntryV2(correlationId, message: String | Null): String | Null = {timestamp: now(), correlationId: correlationId, message: message}

/*
 * Generic function to construct a JSON object that gets used as value for message attribute of OOB logger component
 * 
 * Expects below three inputs
 * 1. message - A concise string to convey the point/state of processing
 * 2. logData - Any data which gets processed by logFunc for extraction of required information
 * 3. logFunc - A lambda function which takes in logData, extracts necessary information and returns an object to get printed in log entry
 * 
 * if logData is empty, function calls printLogEntry(message) to simply print the message out
 * 
 * Ex: printLogEntry("Hello", "{"name": "World"}", (l) -> {payload: upper(l)}) would output {"message": "Hello", payload: "WORLD"}
 */
fun printLogEntry(message: String | Null, logData, logFunc: (Any) -> Object) : Object = if(isEmpty(logData)) printLogEntry(message) else {
    timestamp: now(),
    message: message,
    (logFunc(logData))
}

fun printLogEntryV2(correlationId, message: String | Null, logData, logFunc: (Any) -> Object) : Object = if(isEmpty(logData)) printLogEntry(message) else {
    timestamp: now(),
    correlationId: correlationId,
    message: message,
    (logFunc(logData))
}