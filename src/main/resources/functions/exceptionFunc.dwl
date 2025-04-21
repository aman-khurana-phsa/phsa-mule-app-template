%dw 2.0

/**
 * Maps a given error type to a corresponding HTTP status code and message.
 * @param errorType A string value representing the error type (e.g., "exceptions:INVALID_REQUEST")
 * @return An object with "code" and "message" corresponding to the HTTP error code and description.
 */
fun mapHttpStatus(errorType: String): Object =
    errorType match {
        // Map specific error types to their HTTP codes and messages
        case "exceptions:INVALID_REQUEST" -> { code: 400, message: "Bad Request" }
        case "exceptions:UNAUTHORIZED"    -> { code: 401, message: "Unauthorized" }
        case "exceptions:FORBIDDEN"       -> { code: 403, message: "Forbidden" }
        case "exceptions:NOT_FOUND"       -> { code: 404, message: "Resource Not Found" }
        case "exceptions:CONFLICT"        -> { code: 409, message: "Conflict" }
        case "exceptions:TIMEOUT"         -> { code: 408, message: "Request Timeout" }
        
        // Default case for all other or unknown errors
        else -> { code: 500, message: "Internal Server Error" }
    }
