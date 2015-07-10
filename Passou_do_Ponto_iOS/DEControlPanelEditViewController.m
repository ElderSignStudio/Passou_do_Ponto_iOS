//
//  DEControlPanelEditViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 10/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DEControlPanelEditViewController.h"

@interface DEControlPanelEditViewController ()

@end

@implementation DEControlPanelEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.numeroOnibusTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"num_onibus"];
    self.longitudeTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"lng"];
    self.latitudeTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"lat"];
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
- (IBAction)okButtonPressed:(UIButton *)sender {
    
    id<DEControlPanelEditProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(editCompleted:)]) {
        
        long selectedRow = [self.tipoOcorrenciaPicker selectedRowInComponent:0] + 1;
        
        NSDictionary *ocorrenciaEditada = @{@"tipo" : [[NSNumber numberWithLong:selectedRow] stringValue], @"nr_onibus" : self.numeroOnibusTextField.text};
        
        [strongDelegate editCompleted:ocorrenciaEditada];
    }
    
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.tiposDeOcorrencia count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.tiposDeOcorrencia[row];
}

@end
