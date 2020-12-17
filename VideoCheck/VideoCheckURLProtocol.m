//
//  VideoCheckURLProtocol.m
//  MiaoKan
//
//  Created by zm on 2019/1/24.
//  Copyright © 2019  . All rights reserved.
//

#import "VideoCheckURLProtocol.h"
#import "VideoCheckUtil.h"

NSString *const kURLProtocolHandledKey = @"URLProtocolHandledKey";
NSString *const HttpProtocolKey = @"http";
NSString *const HttpsProtocolKey = @"https";

@interface VideoCheckURLProtocol ()

@end

@implementation VideoCheckURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSURL *requestUrl = request.URL;
    NSLog(@"%@",requestUrl.absoluteString);
    [[VideoCheckUtil shared] sendRequest:requestUrl];
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
    return mutableReqeust;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)equivalent toRequest:(NSURLRequest *)request; {
    return [super requestIsCacheEquivalent:equivalent toRequest:request];
}

+ (NSMutableURLRequest *)redirectHostInRequset:(NSMutableURLRequest *)request {
    return request;
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    // 标示改request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:kURLProtocolHandledKey inRequest:mutableReqeust];
}

- (void)stopLoading
{
    
}

@end
