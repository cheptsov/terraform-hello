package terraform.hello


import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestStreamHandler
import org.json.simple.JSONObject
import org.json.simple.parser.JSONParser
import org.json.simple.parser.ParseException
import java.io.*

class HelloLambdaHandler : RequestStreamHandler {
    internal var parser = JSONParser()


    @Throws(IOException::class)
    override fun handleRequest(inputStream: InputStream, outputStream: OutputStream, context: Context) {
        val logger = context.logger
        logger.log("Loading Java Lambda handler of ProxyWithStream")

        val reader = BufferedReader(InputStreamReader(inputStream))
        val responseJson = JSONObject()
        var name = "you"
        var city = "World"
        var time = "day"
        var day: String? = null
        val responseCode = "200"

        try {
            val event = parser.parse(reader) as JSONObject
            if (event["queryStringParameters"] != null) {
                val queryParameters = event["queryStringParameters"] as JSONObject
                if (queryParameters["time"] != null) {
                    time = queryParameters["time"] as String
                }
            }

            if (event["pathParameters"] != null) {
                val pathParameters = event["pathParameters"] as JSONObject
                if (pathParameters["proxy"] != null) {
                    city = pathParameters["proxy"] as String
                }
            }

            if (event["headers"] != null) {
                val headers = event["headers"] as JSONObject
                if (headers["day"] != null) {
                    day = headers["header"] as String
                }
            }

            if (event["body"] != null) {
                val body = parser.parse(event["body"] as String) as JSONObject
                if (body["callerName"] != null) {
                    name = body["callerName"] as String
                }
            }

            var greeting = "Good $time, $name of $city "
            if (day != null && day != "") {
                greeting += "appy " + day + ""
            }

            val responseBody = JSONObject()
            responseBody.put("message", greeting)

            val headerJson = JSONObject()
            headerJson.put("x-custom-response-header", "my custom response header value")

            responseJson.put("statusCode", responseCode)
            responseJson.put("headers", headerJson)
            responseJson.put("body", responseBody.toString())

        } catch (e: ParseException) {
            responseJson.put("statusCode", "400")
            responseJson.put("exception", e)
        }

        logger.log(responseJson.toJSONString())
        val writer = OutputStreamWriter(outputStream, "UTF-8")
        writer.write(responseJson.toJSONString())
        writer.close()
    }
}