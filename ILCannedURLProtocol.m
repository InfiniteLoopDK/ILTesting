//
//  ILCannedURLProtocol.m
//
//  Created by Claus Broch on 10/09/11.
//  Copyright 2011 Infinite Loop. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted
//  provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice, this list of conditions 
//    and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice, this list of 
//    conditions and the following disclaimer in the documentation and/or other materials provided 
//    with the distribution.
//  - Neither the name of Infinite Loop nor the names of its contributors may be used to endorse or 
//    promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR 
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY 
//  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ILCannedURLProtocol.h"

static id<ILCannedURLProtocolDelegate> gILDelegate = nil;

static void(^startLoadingBlock)(NSURLRequest *request) = nil;
static NSData *gILCannedResponseData = nil;
static NSDictionary *gILCannedHeaders = nil;
static NSInteger gILCannedStatusCode = 200;
static NSError *gILCannedError = nil;
static NSArray *gILSupportedMethods = nil;
static NSArray *gILSupportedSchemes = nil;
static NSURL *gILSupportedBaseURL = nil;
static CGFloat gILResponseDelay = 0;

static ResponseDataBlock gResposeDataBlock = nil;
static ShouldInitRequestBlock gShouldInitRequestBlock = nil;
static RedirectBlockForClient gRedirectBlockForClient = nil;
static StatusCodeBlock gStatusCodeBlock = nil;
static HeadersBlock gHeadersBlock = nil;

@implementation ILCannedURLProtocol

+ (void)setStartLoadingBlock:(void(^)(NSURLRequest *request))block {
    Block_release(startLoadingBlock);
    startLoadingBlock = Block_copy(block);
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	
	BOOL canInit = YES;
	
	if (gILDelegate && [gILDelegate respondsToSelector:@selector(shouldInitWithRequest:)]) {
		canInit = [gILDelegate shouldInitWithRequest:request];
	} else {
		canInit = (
				   (!gILSupportedBaseURL || [request.URL.absoluteString hasPrefix:gILSupportedBaseURL.absoluteString]) &&
				   (!gILSupportedMethods || [gILSupportedMethods containsObject:request.HTTPMethod]) &&
				   (!gILSupportedSchemes || [gILSupportedSchemes containsObject:request.URL.scheme])
				   );
	}

    if (gShouldInitRequestBlock) {
        canInit = gShouldInitRequestBlock(request);
    }

	return canInit;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}

+ (void)setDelegate:(id<ILCannedURLProtocolDelegate>)delegate {
	gILDelegate = delegate;
}

+ (void)setCannedResponseData:(NSData*)data {
	if(data != gILCannedResponseData) {
		[gILCannedResponseData release];
		gILCannedResponseData = [data retain];
	}
}

+ (void)setCannedHeaders:(NSDictionary*)headers {
	if(headers != gILCannedHeaders) {
		[gILCannedHeaders release];
		gILCannedHeaders = [headers retain];
	}
}

+ (void)setCannedStatusCode:(NSInteger)statusCode {
	gILCannedStatusCode = statusCode;
}

+ (void)setCannedError:(NSError*)error {
	if(error != gILCannedError) {
		[gILCannedError release];
		gILCannedError = [error retain];
	}
}

- (NSCachedURLResponse *)cachedResponse {
	return nil;
}

+ (void)setSupportedMethods:(NSArray*)methods {
	if(methods != gILSupportedMethods) {
		[gILSupportedMethods release];
		gILSupportedMethods = [methods retain];
	}
}

+ (void)setSupportedSchemes:(NSArray*)schemes {
	if(schemes != gILSupportedSchemes) {
		[gILSupportedSchemes release];
		gILSupportedSchemes = [schemes retain];
	}
}

+ (void)setSupportedBaseURL:(NSURL*)baseURL {
	if(baseURL != gILSupportedBaseURL) {
		[gILSupportedBaseURL release];
		gILSupportedBaseURL = [baseURL retain];
	}
}


