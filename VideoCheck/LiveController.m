//
//  LiveController.m
//  VideoCheck
//
//  Created by youhebuke on 2019/12/13.
//  Copyright © 2019 carpeople. All rights reserved.
//

#import "LiveController.h"
#import <AVKit/AVKit.h>

#define kScreenBounds  (UIScreen.mainScreen.bounds)
#define kScreenSize    (kScreenBounds.size)
#define kScreenWidth   (kScreenSize.width)
#define kScreenHeight  (kScreenSize.height)

#define kWidthScale    ((kScreenWidth * 1.0)/375.0)
#define kHeightScale   ((kScreenHeight * 1.0)/667.0)

#define kIsIPhoneX  isIPhoneXSeries()

#define kStatusBarHeight  (kIsIPhoneX ? 44.0 : 20.0)
#define kCustomNaviBarHeight  (44.0)
#define kNavigationBarHeight  (kStatusBarHeight + kCustomNaviBarHeight)
#define kTabbarSafeBottomMargin (kIsIPhoneX ? 34.0 : 0.0)
#define kTabBarHeight  (kTabbarSafeBottomMargin + 49.0)

static inline BOOL isIPhoneXSeries() {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    
    return iPhoneXSeries;
}

@interface LiveController ()

@property (nonatomic, strong)AVPlayerViewController *playerVC;

@end

@implementation LiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self playVideoWithUrl:self.videoUrl];
}


- (void)playVideoWithUrl:(NSURL *)url {
    if (!url) {
        return;
    }
    self.playerVC = [[AVPlayerViewController alloc] init];
    self.playerVC.player = [AVPlayer playerWithURL:url];
    self.playerVC.view.frame = CGRectMake(0, kNavigationBarHeight + 100, kScreenWidth, 300);
    self.playerVC.showsPlaybackControls = YES;
//    self.playerVC.entersFullScreenWhenPlaybackBegins = YES;//开启这个播放的时候支持（全屏）横竖屏哦
//    self.playerVC.exitsFullScreenWhenPlaybackEnds = YES;//开启这个所有 item 播放完毕可以退出全屏
    [self.view addSubview:self.playerVC.view];
    
//    if (self.playerVC.readyForDisplay) {
        [self.playerVC.player play];
//    }
}


@end

