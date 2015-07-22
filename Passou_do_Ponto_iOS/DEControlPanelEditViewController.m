//
//  DEControlPanelEditViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 10/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DEControlPanelEditViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DEFotosOcorrenciaViewController.h"
#import "DERequestManager.h"
#import "Constants.h"
#import "DENotificationsCentral.h"

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
    
    // Initialize DEFotosOcorrenciaViewController
    if (!self.fotoViewController) self.fotoViewController = [[DEFotosOcorrenciaViewController alloc] init];
    
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
    
    
    NSMutableString *url = [NSMutableString stringWithString:postGetOcorrenciaFotos];
    [url appendString:[self.ocorrenciaEditada objectForKey:@"id"]];

    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM getFromServer:url caseOfSuccess:^(id responseObject, NSString *msg) {
        
        // Pegou a listagem de fotos
        NSArray *listagemFotos = (NSArray *)responseObject;

        // Monta o NSDictionary de UIImages
        NSMutableDictionary *mutableImages = [[NSMutableDictionary alloc] init];

        for (NSInteger count = [listagemFotos count]; count > 0; count--) {
            
            NSMutableString *url = [NSMutableString stringWithString:filenameURL];
            [url appendString:[listagemFotos[count-1] objectForKey:@"nome_arquivo"]];
            
            [mutableImages setObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]
                              forKey:[NSString stringWithFormat:@"%ld",(long)count-1]];
            
        }
        
        self.photos = (NSDictionary *)mutableImages;
        
        // Propriedades da DEFotosOcorrenciaViewController
        self.fotoViewController.delegate = self;
        self.fotoViewController.photos = self.photos;
        
        [self presentViewController:self.fotoViewController animated:YES completion:nil];
        
    } caseOfFailure:^(int errorType, NSString *error) {
        
        // Erro ao pegar listagem de fotos
        
        DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
        [sharedNC showDialog:error dialogType:NO duration:2.0 viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    }];

    
//    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
//        
//        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
//        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
//        
//        NSString *requiredMediaType = (__bridge NSString *)kUTTypeImage;
//        ipc.mediaTypes = [[NSArray alloc] initWithObjects:requiredMediaType, nil];
//        
//        ipc.allowsEditing = YES;
//        ipc.delegate = self;
//        
//        [self presentViewController:ipc animated:YES completion:nil];
//        
//    } else {
//        // Camera não disponível
//        
//        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ops"
//                                                                       message:@"Camera não disponível!"
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                              handler:^(UIAlertAction * action) {}];
//        
//        [alert addAction:defaultAction];
//        [self presentViewController:alert animated:YES completion:nil];
//    }


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

#pragma mark - DEOcorrenciaPhotoProtocol

- (void)photosChosen:(NSDictionary *)photos
{
    for (NSInteger i = 0; i < 3; i++) {
        
        UIImage *originalImage = [self.photos objectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
        UIImage *newImage = [photos objectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
        
        if (originalImage != newImage) {
            // são diferentes
            
            if (newImage) {
                // Insere o novo no lugar
                NSLog(@"Inserindo %@ no lugar do %@" ,newImage, originalImage);
                
            } else {
                // Não existe um novo, é um delete.
                NSLog(@"Deletando o %@" ,originalImage);
                
            }
            
        }
        
    }
}

- (BOOL)deletePhoto:(NSInteger)chosenPhoto
{
    NSLog(@"Will delete photo %ld",(long)chosenPhoto);
    return YES;
}

#pragma mark - Helper methods

// Dismiss the keyboard when touching anywhere else
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array
{
    id objectInstance;
    NSUInteger indexKey = 0U;
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (objectInstance in array)
        [mutableDictionary setObject:objectInstance forKey:[NSNumber numberWithUnsignedInt:indexKey++]];
    
    return (NSDictionary *)mutableDictionary;
}

@end
