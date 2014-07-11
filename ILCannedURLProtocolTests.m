//
//  ILCannedURLProtocolTests.m
//  TactilizeKit
//
//  Created by Arnaud Coomans on 03/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//TODO urls should use example.com (ietf domain for example purposes)

#import "ILCannedURLProtocolTests.h"

@implementation ILCannedURLProtocolTests

- (void)setUp {
	[super setUp];
	
	[NSURLProtocol registerClass:[ILCannedURLProtocol class]];

	[ILCannedURLProtocol setDelegate:nil];
	
	[ILCannedURLProtocol setCannedStatusCode:200];
	[ILCannedURLProtocol setCannedHeaders:nil];
	[ILCannedURLProtocol setCannedResponseData:nil];
	[ILCannedURLProtocol setCannedError:nil];
	
	[ILCannedURLProtocol setSupportedMethods:nil];
	[ILCannedURLProtocol setSupportedSchemes:nil];
	[ILCannedURLProtocol setSupportedBaseURL:nil];

    [ILCannedURLProtocol setResponseDataBlock:nil];
    [ILCannedURLProtocol setShouldInitWithRequestBlock:nil];
    [ILCannedURLProtocol setRedirectForClientBlock:nil];
    [ILCannedURLProtocol setStatusCodeBlock:nil];
    [ILCannedURLProtocol setHeadersBlock:nil];

	[ILCannedURLProtocol setResponseDelay:0];
}

