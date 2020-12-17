//
//  NSURLProtocol+WebKitSupport.h
//  KG_Video
//
//  Created by Ez on 2018/7/2.
//  Copyright © 2018   . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WebKitSupport)
+ (void)wk_registerScheme:(NSString*)scheme;

+ (void)wk_unregisterScheme:(NSString*)scheme;
@end
