//
//  ViewController.h
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 29/03/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "DELoginViewController.h"
#import "DEControlPanelViewController.h"

@interface ViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DELoginProtocol, GMSMapViewDelegate>

@property (nonatomic, strong) DELoginViewController *lvc;

@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSDictionary *photoMetadata;
@property (nonatomic) BOOL userHasLoggedIn;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) CLLocationCoordinate2D userCoordinates;

@property (nonatomic, strong) NSArray *pastOccurrences;

@property (nonatomic) BOOL currentPositionWasDragged;
@property (nonatomic) CLLocationCoordinate2D draggedCurrentMarkerCoordinates;
@property (nonatomic) GMSMarker *currentLocationMarker;

@property (nonatomic, strong) NSArray *tipoDeOccorencias;

@property (nonatomic, strong) DEControlPanelViewController *cpvc;


// IBOutlets

@property (weak, nonatomic) IBOutlet UIButton *enviarButton;
@property (weak, nonatomic) IBOutlet UIPickerView *tipoDaOcorrenciaPicker;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *fotoButton;

@end

