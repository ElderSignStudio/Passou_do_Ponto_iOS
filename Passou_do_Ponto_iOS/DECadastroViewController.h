//
//  DECadastroViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 04/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DECadastroProtocol;

@interface DECadastroViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *FamilyNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;

@property (nonatomic, weak) id<DECadastroProtocol> delegate;

@end

@protocol DECadastroProtocol <NSObject>

- (void)cadastroPreenchido:(NSDictionary *)cadastro;

@end