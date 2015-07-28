//
//  DENotificationsCentral.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 05/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MRProgress.h>

@interface DENotificationsCentral : NSObject

- (void)showAlert:(UIViewController *)view content:(NSString *)text;
- (void)showAlertYesOrNo:(UIViewController *)view content:(NSString *)text ifYesExecute:(void (^)(void))yesBlock;
- (void)showDialog:(NSString *)text dialogType:(BOOL)success duration:(float)delay viewToShow:(UIView *)view;
- (void)showDialogProgress:(NSString *)text viewToShow:(UIView *)view;
- (void)dismiss:(UIView *)view;

+ (id)sharedNotificationCentral;

@end
