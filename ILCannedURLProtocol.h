//
//  ILCannedURLProtocol.h
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

#import <Foundation/Foundation.h>

@protocol ILCannedURLProtocolDelegate <NSObject>
- (NSData*)responseDataForClient:(id<NSURLProtocolClient>)client request:(NSURLRequest*)request;
@optional
- (BOOL)shouldInitWithRequest:(NSURLRequest*)request;
- (NSURL *)redirectForClient:(id<NSURLProtocolClient>)client request:(NSURLRequest *)request;
- (NSInteger)statusCodeForClient:(id<NSURLProtocolClient>)client request:(NSURLRequest*)request;
- (NSDictionary*)headersForClient:(id<NSURLProtocolClient>)client request:(NSURLRequest*)request;
@end

@interface ILCannedURLProtocol : NSURLProtocol
+ (void)setStartLoadingBlock:(void(^)(NSURLRequest *request))block;
+ (void)setDelegate:(id<ILCannedURLProtocolDelegate>)delegate;

+ (void)setCannedResponseData:(NSData*)data;
+ (void)setCannedHeaders:(NSDictionary*)headers;
+ (void)setCannedStatusCode:(NSInteger)statusCode;
+ (void)setCannedError:(NSError*)error;

+ (void)setSupportedMethods:(NSArray*)methods;
+ (void)setSupportedSchemes:(NSArray*)schemes;
+ (void)setSupportedBaseURL:(NSURL*)baseURL;

+ (void)setResponseDelay:(CGFloat)responseDelay;


@end
