//
//  DELoginViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 05/04/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DELoginProtocol;

@interface DELoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usuarioTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic, weak) id<DELoginProtocol> delegate;

@end

@protocol DELoginProtocol <NSObject>

- (void)loginSucces:(BOOL)result;

@end