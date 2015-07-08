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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)cadastraButtonPressed:(UIButton *)sender {
    
    id<DECadastroProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(cadastroPreenchido:)]) {
        
        // Manda de volta o cadastro
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        
        NSDictionary *cadastro = @{
                                     @"login" : self.userNameTextField.text,
                                     @"senha" : self.passwordTextField.text,
                                     @"email" : self.emailTextField.text,
                                     @"nome" : self.firstNameTextField.text,
                                     @"sobrenome" : self.FamilyNameTextField.text,
                                     @"nascimento" : [formatter stringFromDate:self.birthDatePicker.date],
                                     @"password" : self.passwordTextField.text,
                                     @"password_2" : self.confirmPasswordTextField.text,
                                     };
        
        [strongDelegate cadastroPreenchido:cadastro];
        
        //[self dismissViewControllerAnimated:YES completion:nil];
    
    }
}

- (IBAction)cancelaButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
