//
//  HomeViewController.m
//  VideoCheck
//
//  Created by youhebuke on 2019/12/13.
//  Copyright © 2019 carpeople. All rights reserved.
//

#import "HomeViewController.h"
#import "VideoCheckURLProtocol.h"
#import "NSURLProtocol+WebKitSupport.h"
#import <WebKit/WebKit.h>
#import "LiveController.h"

@interface HomeViewController ()
@property (nonatomic, strong) WKWebView *wkWebView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     for (int i = 1; i <= 10; i ++) {
           UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
           btn.backgroundColor = [UIColor redColor];
           [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
           [btn setTitle:[NSString stringWithFormat:@"Live%d",i] forState:UIControlStateNormal];
           [btn addTarget:self action:@selector(goLive:) forControlEvents:UIControlEventTouchUpInside];
           btn.frame = CGRectMake(30, 100 + i * 50, UIScreen.mainScreen.bounds.size.width - 60, 40);
           btn.tag = i;
           [self.view addSubview:btn];
       }
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveUrlChecked:) name:@"LiveUrlCheckedNotification" object:nil];
}

- (void)checkVideoUrl:(NSString *)urlString {
//    [self addHookForVideoCheckURLProtocol];
    NSMutableURLRequest *request = nil;
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        [self.wkWebView loadRequest:request];
    }
}

- (void)goLive:(UIButton *)sender {
    
//    NSString *urlString = [NSString stringWithFormat:@"http://nbastreams.xyz/live/%ld/",(long)sender.tag];
//    [self checkVideoUrl:urlString];
    [self checkVideoUrl:@"https://payments-web-sandbox.paymaya.com/paymaya/payment?id=ff3ac4c6-e97e-4c17-b364-e14227f87e0f"];
}

- (void)liveUrlChecked:(NSNotification *)notifi {
    [self removeHookForVideoCheckURLProtocol];
    NSString *urlStr = notifi.object;
    [self playVideo:urlStr];
}

- (void)playVideo:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url) {
        LiveController *liveCtr = [LiveController new];
        liveCtr.videoUrl = url;
        [self.navigationController pushViewController:liveCtr animated:YES];
    }
}


- (void)addHookForVideoCheckURLProtocol
{
    for (NSString* scheme in @[@"http", @"https", @"file"]) {
        [NSURLProtocol wk_registerScheme:scheme];
    }
    [VideoCheckURLProtocol registerClass:[VideoCheckURLProtocol class]];
}

- (void)removeHookForVideoCheckURLProtocol
{
    for (NSString* scheme in @[@"http", @"https", @"file"]) {
        [NSURLProtocol wk_unregisterScheme:scheme];
    }
    [VideoCheckURLProtocol unregisterClass:[VideoCheckURLProtocol class]];
}


- (WKWebView *)wkWebView{
    if (!_wkWebView) {
        //设置网页的配置文件
        WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
        if(@available (iOS 9.0, *)) {
            Configuration.allowsAirPlayForMediaPlayback = YES;
        }
        
        // 允许在线播放
        Configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        Configuration.selectionGranularity = YES;
        // web内容处理池
        Configuration.processPool = default_Pool();
        //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
        WKUserContentController * UserContentController = [[WKUserContentController alloc]init];
        // 是否支持记忆读取
        //        Configuration.suppressesIncrementalRendering = YES;
        // 允许用户更改网页的设置
        Configuration.userContentController = UserContentController;
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        Configuration.preferences = preferences;
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
       
        _wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:Configuration];
        _wkWebView.backgroundColor = [UIColor grayColor];
        _wkWebView.scrollView.backgroundColor = [UIColor lightGrayColor];
//        // 设置代理
//        _wkWebView.navigationDelegate = self;
//        _wkWebView.UIDelegate = self;
        //kvo 添加进度监控
        //开启手势触摸 设置 可以前进 和 后退
        _wkWebView.allowsBackForwardNavigationGestures = YES;
//        _wkWebView.alpha = 0;
        //适应你设定的尺寸
        //        [_wkWebView sizeToFit];
        [self.view addSubview:_wkWebView];
        
    }
    return _wkWebView;
}

WKProcessPool *default_Pool() {
    static WKProcessPool *pool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[WKProcessPool alloc] init];
    });
    return pool;
}

@end
