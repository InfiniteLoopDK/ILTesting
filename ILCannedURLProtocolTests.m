//
//  ILCannedURLProtocolTests.m
//  TactilizeKit
//
//  Created by Arnaud Coomans on 03/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ILCannedURLProtocolTests.h"

@implementation ILCannedURLProtocolTests

- (void)testCanInitWithGETHTTPRequestWithSupportedSchemesAndMethodsNotSet {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://test.com"]];
	request.HTTPMethod = @"GET";
	
	[ILCannedURLProtocol setSupportedMethods:nil];
	[ILCannedURLProtocol setSupportedSchemes:nil];
	
	STAssertTrue([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithGETHTTPRequestWithSupportedSchemesAndMethodsEmpty {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://test.com"]];
	request.HTTPMethod = @"GET";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray array]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray array]];
	
	STAssertFalse([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithGETHTTPRequestWithSupportedHTTPSchemesAndGETMethods{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://test.com"]];
	request.HTTPMethod = @"GET";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray arrayWithObject:@"GET"]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray arrayWithObject:@"http"]];
	
	STAssertTrue([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithPOSTHTTPSRequestWithSupportedHTTPSSchemesAndPOSTMethods{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://test.com"]];
	request.HTTPMethod = @"POST";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray arrayWithObject:@"POST"]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray arrayWithObject:@"https"]];
	
	STAssertTrue([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithPOSTHTTPRequestWithSupportedHTTPSchemesAndGETMethods{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://test.com"]];
	request.HTTPMethod = @"POST";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray arrayWithObject:@"GET"]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray arrayWithObject:@"http"]];
	
	STAssertFalse([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

- (void)testCanInitWithGETHTTPRequestWithSupportedHTTPSSchemesAndGETMethods{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://test.com"]];
	request.HTTPMethod = @"GET";
	
	[ILCannedURLProtocol setSupportedMethods:[NSArray arrayWithObject:@"GET"]];
	[ILCannedURLProtocol setSupportedSchemes:[NSArray arrayWithObject:@"https"]];
	
	STAssertFalse([ILCannedURLProtocol canInitWithRequest:request], @"ILCannedURLProtocol does not support a GET HTTP request");
}

@end
