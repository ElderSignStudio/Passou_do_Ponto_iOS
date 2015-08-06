


//
//  ViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 29/03/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking.h>
#import "DELoginViewController.h"
#import "DERequestManager.h"
#import "DENotificationsCentral.h"
#import "DENotificationsCentral.h"
#import "Constants.h"

@implementation ViewController {
    GMSMapView *mapView_;
    
    UIView *overlay_;
    BOOL firstLocationUpdate_;
    UIActivityIndicatorView *activityIndicator_;
    
    NSArray *tipoDeOcorrencias_;
    
    UIView *popoverView_;
    UIView *viewDummy_;
    
    DENotificationsCentral *sharedNC_;
}

#pragma mark - Initializers

-(void)loadView
{
    //[super loadView];
    
    //Update os tipos de ocorrencia
    [self updateOcurrenceTypeFromServer];
    
    // Populate de array of Tipo de Ocorrencias
    //tipoDeOcorrencias_ = [NSArray arrayWithObjects:@"Passou do ponto", @"Atropelou o pedestre", @"Cuspiu na minha cara", @"Não abriu a porta", nil];
    
    
    // Create a GMSCameraPosition object that specifies the center and zoom level of the map.
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];

    
    mapView_.delegate = self;
    //mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
    // Disable gestures
    mapView_.settings.scrollGestures = YES;
    mapView_.settings.zoomGestures = YES;
    mapView_.settings.tiltGestures = NO;
    mapView_.settings.rotateGestures = NO;
    
    // Insets are specified in this order: top, left, bottom, right
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0, 0.0, kOverlayHeight, 0.0);
    mapView_.padding = mapInsets;
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    self.view = mapView_;
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize variables

    self.userHasLoggedIn = NO;
    self.userName = @"no_username";
    self.currentPositionWasDragged = NO;
    
    // Get pointer to the sharednotificationcentral, for error, dialogs, etc
    sharedNC_ = [DENotificationsCentral sharedNotificationCentral];
    
    // Create and configure overlay frame
    CGRect overlayFrame = CGRectMake(0, -kOverlayHeight, 0, kOverlayHeight);
    overlay_ = [[UIView alloc] initWithFrame:overlayFrame];
    overlay_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    overlay_.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.4];
    
    // Create and configure Button
    UIButton *passouDoPontoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    passouDoPontoButton.frame = CGRectMake(0.0, 0.0, 150.0, 50.0);
    [passouDoPontoButton setTitle:@"Passou do Ponto!" forState:UIControlStateNormal];
    passouDoPontoButton.titleLabel.textColor = [UIColor whiteColor];
    [passouDoPontoButton setTranslatesAutoresizingMaskIntoConstraints:NO]; // Permite usar Constraints
    passouDoPontoButton.backgroundColor = [UIColor redColor];
    
    // Button target method
    [passouDoPontoButton addTarget:self action:@selector(passouDoPontoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Create the control panel button
    UIButton *controlPanelButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    controlPanelButton.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    controlPanelButton.tintColor = [UIColor blackColor];

    // Button target method
    [controlPanelButton addTarget:self action:@selector(controlPanelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Add button to overlay and overlay to view
    [overlay_ addSubview:passouDoPontoButton];
    [overlay_ addSubview:controlPanelButton];
    [self.view addSubview:overlay_];
    
    // Buttons Constraints
    [overlay_ addConstraint:[NSLayoutConstraint constraintWithItem:passouDoPontoButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:overlay_
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [overlay_ addConstraint:[NSLayoutConstraint constraintWithItem:passouDoPontoButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:overlay_
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    [overlay_ addConstraint:[NSLayoutConstraint constraintWithItem:passouDoPontoButton
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:overlay_
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.5
                                                          constant:0.0]];
    [overlay_ addConstraint:[NSLayoutConstraint constraintWithItem:passouDoPontoButton
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:overlay_
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:0.5
                                                          constant:0.0]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.userHasLoggedIn) {
        NSBundle *appBundle = [NSBundle mainBundle];
        self.lvc = [[DELoginViewController alloc] initWithNibName:@"DELoginViewController" bundle:appBundle];
        self.lvc.delegate = self;
        [self presentViewController:self.lvc animated:YES completion:nil];
    }
    
    //NSLog(@"My Facebook Token String is: %@",[FBSDKAccessToken currentAccessToken].tokenString);
    
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    self.userCoordinates = location.coordinate;
    
    if (!firstLocationUpdate_) {
        
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:16];
        
    } else {
        //[self drawMarkers];
    }
    
}

#pragma mark - Map methods


- (void)drawMarkers
{
    [mapView_ clear];
    
    
    if (self.currentPositionWasDragged) {
        
        // Marker is where the locator was dragged to
        self.currentLocationMarker.position = self.draggedCurrentMarkerCoordinates;
    }else {
        
        // Add a custom 'glow' marker around the current location.
        self.currentLocationMarker.position = self.userCoordinates;
    }
    
    self.currentLocationMarker.map = mapView_;
    
    // Abre a info windows do marker
    //[mapView_ setSelectedMarker:self.currentLocationMarker];
    
    
    // Draw old ocorrencias markers
    
    if (self.pastOccurrences != nil) {
        
        GMSMarker *occorenciaMarker;
        
        for (NSDictionary *occurence in self.pastOccurrences) {
            
            occorenciaMarker = [[GMSMarker alloc] init];
            
            if ([[occurence objectForKey:@"lat"] class] == [NSNull class] || [[occurence objectForKey:@"lng"] class] == [NSNull class]) {
                NSLog(@"%@",occurence);
                
            } else{
                
                CLLocationCoordinate2D coord = self.userCoordinates;
                coord.latitude =  [[occurence objectForKey:@"lat"] doubleValue];
                coord.longitude = [[occurence objectForKey:@"lng"] doubleValue];
                
                occorenciaMarker.position = coord;
                
                NSInteger index = [[occurence objectForKey:@"tipo_id"] integerValue];
                NSDictionary *tipo = self.tipoDeOccorencias[index-1];
                
                occorenciaMarker.title = [tipo objectForKey:@"nome"];
                occorenciaMarker.snippet = [NSString stringWithFormat:@"%@\n%@\n%@",[occurence objectForKey:@"num_onibus"], [occurence objectForKey:@"data_hora"], [occurence objectForKey:@"nome"]];
                
                if ([[occurence objectForKey:@"usuario_id"] isEqualToString:self.userId]) {
                    occorenciaMarker.icon = [GMSMarker markerImageWithColor:[UIColor orangeColor]];
                }
                
                occorenciaMarker.map = mapView_;
            }
            
        }
    }
    
}

- (void)initializeCurrentMarkerPositions:(NSString *)username
{
    // Initialize CurrentPosition Marker
    self.currentLocationMarker = [[GMSMarker alloc] init];
    self.currentLocationMarker.title = self.userName;
    self.currentLocationMarker.icon = [UIImage imageNamed:@"arrow"];
    self.currentLocationMarker.draggable = YES;
    
    [self updatePastOcurrencesFromServer];
}

- (void)centerMapOn:(CLLocationCoordinate2D)coord
{
    [mapView_ animateToLocation:coord];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker
{}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker
{}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{
    self.currentPositionWasDragged = YES;
    self.draggedCurrentMarkerCoordinates = marker.position;
}

- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView
{
    [mapView_ animateToLocation:self.userCoordinates];
    
    if (self.currentPositionWasDragged) {
        self.currentPositionWasDragged = NO;
        
        // Create a new marker and initialize it. Only way for it to appear. SDK BUG
        self.currentLocationMarker = [[GMSMarker alloc] init];
        self.currentLocationMarker.title = self.userName;
        self.currentLocationMarker.icon = [UIImage imageNamed:@"arrow"];
        self.currentLocationMarker.draggable = YES;
        
        [self drawMarkers];
    }
    
    return YES;
}

#pragma mark - Buttons Target

-(void)passouDoPontoButtonPressed
{
    // center map on where user wants to add ocorrencia
    if (self.currentPositionWasDragged) {
        [mapView_ animateToLocation:self.draggedCurrentMarkerCoordinates];
    } else [mapView_ animateToLocation:self.userCoordinates];
    
    CLLocationCoordinate2D coordinate = mapView_.myLocation.coordinate;
    
    DEControlPanelEditViewController *editViewController = [[DEControlPanelEditViewController alloc] init];
    
    editViewController.ocorrenciaEditada = nil;
    editViewController.tiposDeOcorrencia = tipoDeOcorrencias_;
    editViewController.delegate = self;
    editViewController.ocorrenciaENova = YES;
    editViewController.userId = self.userId;
    
    
    if (self.currentPositionWasDragged) {
        
        editViewController.lat = [[NSNumber numberWithDouble:self.draggedCurrentMarkerCoordinates.latitude] stringValue];
        editViewController.lng = [[NSNumber numberWithDouble:self.draggedCurrentMarkerCoordinates.longitude] stringValue];
        
    } else {
        editViewController.lat = [[NSNumber numberWithDouble:coordinate.latitude] stringValue];
        editViewController.lng = [[NSNumber numberWithDouble:coordinate.longitude] stringValue];
    }
    
    [self presentViewController:editViewController animated:YES completion:nil];
    
}

- (void)controlPanelButtonPressed
{
    self.cpvc = [[DEControlPanelViewController alloc] init];
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM getFromServer:postGetOccurenceByCurrentUser
              caseOfSuccess:^(id responseObject, NSString *msg) {
                  
                  self.cpvc.userOcorrencias = (NSArray *)responseObject;
                  //self.cpvc.userOcorrencias = (NSArray *)[(NSDictionary *)responseObject objectForKey:@"ocorrencias"];
                  self.cpvc.tipoDeOccorencias = tipoDeOcorrencias_;
                  self.cpvc.userName = self.userName;
                  self.cpvc.delegate = self;
                  self.cpvc.userId = self.userId;
                  self.cpvc.userAvatar = self.userAvatar;
                  
                  [self presentViewController:self.cpvc animated:YES completion:nil];
              }
              caseOfFailure:^(int errorType, NSString *error) {
                  
                  [sharedNC_ showDialog:error dialogType:NO duration:2.0 viewToShow:self.view];
              }];
}

#pragma mark - DELoginProtocol Methods

- (void)loginSuccessful:(NSString *)username
{
    self.userHasLoggedIn = YES;
    self.userName = username;

    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM getFromServer:postGetUserData caseOfSuccess:^(id responseObject, NSString *msg) {
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        self.userId = [dict objectForKey:@"id"];
        
        // get avatar
        NSMutableString *url = [NSMutableString stringWithString:filenameURL];
        if ([[dict objectForKey:@"avatar"] class] != [NSNull class]) {
            [url appendString:[dict objectForKey:@"avatar"]];
            self.userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        }
        
        [self initializeCurrentMarkerPositions:username];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } caseOfFailure:^(int errorType, NSString *error) {
        
        [sharedNC_ showDialog:error dialogType:NO duration:2.0 viewToShow:self.view];
    }];
    
}

#pragma mark - DEControlPanel Procol

- (void)doneEditing
{
    [self updatePastOcurrencesFromServer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DEControlPanelEdit Procol

- (void)editCompleted:(NSDictionary *)ocorrenciaAtualizada
{
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM postToServer:postInsertUrl
                parameters:ocorrenciaAtualizada
             caseOfSuccess:^(NSString *success) {
                 
                 [self dismissViewControllerAnimated:YES completion:nil];
                 
                 // SUCCESS
                 [sharedNC_ showDialog:success dialogType:YES duration:2.0 viewToShow:self.view];
                 
                 [self updatePastOcurrencesFromServer];
                 
             }
             caseOfFailure:^(int errorType, NSString *error) {
                 
                 // FAILURE
                 
                 [sharedNC_ showDialog:error dialogType:NO duration:2.0 viewToShow:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
                 
                 if (errorType == 3) [self presentViewController:self.lvc animated:YES completion:nil];
             }];

}


- (void)updatePastOcurrencesFromServer
{
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM getFromServer:postGetAllUrl
              caseOfSuccess:^(id responseObject, NSString *msg) {
                  
                  // SUCCESS
                  
                  self.pastOccurrences = (NSArray *)responseObject;
                  NSLog(@"%@",self.pastOccurrences);
                  [self drawMarkers];
              }
              caseOfFailure:^(int errorType, NSString *error) {
                  
                  // FAILURE
                  [sharedNC_ showDialog:error dialogType:NO duration:2.0 viewToShow:self.view];
              }];
}

- (void)updateOcurrenceTypeFromServer
{
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM getFromServer:postGetOccurenceType
              caseOfSuccess:^(id responseObject, NSString *msg) {
                  
                  // SUCCESS
                  
                  //Update o tipoDeOcorrencia picker
                  self.tipoDeOccorencias = (NSArray *)responseObject;
                  
                  NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
                  for (NSDictionary *tipo in self.tipoDeOccorencias) {
                      [mutableArray addObject:[tipo objectForKey:@"nome"]];
                  }
                  
                  tipoDeOcorrencias_ = [NSArray arrayWithArray:mutableArray];

                  
              } caseOfFailure:^(int errorType, NSString *error) {
                  
                  // FAILURE
        
                  [sharedNC_ showDialog:error dialogType:NO duration:2.0 viewToShow:self.view];
    }];
    
}




@end
