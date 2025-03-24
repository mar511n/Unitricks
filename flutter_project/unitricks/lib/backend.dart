import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const baseWebsite = "https://marvin.henke-email.de";
const databaseWebsite = '$baseWebsite/databaseAccess.php';

final storage = FlutterSecureStorage();
String username = "";
String passwd = "";

bool credentialsValidated = false;

Future<String> tryLogIn() async {
  String retVal = "";
  if(username != "" && passwd != "") {
    final resp = await validateCredentials();
    log('${resp.body} ${resp.statusCode}');
    credentialsValidated = resp.body == "Access granted";
    if (!credentialsValidated) {
      retVal = 'error: status=${resp.statusCode}, body=${resp.body}';
    }
  }else{
    credentialsValidated = false;
    retVal = "error: username or password was not set";
  }
  if (credentialsValidated) {
    saveCredentials();
  }
  return retVal;
}

void saveCredentials() async {
  await storage.write(key: 'username', value: username);
  await storage.write(key: 'password', value: passwd);
}

/// response body is either "Access granted" or "Access denied"
Future<http.Response> callDbFunction(String fname, List<dynamic> params) async {
  final body = <String, dynamic>{};
  for (var i = 0; i < params.length; i++) {
    body['$i'] = params[i];
  }
  return makeHttpRequest("PUT", databaseWebsite, headers: basicAuthHeader(username,passwd), body: body, queryParams: <String, String>{'fname':fname});
}

/// response body is either "Access granted" or "Access denied"
Future<http.Response> validateCredentials() async {
  return makeHttpRequest("GET", databaseWebsite, headers: basicAuthHeader(username,passwd));
}

Map<String, String> basicAuthHeader(String user, String passwd) {
  final credentials = '$user:$passwd';
  final encodedCredentials = base64Encode(utf8.encode(credentials));
  
  return {
    'Authorization': 'Basic $encodedCredentials',
    //'Content-Type' : 'application/json',
  };
}

Future<http.Response> makeHttpRequest(
  String method,
  String url, {
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  Map<String, String>? queryParams,
}) async {
  // Construct the full URL with query parameters
  final uri = Uri.parse(url).replace(queryParameters: queryParams);

  // Create the HTTP request
  final request = http.Request(method, uri);

  // Set headers if provided
  if (headers != null) {
    request.headers.addAll(headers);
  }

  // Set body based on Content-Type header
  if (body != null) {
    request.body = json.encode(body);
    /**
    final contentType = headers?['Content-Type'] ?? '';
    if (contentType.contains('application/json')) {
      // Encode as JSON if Content-Type is set to JSON
      request.body = json.encode(body);
    } else {
      // Default to form-urlencoded encoding
      final bodyFields = <String, String>{};
      body.forEach((key, value) {
        bodyFields[key] = value.toString();
      });
      request.bodyFields = bodyFields;
    }
    */
  }

  // Send the request and return the response
  final streamedResponse = await request.send();
  return await http.Response.fromStream(streamedResponse);
}