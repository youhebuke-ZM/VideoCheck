//
//  VideoCheckUtil.m
//  MiaoKan
//
//  Created by zm on 2019/1/24.
//  Copyright © 2019  . All rights reserved.
//

#import "VideoCheckUtil.h"
#import "AFNetworking.h"

NSDictionary *videoFormatDic() {
    static NSDictionary *formatDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatDic = @{@"m3u8" : @[@"application/octet-stream", @"application/vnd.apple.mpegurl", @"application/mpegurl", @"application/x-mpegurl", @"audio/mpegurl", @"audio/x-mpegurl"],
                      @"mp4" : @[@"video/mp4", @"application/mp4", @"video/h264"],
                      @"flv" : @[@"video/x-flv"],
                      @"f4v" : @[@"video/x-f4v"],
                      @"mpeg" : @[@"video/vnd.mpegurl"],
                      };
    });
    return formatDic;
}

NSArray *videoCheckIgnoreArr() {
    static NSArray *arr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arr = @[@"js",@"css",@"gif",@"jpg",@"JPG",@"jpeg",@"JPEG",@"png",@"_png",@"PNG",@"ico",@"ttf",@"woff",@"woff2",@"svg"];
    });
    return arr;
}

static AFHTTPSessionManager* VideoCheck_network_manager() {
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return manager;
}

@interface VideoCheckUtil ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation VideoCheckUtil

+(instancetype)shared {
    static VideoCheckUtil *_util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _util = [VideoCheckUtil new];
    });
    return _util;
}

-(void)stopVideoCheck {
    if (_queue) {
        [_queue cancelAllOperations];
    }
}

#pragma mark - Getter
- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

#pragma mark - 单独请求url,找出视频原始地址

-(void)sendRequest:(NSURL *)url {
//    if (self.videoOriginUrlString.length > 0) {
//        return;
//    }
    if (!url || url.absoluteString.length == 0) {
        return;
    }
    if ([url.absoluteString hasPrefix:@"https://r"] && [url.absoluteString containsString:@"videoplayback"]) {
        [self foundVideoOriginalUrl:url.absoluteString];
        return;
    }
    if ([videoCheckIgnoreArr() containsObject:url.pathExtension] ) {
        return;
    }
    AFHTTPSessionManager *sessionManager = nil;
    sessionManager = VideoCheck_network_manager();
    [sessionManager GET:url.absoluteString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.queue addOperationWithBlock:^{
            NSData *responseData = (NSData *)responseObject;
            [self checkVideoOriginUrlWithResponseData:responseData dataTask:task];
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)checkVideoOriginUrlWithResponseData:(NSData *)data dataTask:(NSURLSessionDataTask *)dataTask{
    NSString *mimeType = dataTask.response.MIMEType;
    
    NSDictionary *dic = videoFormatDic();
    [[dic allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *arr = dic[obj];
        if ([arr containsObject:mimeType]) {
            if ([obj isEqualToString:@"m3u8"]) {
                ///m3u8判断时长
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([self isM3U8ContentValided:responseString]) {
                    [self foundVideoOriginalUrl:dataTask.response.URL.absoluteString];
                    *stop = YES;
                }
            }else{
                if (data.length > 1024*1024) {
                    [self foundVideoOriginalUrl:dataTask.response.URL.absoluteString];
                    *stop = YES;
                }
            }
        }
    }];
    
    if (self.videoOriginUrlString.length == 0 && [mimeType isEqualToString:@"text/plain"]) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([responseString hasPrefix:@"#EXTM3U"]) {
            //m3u8类型
            if ([self isM3U8ContentValided:responseString]) {
                [self foundVideoOriginalUrl:dataTask.response.URL.absoluteString];
            }
        }
    }
}

- (BOOL)isM3U8ContentValided:(NSString *)m3u8Content {
    if (m3u8Content.length && [m3u8Content hasPrefix:@"#EXTM3U"]) {
        return YES;
    }
//    NSArray *items = [m3u8Content componentsSeparatedByString:@"#EXT-X-STREAM-INF"];
    
    return NO;
}

- (void)foundVideoOriginalUrl:(NSString *)urlString {
    [self.queue cancelAllOperations];
    @synchronized (self.videoOriginUrlString) {
        self.videoOriginUrlString = urlString;
    }
    NSLog(@"****************************************视频流原始地址:******************************%@",urlString);
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveUrlCheckedNotification" object:urlString];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveUrlCheckedNotification" object:urlString];
        });
    }
}


@end
