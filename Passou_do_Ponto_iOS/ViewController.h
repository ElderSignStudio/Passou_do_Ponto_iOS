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

@interface ViewController : UIViewController <DEControlPanelEditProtocol, DEControlPanelProtocol, DELoginProtocol, GMSMapViewDelegate>

@property (nonatomic, strong) DELoginViewController *lvc;

@property (nonatomic) BOOL userHasLoggedIn;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic , strong) UIImage *userAvatar;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userCoordinates;

@property (nonatomic) BOOL currentPositionWasDragged;
@property (nonatomic) CLLocationCoordinate2D draggedCurrentMarkerCoordinates;
@property (nonatomic) GMSMarker *currentLocationMarker;

@property (nonatomic, strong) NSArray *pastOccurrences;
@property (nonatomic, strong) NSArray *tipoDeOccorencias;

@property (nonatomic, strong) DEControlPanelViewController *cpvc;


@end

