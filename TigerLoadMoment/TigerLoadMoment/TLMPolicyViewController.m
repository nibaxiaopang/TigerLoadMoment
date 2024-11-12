//
//  TLMPolicyViewController.m
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/11/12.
//

#import "TLMPolicyViewController.h"
#import "UIViewController+Extentsion.h"
#import <WebKit/WebKit.h>

@interface TLMPolicyViewController ()<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet WKWebView *policyWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCos;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCos;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic, copy) void(^backAction)(void);
@property (nonatomic, copy) NSString *extUrlstring;

@property (nonatomic, strong) NSDictionary *confData;
@property (nonatomic, assign) BOOL bju;
@end

@implementation TLMPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.confData = [NSUserDefaults.standardUserDefaults objectForKey:@"TLMPolicyHanlde"];
    self.bju = [[self.confData objectForKey:@"bju"] boolValue];
    [self tmlPrivacyInitSubViews];
    [self tcInitConfigNav];
    [self tcInitWebViewConfig];
    [self tcInitWebData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.confData) {
        NSInteger top = [[self.confData objectForKey:@"top"] integerValue];
        NSInteger bottom = [[self.confData objectForKey:@"bottom"] integerValue];
        if (top>0) {
            self.topCos.constant = self.view.safeAreaInsets.top;
        }
        
        if (bottom>0) {
            self.bottomCos.constant = self.view.safeAreaInsets.bottom;
        }
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

#pragma mark Event

- (void)backClick
{
    if (self.backAction) {
        self.backAction();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark INIT
- (void)tmlPrivacyInitSubViews
{
    self.policyWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.view.backgroundColor = UIColor.blackColor;
    self.policyWebView.backgroundColor = [UIColor blackColor];
    self.policyWebView.opaque = NO;
    self.policyWebView.scrollView.backgroundColor = [UIColor blackColor];
    self.indicatorView.hidesWhenStopped = YES;
}

- (void)tcInitConfigNav
{
    if (!self.url.length) {
        self.policyWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        return;
    }
    
    self.backBtn.hidden = YES;
    self.navigationController.navigationBar.tintColor = [UIColor systemBlueColor];
    UIImage *image = [UIImage systemImageNamed:@"xmark"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)tcInitWebViewConfig
{
    if (self.confData) {
        NSInteger type = [[self.confData objectForKey:@"type"] integerValue];
        WKUserContentController *userContentC = self.policyWebView.configuration.userContentController;
        // w
        if (type == 1) {
            NSString *trackStr = @"window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.TLMHandleEvents.postMessage({name, data})\n    }\n};\n";
            WKUserScript *trackScript = [[WKUserScript alloc] initWithSource:trackStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [userContentC addUserScript:trackScript];
            
            NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
            if (!version) {
                version = @"";
            }
            NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
            if (!bundleId) {
                bundleId = @"";
            }
            NSString *inPPStr = [NSString stringWithFormat:@"window.WgPackage = {name: '%@', version: '%@'}", bundleId, version];
            WKUserScript *inPPScript = [[WKUserScript alloc] initWithSource:inPPStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [userContentC addUserScript:inPPScript];
            [userContentC addScriptMessageHandler:self name:@"TLMHandleEvents"];
        }
        
        // afu
        else {
            [userContentC addScriptMessageHandler:self name:@"jsBridge"];
        }
    }
    
    self.policyWebView.navigationDelegate = self;
    self.policyWebView.UIDelegate = self;
}

- (void)tcInitWebData
{
    if (self.url.length) {
        NSURL *url = [NSURL URLWithString:self.url];
        if (url == nil) {
            return;
        }
        [self.indicatorView startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.policyWebView loadRequest:request];
    } else {
        NSURL *url = [NSURL URLWithString:@"https://www.termsfeed.com/live/caa50514-be1a-458d-a553-da93fff8bdaf"];
        if (url == nil) {
            return;
        }
        [self.indicatorView startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.policyWebView loadRequest:request];
    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *name = message.name;
    if ([name isEqualToString:@"TLMHandleEvents"]) {
        NSDictionary *trackMessage = (NSDictionary *)message.body;
        NSString *tName = trackMessage[@"name"] ?: @"";
        NSString *tData = trackMessage[@"data"] ?: @"";
        NSData *data = [tData dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data) {
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!error && [jsonObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = jsonObject;
                if (![tName isEqualToString:@"openWindow"]) {
                    [self tmlSendEvent:tName values:dic];
                    return;
                }
                if ([tName isEqualToString:@"rechargeClick"]) {
                    return;
                }
                NSString *adId = dic[@"url"] ?: @"";
                if (adId.length > 0) {
                    [self tcReloadWebViewData:adId];
                }
            }
        } else {
            [self tmlSendEvent:tName values:@{tName: data}];
        }
    }  else if ([message.name isEqualToString:@"jsBridge"] && [message.body isKindOfClass:[NSString class]]) {
        NSDictionary *dic = [self tlmJsonToDicWithJsonString:(NSString *)message.body];
        NSString *evName = dic[@"funcName"] ?: @"";
        NSString *evParams = dic[@"params"] ?: @"";
        if ([evName isEqualToString:@"openAppBrowser"]) {
            NSDictionary *uDic = [self tlmJsonToDicWithJsonString:evParams];
            NSString *urlStr = uDic[@"url"] ?: @"";
            NSURL *url = [NSURL URLWithString:urlStr];
            if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        } else if ([evName isEqualToString:@"appsFlyerEvent"]) {
            [self tmlSendEventsWithParams:evParams];
        }
    }
}

- (void)tcReloadWebViewData:(NSString *)adurl
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.extUrlstring isEqualToString:adurl] && self.bju) {
            return;
        }
        
        TLMPolicyViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:@"TLMPolicyViewController"];
        adView.url = adurl;
        __weak typeof(self) weakSelf = self;
        adView.backAction = ^{
            NSString *close = @"window.closeGame();";
            [weakSelf.policyWebView evaluateJavaScript:close completionHandler:nil];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:adView];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    });
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
    });
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame == nil) {
        NSURL *url = navigationAction.request.URL;
        if (url) {
            self.extUrlstring = url.absoluteString;
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSString *authenticationMethod = challenge.protectionSpace.authenticationMethod;
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = nil;
        if (challenge.protectionSpace.serverTrust) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        }
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

@end
