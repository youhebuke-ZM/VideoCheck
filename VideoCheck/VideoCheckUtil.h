//
//  VideoCheckUtil.h
//  MiaoKan
//
//  Created by zm on 2019/1/24.
//  Copyright © 2019  . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCheckUtil : NSObject
@property (nonatomic, copy, nullable) NSString *videoOriginUrlString;

+(instancetype)shared;
-(void)sendRequest:(NSURL *)url;
-(void)stopVideoCheck;
@end

NS_ASSUME_NONNULL_END
