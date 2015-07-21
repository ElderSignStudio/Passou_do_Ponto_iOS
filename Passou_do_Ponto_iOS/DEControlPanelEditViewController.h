//
//  DEControlPanelEditViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 10/07/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DEFotosOcorrenciaViewController.h"

@protocol DEControlPanelEditProtocol;

@interface DEControlPanelEditViewController : UIViewController <UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, DEOcorrenciaPhotoProtocol>

@property (nonatomic, weak) id<DEControlPanelEditProtocol> delegate;

@property (nonatomic) BOOL ocorrenciaENova;

@property (nonatomic, strong) DEFotosOcorrenciaViewController *fotoViewController;
@property (nonatomic, strong) NSDictionary *photos;

@property (weak, nonatomic) IBOutlet UIPickerView *tipoOcorrenciaPicker;
@property (weak, nonatomic) IBOutlet UITextField *numeroOnibusTextField;
@property (weak, nonatomic) IBOutlet UILabel *latitudeTextField;
@property (weak, nonatomic) IBOutlet UILabel *longitudeTextField;
@property (weak, nonatomic) IBOutlet UIButton *fotoButton;

@property (nonatomic, strong) NSArray *tiposDeOcorrencia;

// EDIT OCORRENCIAS
@property (nonatomic, strong) NSDictionary *ocorrenciaEditada;

// NEW OCORRENCIA
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;

// PHOTO
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSDictionary *photoMetadata;

- (void)updatePhotoButton:(NSString *)text;

@end

@protocol DEControlPanelEditProtocol <NSObject>

-(void)editCompleted:(NSDictionary *)ocorrenciaAtualizada;
-(void)imagePickerFinished:(UIImage *)photo ocorrenciaId:(NSString *)ocorrenciaId;

@end