- (void)testCanInitWithGETHTTPRequestWithSupportedSchemesAndMethodsNotSet {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
	request.HTTPMethod = @"GET";
	
	[ILCannedURLProtocol setSupportedMethods:nil];
	[ILCannedURLProtocol setSupportedSchemes:nil];
	
	STAssertTrue([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithGETHTTPRequestWithSupportedSchemesAndMethodsEmpty {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
	request.HTTPMethod = @"GET";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray array]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray array]];
	
	STAssertFalse([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithGETHTTPRequestWithSupportedHTTPSchemesAndGETMethods{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
	request.HTTPMethod = @"GET";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray arrayWithObject:@"GET"]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray arrayWithObject:@"http"]];
	
	STAssertTrue([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithPOSTHTTPSRequestWithSupportedHTTPSSchemesAndPOSTMethods{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://example.com"]];
	request.HTTPMethod = @"POST";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray arrayWithObject:@"POST"]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray arrayWithObject:@"https"]];
	
	STAssertTrue([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithPOSTHTTPRequestWithSupportedHTTPSchemesAndGETMethods{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
	request.HTTPMethod = @"POST";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray arrayWithObject:@"GET"]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray arrayWithObject:@"http"]];
	
	STAssertFalse([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithGETHTTPRequestWithSupportedHTTPSSchemesAndGETMethods{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
	request.HTTPMethod = @"GET";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray arrayWithObject:@"GET"]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray arrayWithObject:@"https"]];
	
	STAssertFalse([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithRequestWithSupportedBaseURL {
	
	NSMutableURLRequest *goodRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testCanInitWithRequestWithSupportedBaseURL"]];
	NSMutableURLRequest *badRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.org"]];
	
	[ILCannedURLProtocol setSupportedBaseURL:[NSURL URLWithString:@"http://example.com"]];
	
	STAssertTrue([ILCannedURLProtocol canInitWithRequest:goodRequest], @"ILCannedURLProtocol does not support a request with base url");
	STAssertFalse([ILCannedURLProtocol canInitWithRequest:badRequest], @"ILCannedURLProtocol does not support a request with base url");
}


- (void)testStartLoadingWithoutDelegate {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
	
	id requestObject = [NSDictionary dictionaryWithObjectsAndKeys:
				 [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil], @"array", 
				 @"hello", @"string",
				 nil];
				 
	NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestObject options:0 error:nil];
	[ILCannedURLProtocol setCannedResponseData:requestData];
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	
	STAssertNotNil(responseObject, @"no canned response from http request");
	STAssertTrue([responseObject isKindOfClass:[NSDictionary class]], @"canned response has wrong format (not dictionary)");	
}

- (void)testStartLoadingWithDelegate {

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testStartLoadingWithDelegate"]];
	
	[ILCannedURLProtocol setDelegate:self];
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	
	STAssertNotNil(responseObject, @"no canned response from http request");
	STAssertTrue([responseObject isKindOfClass:[NSDictionary class]], @"canned response has wrong format (not dictionary)");
	STAssertTrue([[responseObject objectForKey:@"testName"] isEqual:@"testStartLoadingWithDelegate"], @"wrong canned response");
}

- (void)testAgainStartLoadingWithDelegate {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testAgainStartLoadingWithDelegate"]];
	
	[ILCannedURLProtocol setDelegate:self];
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	
	STAssertNotNil(responseObject, @"no canned response from http request");
	STAssertTrue([responseObject isKindOfClass:[NSDictionary class]], @"canned response has wrong format (not dictionary)");
	STAssertTrue([[responseObject objectForKey:@"testName"] isEqual:@"testAgainStartLoadingWithDelegate"], @"wrong canned response");
}

- (void)testStartLoadingWithDelegatePlainJSONResponse {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testStartLoadingWithDelegatePlainJSONResponse"]];
	
	[ILCannedURLProtocol setDelegate:self];
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	
	STAssertNotNil(responseObject, @"no canned response from http request");
	STAssertTrue([responseObject isKindOfClass:[NSDictionary class]], @"canned response has wrong format (not dictionary)");
	STAssertTrue([[responseObject objectForKey:@"testName"] isEqual:@"testStartLoadingWithDelegatePlainJSONResponse"], @"wrong canned response");
}

- (void)testCanInitWithRequestWithDelegateShouldInitWithRequest {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testCanInitWithRequestWithDelegateShouldInitWithRequest"]];
	
	[ILCannedURLProtocol setDelegate:self];
	
	STAssertTrue([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol delegate returned shouldInitWithRequest NO");
}

- (void)testCanInitWithRequestWithDelegateShouldInitWithRequestNO {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testCanInitWithRequestWithDelegateShouldInitWithRequestNO"]];
	
	[ILCannedURLProtocol setDelegate:self];
	
	STAssertFalse([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol delegate returned shouldInitWithRequest YES");
}


- (void)testRedirectForClient {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://redirect-test.com"]];
    
    [ILCannedURLProtocol setDelegate:self];
    
    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	
    STAssertNotNil(response, @"no canned response from http request");
	STAssertNotNil(responseObject, @"no canned response object from http request");
    STAssertEqualObjects(response.URL.absoluteString, @"http://redirected-response.com", @"response should have been redirected");
    STAssertTrue([[responseObject objectForKey:@"REDIRECTED"] isEqual:@"YES"], @"wrong canned response");
}

- (void)testResponseBlock {

    [ILCannedURLProtocol setResponseDataBlock:^NSData *(id<NSURLProtocolClient> client, NSURLRequest *request) {

        NSData *requestData = nil;

        if ([request.URL.absoluteString isEqual:@"http://example.com/testResponseBlock"]) {
            id requestObject = [NSDictionary dictionaryWithObjectsAndKeys:@"testResponseBlock", @"testName", nil];
            requestData = [NSJSONSerialization dataWithJSONObject:requestObject options:0 error:nil];
            
        }

        return requestData;
    }];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testResponseBlock"]];

	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

	STAssertNotNil(responseObject, @"no canned response from http request");
	STAssertTrue([responseObject isKindOfClass:[NSDictionary class]], @"canned response has wrong format (not dictionary)");
	STAssertTrue([[responseObject objectForKey:@"testName"] isEqual:@"testResponseBlock"], @"wrong canned response");
}

- (void)testCanInitWithRequestWithShouldInitWithRequestBlock {

    [ILCannedURLProtocol setShouldInitWithRequestBlock:^BOOL(NSURLRequest *request) {
        if ([request.URL.absoluteString isEqual:@"http://example.com/testCanInitWithRequestWithShouldInitWithRequestBlock"]) {
            return YES;
        }
        return NO;
    }];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testCanInitWithRequestWithShouldInitWithRequestBlock"]];

	STAssertTrue([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol delegate returned shouldInitWithRequest NO");
}

- (void)testCanInitWithRequestWithShouldInitWithRequestBlockNO {

    [ILCannedURLProtocol setShouldInitWithRequestBlock:^BOOL(NSURLRequest *request) {
        if ([request.URL.absoluteString isEqual:@"http://example.com/testCanInitWithRequestWithShouldInitWithRequestBlockNO"]) {
            return NO;
        }
        return YES;
    }];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testCanInitWithRequestWithShouldInitWithRequestBlockNO"]];

	STAssertFalse([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol delegate returned shouldInitWithRequest YES");
}


- (void)testRedirectForClientBlock {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://redirect-test.com/testRedirectForClientBlock"]];


    [ILCannedURLProtocol setRedirectForClientBlock:^NSURL *(id<NSURLProtocolClient> client, NSURLRequest *request) {
        if ([request.HTTPMethod isEqualToString:@"GET"] && [request.URL.absoluteString isEqualToString:@"http://redirect-test.com/testRedirectForClientBlock"]) {
            return [NSURL URLWithString:@"http://redirected-response.com/testRedirectForClientBlock"];
        }

        return nil;
    }];

    [ILCannedURLProtocol setResponseDataBlock:^NSData *(id<NSURLProtocolClient> client, NSURLRequest *request) {
        NSData *requestData = nil;

        if ([request.URL.absoluteString isEqual:@"http://redirected-response.com/testRedirectForClientBlock"]) {
            id requestObject = [NSDictionary dictionaryWithObject:@"YES" forKey:@"REDIRECTED"];
            requestData = [NSJSONSerialization dataWithJSONObject:requestObject options:0 error:nil];
        }
        return requestData;
    }];

    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

    STAssertNotNil(response, @"no canned response from http request");
	STAssertNotNil(responseObject, @"no canned response object from http request");
    STAssertEqualObjects(response.URL.absoluteString, @"http://redirected-response.com/testRedirectForClientBlock", @"response should have been redirected");
    STAssertTrue([[responseObject objectForKey:@"REDIRECTED"] isEqual:@"YES"], @"wrong canned response");
}

- (void)testStatusCodeBlock {
    
    [ILCannedURLProtocol setStatusCodeBlock:^NSInteger(id<NSURLProtocolClient> client, NSURLRequest *request) {
        if ([request.URL.absoluteString isEqual:@"http://example.com/testStatusCodeBlock"]) {
            return 204;
        }
        return 201;
     }];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testStatusCodeBlock"]];

    NSHTTPURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];

    STAssertEquals([response statusCode], 204L, @"Wrong status code");
}

- (void)testHeadersBlock {

    [ILCannedURLProtocol setHeadersBlock:^NSDictionary *(id<NSURLProtocolClient> client, NSURLRequest *request) {
        if ([request.URL.absoluteString isEqual:@"http://example.com/testHeadersBlock"]) {
            return @{@"key": @"value"};
        }
        return nil;
    }];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testHeadersBlock"]];

    NSHTTPURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];

    NSDictionary *headers = [response allHeaderFields];
    STAssertNotNil(headers, @"no headers");
    STAssertTrue([[headers objectForKey:@"key"] isEqual:@"value"], @"no key on the header");
}


#pragma mark - ILCannedURLProtocolDelegate

- (NSURL *)redirectForClient:(id<NSURLProtocolClient>)client request:(NSURLRequest *)request
{
    if ([request.HTTPMethod isEqualToString:@"GET"] && [request.URL.absoluteString isEqualToString:@"http://redirect-test.com"]) {
        return [NSURL URLWithString:@"http://redirected-response.com"];
    }
    
    return nil;
}

- (NSData*)responseDataForClient:(id<NSURLProtocolClient>)client request:(NSURLRequest*)request {
	
	NSData *requestData = nil;
	
	if ([request.URL.absoluteString isEqual:@"http://example.com/testStartLoadingWithDelegate"]) {
		id requestObject = [NSDictionary dictionaryWithObjectsAndKeys:@"testStartLoadingWithDelegate", @"testName", nil];
		requestData = [NSJSONSerialization dataWithJSONObject:requestObject options:0 error:nil];
	
	}
	
	if ([request.URL.absoluteString isEqual:@"http://example.com/testAgainStartLoadingWithDelegate"]) {
		id requestObject = [NSDictionary dictionaryWithObjectsAndKeys:@"testAgainStartLoadingWithDelegate", @"testName", nil];
		requestData = [NSJSONSerialization dataWithJSONObject:requestObject options:0 error:nil];
			
	}
	
	if ([request.URL.absoluteString isEqual:@"http://example.com/testStartLoadingWithDelegatePlainJSONResponse"]) {
		requestData = [@"{\"testName\":\"testStartLoadingWithDelegatePlainJSONResponse\"}" dataUsingEncoding:NSUnicodeStringEncoding];
	}
    
    if ([request.URL.absoluteString isEqual:@"http://redirected-response.com"]) {
        id requestObject = [NSDictionary dictionaryWithObject:@"YES" forKey:@"REDIRECTED"];
		requestData = [NSJSONSerialization dataWithJSONObject:requestObject options:0 error:nil];
    }
	
	
	return requestData;
}


- (BOOL)shouldInitWithRequest:(NSURLRequest*)request {
	if ([request.URL.absoluteString isEqual:@"http://example.com/testCanInitWithRequestWithDelegateShouldInitWithRequest"]) {
		return YES;
	}
	
	if ([request.URL.absoluteString isEqual:@"http://example.com/testCanInitWithRequestWithDelegateShouldInitWithRequestNO"]) {
		return NO;
	}
	
	return YES;
}


@end
