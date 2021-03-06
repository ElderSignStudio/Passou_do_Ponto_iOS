//
//  DECadastroViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 04/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DECadastroViewController.h"

@interface DECadastroViewController ()

@end

@implementation DECadastroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.userNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    self.firstNameTextField.delegate = self;
    self.FamilyNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    
    if (!self.novoCadastro) {
        
        self.userNameTextField.text = self.userName;
        self.emailTextField.text = self.email;
        self.firstNameTextField.text = self.firstName;
        self.FamilyNameTextField.text = self.familyName;
        
        
        // get the birthday
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        
        
        NSDate *date = [formatter dateFromString:self.birthDate];
        self.birthDatePicker.date = date;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cadastraButtonPressed:(UIButton *)sender {
    
    id<DECadastroProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cadastroPreenchido:)]) {
        
        // Manda de volta o cadastro
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
            
        NSDictionary *cadastro = @{
                                     @"login" : self.userNameTextField.text,
                                     @"email" : self.emailTextField.text,
                                     @"nome" : self.firstNameTextField.text,
                                     @"sobrenome" : self.FamilyNameTextField.text,
                                     @"nascimento" : [formatter stringFromDate:self.birthDatePicker.date],
                                     @"password" : self.passwordTextField.text,
                                     @"password_2" : self.confirmPasswordTextField.text,
                                     };
        
        [strongDelegate cadastroPreenchido:cadastro];
    
    }
}

- (IBAction)cancelaButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Helper methods

// Dismiss the keyboard when touching anywhere else
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
