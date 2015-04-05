//
//  ViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 29/03/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSDictionary *photoMetadata;

@property (nonatomic, strong) CLLocationManager *locationManager;

// IBOutlets

@property (weak, nonatomic) IBOutlet UIButton *enviarButton;
@property (weak, nonatomic) IBOutlet UIPickerView *tipoDaOcorrenciaPicker;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *fotoButton;

@end

