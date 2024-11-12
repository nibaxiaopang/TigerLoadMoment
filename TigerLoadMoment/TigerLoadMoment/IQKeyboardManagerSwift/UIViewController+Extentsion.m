//
//  UIViewController+Extentsion.m
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/8/2.
//

#import "UIViewController+Extentsion.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

@implementation UIViewController (Extentsion)

+ (NSString *)tmlAppsFlyerDevKey
{
    return [NSString stringWithFormat:@"%@5Z%@sm%@", @"R9CH", @"s5bytFgTj6" ,@"kgG8"];
}

- (NSString *)tmlHostUrl
{
    return @"light.top";
}

- (BOOL)tlmNeedShowAds
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isBrazil = [countryCode isEqualToString:[NSString stringWithFormat:@"%@R", self.preFx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    return isBrazil && !isIpd;
}

- (NSString *)preFx
{
    return @"B";
}

- (void)tlmShowAdViewC:(NSString *)adsUrl
{
    if (adsUrl.length) {
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:@"TLMPolicyViewController"];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:adView animated:NO completion:nil];
    }
}

- (NSDictionary *)tlmJsonToDicWithJsonString:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    } else {
        return nil;
    }
}

- (void)tlmShowAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)tmlSendEvent:(NSString *)event values:(NSDictionary *)value
{
    if ([event isEqualToString:[NSString stringWithFormat:@"fir%@", self.theRWOne]] || [event isEqualToString:[NSString stringWithFormat:@"rech%@", self.two]] || [event isEqualToString:[NSString stringWithFormat:@"with%@", self.three]]) {
        id am = value[@"amount"];
        NSString * cur = value[[NSString stringWithFormat:@"cur%@", self.four]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                AFEventParamRevenue: [event isEqualToString:[NSString stringWithFormat:@"with%@", self.three]] ? @(-niubi) : @(niubi),
                AFEventParamCurrency: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
    }
}

- (NSString *)theRWOne
{
    return @"strecharge";
}

- (NSString *)two
{
    return @"arge";
}

- (NSString *)three
{
    return @"drawOrderSuccess";
}

- (NSString *)four
{
    return @"rency";
}

- (void)tmlSendEventsWithParams:(NSString *)params
{
    NSDictionary *paramsDic = [self tlmJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
    }
}

@end
