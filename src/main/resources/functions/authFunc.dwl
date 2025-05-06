%dw 2.6

/*
 * Purpose: A generic dwl module with functions to process information pertaining to authorization
 * such token, Authorization header, token validations, token decode etc. It is intended to be used along with dhsAuth.xml file.
 */

import * from dw::core::Binaries
import every from dw::core::Arrays
import substringBefore, substringAfter, substringAfterLast from dw::core::Strings

// Extracts token provided from the "Authorization" header (authHeader)
fun getAuthorizationToken(authHeader: String | Null): String | Null = substringAfter(authHeader, " ")

// Extracts header of a JWT token
fun getJWTTokenHeader(token: String | Null): String | Null = substringBefore(token, '.')

// Extracts body of a JWT token
fun getJWTTokenBody(token: String | Null): String | Null = substringBefore(substringAfter(token, '.'), '.')

// Extracts signature of a JWT token
fun getJWTTokenSignature(token: String | Null): String | Null = substringAfterLast(token, '.')

// Outputs a JWT Token string as an object with header, body, signature of the token as separate fields
fun printJWTTokenAsObject(token: String | Null): Object | Null = if(isEmpty(token)) null else {
	header: getJWTTokenHeader(token),
	body: getJWTTokenBody(token),
	signature: getJWTTokenSignature(token)
}

/*
 * Extracts the JWT Token from "Authorization" header (authHeader)
 * Outputs it as an object with header, body, signature of the token as separate fields
 */
fun getAuthTokenAsObject(authHeader: String | Null): Object | Null = if(isEmpty(authHeader)) null else do {
	var authToken = getAuthorizationToken(authHeader)
	---
	if(isEmpty(authToken)) null else printJWTTokenAsObject(authToken)
}

// Separates the header, body of a JWT token, base64 decodes them and returns object containing the decoded header, body
fun decodeJWTToken(token: String | Null): Object | Null = if(isEmpty(token)) null else do {
	var accessTokenObject = printJWTTokenAsObject(token)
	fun readToken(t) = read(fromBase64(t),"application/json")
	---
	{
	    header:readToken(accessTokenObject.header),
	    body:readToken(accessTokenObject.body)
	}
}

// Constructs an object containing "Authorization" field for usage in HTTP request as a header
// authType (ie Bearer, Basic, SessionId))
fun createAuthorizationHeader(token, authType="Bearer") = {"Authorization": authType ++ ' ' ++ token}

fun printException(exceptionCode: String): Object | Null = {
	exceptionCode: exceptionCode,
	exceptionMessage: exceptionCode match {
		case 'auth-err-001' -> 'Token Authorization failed'
		case 'auth-err-002' -> 'Processing error. Unable to complete the request. Please Contact your system administrator.'
		else -> null
	}
}

/*
 * Constructs an array to represent failed decode of token
 * Used as part of error handling in dhsAuth.xml's flow auth:decode-access-token
 */
fun printFailedAuthDecode(): Array = do {
	var category = 'Token-Decode'
	---
	[
		{
			name: 'auth-fail',
			isValid: false,	
			(printException('auth-err-002'))
		}
	] map ($ ++ {category: category})
	
}

/*
 * Constructs an array to represent failed signature validation of token.
 * Used as part of error handling in dhsAuth.xml's flow auth:validate-token-java
 */
fun printFailedAuthSignature(errorDescription: String): Array = do {
	var category = 'Token-Signature'
	---
	[
		{
			name: 'auth-fail',
			isValid: false,	
			(printException('auth-err-001'))
		}
	] map ($ ++ {category: category})
	
}

/*
 * Validates below aspects of the token and outputs an array containing each validation name, its result along with exceptionCode and message
 * 1. Token's algorithm, specified in the header, must be valid (RS256)
 * 2. Issuer must be valid, URL of the auth server corresponding to the environment
 * 3. Token must not have expired
 */
fun printTokenGeneralValidationResults(accessTokenDecrypt: Object, startTime: Number): Array = do {
	var category = 'Token-General'
	
	var validAlgorithm = Mule::p('lra.dhsAuth.token.algorithm')
	var validIssuer = Mule::p('lra.dhsAuth.issuerUrl')
	---
	[
		{
			name: 'Valid-Algorithm',
			isValid: accessTokenDecrypt.header.alg ~= validAlgorithm,
			(printException('auth-err-001'))
		},
		{
			name: 'Valid-Issuer',
			isValid: accessTokenDecrypt.body.iss == validIssuer,
			(printException('auth-err-001'))
		},
		{
			name: 'Token-Has-Not-Expired',
			isValid: startTime != 0 and (ceil(startTime/1000) <= accessTokenDecrypt.body.exp),
			(printException('auth-err-001'))
		}
	] map ($ ++ {category: category})
}

/*
 * Tokens in decoded token object containing header, body fields, performs general validations and outputs an array containing all failed validations
 * Usage: Used in dhsAuth.xml's auth:validate-token flow, Validations performed are generic enough to re-use in other apps
 */
fun printFailedTokenGeneralValidations(accessTokenDecrypt: Object, startTime: Number): Array = (printTokenGeneralValidationResults(accessTokenDecrypt, startTime) default []) filter $.isValid ~= 'false'

