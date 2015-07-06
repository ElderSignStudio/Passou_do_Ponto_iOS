//
//  DENotificationsCentral.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 05/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DENotificationsCentral.h"

@implementation DENotificationsCentral

#pragma mark Singleton Methods

+ (id)sharedNotificationCentral {
    
    static DENotificationsCentral *sharedNotificationCentral = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedNotificationCentral = [[self alloc] init];
    });
    
    return sharedNotificationCentral;
}

- (id)init
{
    if (self = [super init]) {
        //initialize properties here
    }
    return self;
}

#pragma mark - Alerts

-(void)showAlert:(UIViewController *)view content:(NSString *)text
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ops!"
                                                                   message:[text stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [view presentViewController:alert animated:YES completion:nil];
    
}


@end
