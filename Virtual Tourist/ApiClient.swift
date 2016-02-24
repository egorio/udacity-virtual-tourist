//
//  ApiClient.swift
//  Virtual Tourist
//
//  Created by Egorio on 2/22/16.
//  Copyright © 2016 Egorio. All rights reserved.
//

import Foundation

/*
 * Main class for specific API client implementation
 */
class ApiClient {

    // Session
    var session: NSURLSession { return NSURLSession.sharedSession() }

    // Common headers for each request
    var headers: [String: String] = [String: String]()

    // Available HTTP methods for requests
    enum Method: String {
        case Get
        case Post
        case Put
        case Delete
    }

    /*
     * Create encoded query string from params dictionary
     */
    class func encodeParameters(params: [String: AnyObject]) -> String {
        let components = NSURLComponents()
        components.queryItems = params.map { NSURLQueryItem(name: $0, value: String($1)) }

        return components.percentEncodedQuery ?? ""
    }

    /*
     * Prepare NSMutableURLRequest object to call API
     */
    func prepareRequest(url: String, method: Method = .Get, params: [String: AnyObject] = [String: AnyObject](), body: AnyObject? = nil) -> NSMutableURLRequest {
        let url = url + "?" + ApiClient.encodeParameters(params)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = method.rawValue.uppercaseString

        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        if body != nil {
            do {
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(body!, options: [])
            }
        }

        return request
    }

    /*
     * Send request using session task and try parse result as JSON object
     */
    func processResuest(request: NSMutableURLRequest, handler: (result: AnyObject?, error: String?) -> Void) {
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // Was there an error?
            guard error == nil else {
                print("Error in response")
                handler(result: nil, error: "Connection error")
                return
            }

            // Did we get a successful 2XX response?
            guard let status = (response as? NSHTTPURLResponse)?.statusCode where status != 403 else {
                print("Wrong response status code (403)")
                handler(result: nil, error: "Username or password is incorrect")
                return
            }

            // Was there any data returned?
            guard let data = data else {
                print("Wrong response data")
                handler(result: nil, error: "Connection error")
                return
            }

            let json: AnyObject!
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("JSON converting error")
                handler(result: nil, error: "Connection error")
                return
            }

            handler(result: json, error: nil)
        }

        task.resume()
    }
}