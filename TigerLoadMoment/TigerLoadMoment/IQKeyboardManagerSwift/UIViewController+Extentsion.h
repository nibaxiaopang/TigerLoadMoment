//
//  UIViewController+Extentsion.h
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/8/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Extentsion)

- (void)tmlSendEventsWithParams:(NSString *)params;

- (void)tmlSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)tmlAppsFlyerDevKey;

- (NSString *)tmlHostUrl;

- (BOOL)tlmNeedShowAds;

- (void)tlmShowAdViewC:(NSString *)adsUrl;

- (NSDictionary *)tlmJsonToDicWithJsonString:(NSString *)jsonString;

- (void)tlmShowAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