+ (void)setResponseDelay:(CGFloat)responseDelay {
	gILResponseDelay = responseDelay;
}

+ (void)setResponseDataBlock:(ResponseDataBlock)responseDataBlock {
    Block_release(gResposeDataBlock);
    gResposeDataBlock = Block_copy(responseDataBlock);
}

+ (void)setShouldInitWithRequestBlock:(ShouldInitRequestBlock)shouldInitRequestBlock {
    Block_release(gShouldInitRequestBlock);
    gShouldInitRequestBlock = Block_copy(shouldInitRequestBlock);
}

+ (void)setRedirectForClientBlock:(RedirectBlockForClient)redirectForClientBlock {
    Block_release(gRedirectBlockForClient);
    gRedirectBlockForClient = Block_copy(redirectForClientBlock);
}

+ (void)setStatusCodeBlock:(StatusCodeBlock)statusCodeBlock {
    Block_release(gStatusCodeBlock);
    gStatusCodeBlock = Block_copy(statusCodeBlock);
}

+ (void)setHeadersBlock:(HeadersBlock)headersBlock {
    Block_release(gHeadersBlock);
    gHeadersBlock = Block_copy(headersBlock);
}

- (void)startLoading {
    NSURLRequest *request = [self request];
	id<NSURLProtocolClient> client = [self client];

    if (startLoadingBlock) {
        startLoadingBlock(request);
    }
    
	NSInteger statusCode = gILCannedStatusCode;
	NSDictionary *headers = gILCannedHeaders;
	NSData *responseData = gILCannedResponseData;
    
    // Handle redirects
    NSURL *redirectUrl = nil;

    if (gRedirectBlockForClient) {
        redirectUrl = gRedirectBlockForClient(client,request);
    } else if (gILDelegate && [gILDelegate respondsToSelector:@selector(redirectForClient:request:)]) {
        redirectUrl = [gILDelegate redirectForClient:client request:request];
    }
    
    if (redirectUrl) {
        NSHTTPURLResponse *redirectResponse = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
                                                                          statusCode:302
                                                                         HTTPVersion:@"HTTP/1.1"
                                                                        headerFields: [NSDictionary dictionaryWithObject:[redirectUrl absoluteString] forKey:@"Location"]];
        
        [client URLProtocol:self wasRedirectedToRequest:[NSURLRequest requestWithURL:redirectUrl] redirectResponse:redirectResponse];
        return;
    }

	if (gILCannedError) {
		[NSThread sleepForTimeInterval:gILResponseDelay];
		[client URLProtocol:self didFailWithError:gILCannedError];
		
	} else {



        if (gILDelegate && [gILDelegate respondsToSelector:@selector(responseDataForClient:request:)]) {
            
            if ([gILDelegate respondsToSelector:@selector(statusCodeForClient:request:)]) {
                statusCode  = [gILDelegate statusCodeForClient:client request:request];
			}
			
			if ([gILDelegate respondsToSelector:@selector(headersForClient:request:)]) {
				headers  = [gILDelegate headersForClient:client request:request];
			}
            
			responseData = [gILDelegate responseDataForClient:client request:request];
		}

        if (gResposeDataBlock) {
            responseData = gResposeDataBlock(client,request);
        }

        if (gStatusCodeBlock) {
            statusCode = gStatusCodeBlock(client,request);
        }

        if (gHeadersBlock) {
            headers = gHeadersBlock(client,request);
        }

        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
											   statusCode:statusCode
											  HTTPVersion:@"HTTP/1.1"
											 headerFields:headers];
		
		[NSThread sleepForTimeInterval:gILResponseDelay];
		//NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:gILResponseDelay];
		//[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:loopUntil];
		
		
		[client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
		[client URLProtocol:self didLoadData:responseData];
		[client URLProtocolDidFinishLoading:self];
		
		[response release];
	}
}

- (void)stopLoading {
}

@end
