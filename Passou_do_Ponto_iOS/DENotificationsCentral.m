//
//  DENotificationsCentral.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 05/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DENotificationsCentral.h"
#import <MRProgress.h>

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

-(void)showAlertYesOrNo:(UIViewController *)view content:(NSString *)text ifYesExecute:(void (^)(void))yesBlock
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Certeza?"
                                                                   message:[text stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // execute block sent
        yesBlock();
    }];
    
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [view presentViewController:alert animated:YES completion:nil];

}


#pragma mark - MRProgress Dialogs


- (void)showDialog:(NSString *)text dialogType:(BOOL)success duration:(float)delay viewToShow:(UIView *)view
{
    [MRProgressOverlayView dismissOverlayForView:view animated:YES];
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:view animated:YES];
    
    progressView.titleLabelText = [self removeHTML:text];
    
    if (success) {
        progressView.mode = MRProgressOverlayViewModeCheckmark;
    } else progressView.mode = MRProgressOverlayViewModeCross;
    
    if (delay > 0.0) {
        [self performSelector:@selector(dismissDialog:) withObject:progressView afterDelay:delay];
    }
    
}


- (void)showDialogProgress:(NSString *)text viewToShow:(UIView *)view
{
    [MRProgressOverlayView dismissOverlayForView:view animated:YES];
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:view animated:YES];
    
    progressView.titleLabelText = [self removeHTML:text];
    
    progressView.mode = MRProgressOverlayViewModeIndeterminate;
    
}

- (void)dismissDialog:(MRProgressOverlayView *)overlayView
{
    [overlayView dismiss:YES];
}

- (void)dismiss:(UIView *)view
{
    [MRProgressOverlayView dismissOverlayForView:view animated:YES];
}


#pragma mark - String Manipulation

- (NSString *)removeHTML:(NSString *)text
{
    NSArray *replaceAll = [NSArray arrayWithObjects:@"<BR>", @"</BR>", @"<br>", @"</br>", nil];
    NSString *replaceWith = @"";
    
    for (NSString *toReplace in replaceAll) {
        text = [text stringByReplacingOccurrencesOfString:toReplace withString:replaceWith];
    }

    
    return text;
}

@end
