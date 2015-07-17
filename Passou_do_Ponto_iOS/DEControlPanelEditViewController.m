//
//  DEControlPanelEditViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 10/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DEControlPanelEditViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface DEControlPanelEditViewController ()

@end

@implementation DEControlPanelEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.photo = nil;
    self.photoMetadata = nil;
    
    self.numeroOnibusTextField.delegate = self;
    
    if (self.ocorrenciaENova) {
        
        self.numeroOnibusTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@""];
        self.longitudeTextField.text = self.lng;
        self.latitudeTextField.text = self.lat;
        
    } else {
        
        self.numeroOnibusTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"num_onibus"];
        self.longitudeTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"lng"];
        self.latitudeTextField.text = (NSString *)[self.ocorrenciaEditada objectForKey:@"lat"];
        
        self.fotoButton.hidden = NO;
    }
    
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
        
        NSDictionary *ocorrenciaFoiEditada;
        
        if (self.ocorrenciaENova) {
            
            // monta o dicitionary no formato do INSERT OCORRENCIA
            
            ocorrenciaFoiEditada = @{
                           @"lat" : self.lat,
                           @"lng" : self.lng,
                           @"tipo" : [[NSNumber numberWithLong:selectedRow] stringValue],
                           @"usuario_id" : @"1",
                           @"nr_onibus" : self.numeroOnibusTextField.text,
                           @"nr_ordem" : @""
                           };
            
        } else {
            
            // monta o dicitionary no formato do EDIT OCORRENCIA
            ocorrenciaFoiEditada = @{@"id" : [self.ocorrenciaEditada objectForKey:@"id"], @"tipo" : [[NSNumber numberWithLong:selectedRow] stringValue], @"nr_onibus" : self.numeroOnibusTextField.text, @"usuario_id" : @"1"};
        }
        
        [strongDelegate editCompleted:ocorrenciaFoiEditada];
    }
    
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fotoButtonPressed:(UIButton *)sender {

    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        NSString *requiredMediaType = (__bridge NSString *)kUTTypeImage;
        ipc.mediaTypes = [[NSArray alloc] initWithObjects:requiredMediaType, nil];
        
        ipc.allowsEditing = YES;
        ipc.delegate = self;
        
        [self presentViewController:ipc animated:YES completion:nil];
        
    } else {
        // Camera não disponível
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ops"
                                                                       message:@"Camera não disponível!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }


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

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Camera

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]) { // se veio um VIDEO
        NSURL *urlOfVideo = info[UIImagePickerControllerMediaURL];
        NSLog(@"Video URL = %@",urlOfVideo);
        
    } else if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]){ // se veio uma IMAGEM
        // get the metadata
        
        self.photoMetadata = info[UIImagePickerControllerMediaMetadata];
        self.photo = info[UIImagePickerControllerOriginalImage];
        
        id<DEControlPanelEditProtocol> strongDelegate = self.delegate;
        
        if ([strongDelegate respondsToSelector:@selector(imagePickerFinished:ocorrenciaId:)]) {
            
            self.fotoButton.titleLabel.text = @"Enviando...";
        
            [strongDelegate imagePickerFinished:self.photo ocorrenciaId:(NSString *)[self.ocorrenciaEditada objectForKey:@"id"]];
        }
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)updatePhotoButton:(NSString *)text
{
    [self.fotoButton setTitle:text forState:UIControlStateNormal];
    [self.fotoButton setTitle:text forState:UIControlStateSelected];
    [self.fotoButton setTitle:text forState:UIControlStateHighlighted];
    self.fotoButton.enabled = NO;
}

#pragma mark - Camera Helper Methods

// Existe uma camera no device?
- (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// Camera suporta fotos?
- (BOOL) doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

// Verifica se a camera siporta o tipo de função
- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO; // __block: variavel RESULT se modificada dentro de mum block vai aparecer fora tambem
    
    if ([paramMediaType length] == 0) {
        NSLog(@"Media type is empty.");
        return NO;
    }
    
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

// Dismiss the keyboard when touching anywhere else
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
