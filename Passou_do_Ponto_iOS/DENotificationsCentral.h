//
//  DENotificationsCentral.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 05/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DENotificationsCentral : NSObject

- (void)showAlert:(UIViewController *)view content:(NSString *)text;

+ (id)sharedNotificationCentral;

@end
