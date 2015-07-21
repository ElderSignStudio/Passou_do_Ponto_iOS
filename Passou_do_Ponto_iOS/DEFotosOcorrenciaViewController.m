//
//  DEFotosOcorrenciaViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 20/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "DEFotosOcorrenciaViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DENotificationsCentral.h"

@interface DEFotosOcorrenciaViewController ()

@end

@implementation DEFotosOcorrenciaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.photoButton0.imageView.tag = 0;
    self.photoButton1.imageView.tag = 1;
    self.photoButton2.imageView.tag = 2;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.photos) {
        self.photosMutable = [self.photos mutableCopy];
    } else self.photosMutable = [[NSMutableDictionary alloc] init];
    
    [self updateScreenImages];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Buttons

- (IBAction)photoButtonPressed:(UIButton *)sender {
    
    self.photoClicked = sender.imageView.tag;
    
    NSString *photoClickedString = [NSString stringWithFormat:@"%ld",(long)self.photoClicked];
    
    if ([self.photosMutable objectForKey:photoClickedString] == nil) {
        
        // Não tem foto neste button, abre o picker
        
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

    } else {
        
        // Tem foto neste button, DELETE
        
        DENotificationsCentral *sharedNC = [DENotificationsCentral sharedNotificationCentral];
        
        [sharedNC showAlertYesOrNo:self content:@"Deleta?" ifYesExecute:^{
            
            // Se o cara confirma, deleta de verdade
            
            [self.photosMutable removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)self.photoClicked]];
            [self updateScreenImages];
        }];
        
    }
    
}


- (IBAction)doneButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    id<DEOcorrenciaPhotoProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(photosChosen:)]) {
        
        [strongDelegate photosChosen:self.photosMutable];
    }
}

#pragma mark - Photo

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]) { // se veio um VIDEO
        NSURL *urlOfVideo = info[UIImagePickerControllerMediaURL];
        NSLog(@"Video URL = %@",urlOfVideo);
        
    } else if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]){ // se veio uma IMAGEM
        
        //self.photoMetadata = info[UIImagePickerControllerMediaMetadata];
        
        // coloca a foto n dict
        
        [self.photosMutable setObject:info[UIImagePickerControllerOriginalImage] forKey:[NSString stringWithFormat:@"%ld", (long)self.photoClicked]];
        
        self.photos = @{[NSString stringWithFormat:@"%ld", (long)self.photoClicked] : info[UIImagePickerControllerOriginalImage]};
        [self updateScreenImages];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
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


#pragma mark - Helper Methods

- (void)updateScreenImages
{
    // populate the screen UIImageViews

    if ([self.photosMutable objectForKey:@"0"] != nil) {
        [self.photoButton0 setImage:[self.photosMutable objectForKey:@"0"] forState:UIControlStateNormal];
    } else [self.photoButton0 setImage:[UIImage imageNamed:@"default-placeholder"] forState:UIControlStateNormal];
    
    
    if ([self.photosMutable objectForKey:@"1"] != nil) {
        [self.photoButton1 setImage:[self.photosMutable objectForKey:@"1"] forState:UIControlStateNormal];
    } else [self.photoButton1 setImage:[UIImage imageNamed:@"default-placeholder"] forState:UIControlStateNormal];
    
    if ([self.photosMutable objectForKey:@"2"] != nil) {
        [self.photoButton2 setImage:[self.photosMutable objectForKey:@"2"] forState:UIControlStateNormal];
    } else [self.photoButton2 setImage:[UIImage imageNamed:@"default-placeholder"] forState:UIControlStateNormal];

}

@end
