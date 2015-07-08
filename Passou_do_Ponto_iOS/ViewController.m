


//
//  ViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 29/03/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MRProgress.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking.h>
#import "DELoginViewController.h"
#import "DERequestManager.h"
#import "DENotificationsCentral.h"

static CGFloat kOverlayHeight = 100.0f;
static NSString *postInsertUrl = @"http://passoudoponto.org/ocorrencia/insert";
static NSString *postGetAllUrl = @"http://passoudoponto.org/ocorrencia/get_all";
static NSString *postGetOccurenceType = @"http://passoudoponto.org/ocorrencia/ref_get_tipos";
static NSString *postGetOccurenceByCurrentUser = @"http://passoudoponto.org/usuario/ocorrencias";

@implementation ViewController {
    GMSMapView *mapView_;
    
    UIView *overlay_;
    BOOL firstLocationUpdate_;
    UIActivityIndicatorView *activityIndicator_;
    
    NSArray *tipoDeOcorrencias_;
    
    UIView *popoverView_;
    UIView *viewDummy_;
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
    self.photo = nil;
    self.photoMetadata = nil;
    self.userHasLoggedIn = NO;
    self.userName = @"no_username";
    self.currentPositionWasDragged = NO;
    
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
    
    // Add button to overlay and overlay to view
    [overlay_ addSubview:passouDoPontoButton];
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
    
    
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - DELoginProtocol Methods

- (void)loginSuccessful:(NSString *)username
{
    self.userHasLoggedIn = YES;
    self.userName = username;
    
    // Initialize CurrentPosition Marker
    self.currentLocationMarker = [[GMSMarker alloc] init];
    self.currentLocationMarker.title = self.userName;
    self.currentLocationMarker.icon = [UIImage imageNamed:@"arrow"];
    self.currentLocationMarker.draggable = YES;
    
    [self updatePastOcurrencesFromServer];
    
    [self testaSession];
    
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
        [self drawMarkers];
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
    
    //NSLog(@"My coord is Lat: %f Long: %f", self.userCoordinates.latitude, self.userCoordinates.longitude);
    
    // Abre a info windows do marker
    //[mapView_ setSelectedMarker:self.currentLocationMarker];
    
    
    // Draw old ocorrencias markers
    
    if (self.pastOccurrences != nil) {
        
        GMSMarker *occorenciaMarker;
        
        for (NSDictionary *occurence in self.pastOccurrences) {
            
            occorenciaMarker = [[GMSMarker alloc] init];
            
            CLLocationCoordinate2D coord = self.userCoordinates;
            coord.latitude =  [[occurence objectForKey:@"lat"] doubleValue];
            coord.longitude = [[occurence objectForKey:@"lng"] doubleValue];
            
            //NSLog(@"Plotting id=%@ Lat: %f Long: %f", [occurence objectForKey:@"id"], coord.latitude, coord.longitude);
            
            occorenciaMarker.position = coord;
            
            NSInteger index = [[occurence objectForKey:@"tipo_id"] integerValue];
            NSDictionary *tipo = self.tipoDeOccorencias[index-1];
            
            occorenciaMarker.title = [tipo objectForKey:@"nome"];
            occorenciaMarker.snippet = [NSString stringWithFormat:@"%@\n%@\n%@",[occurence objectForKey:@"num_onibus"], [occurence objectForKey:@"data_hora"], [occurence objectForKey:@"nome"]];
            occorenciaMarker.map = mapView_;
            
        }
    }
    
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

#pragma mark - UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [tipoDeOcorrencias_ count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return tipoDeOcorrencias_[row];
}

#pragma mark - UIButton target methods

- (IBAction)enviarButtonPressed:(UIButton *)sender {
    
    // fecha janela
    [self performSelector:@selector(dismissOverlay) withObject:nil afterDelay:1.0];
    
    [popoverView_ removeFromSuperview];
    [viewDummy_ removeFromSuperview];
    
    // monta NSDictionary

    CLLocationCoordinate2D coordinate = mapView_.myLocation.coordinate;
    long selectedRow = [self.tipoDaOcorrenciaPicker selectedRowInComponent:0] + 1;
    
    NSDictionary *dictionary;
    
    if (self.currentPositionWasDragged) {
         dictionary = @{
                                     @"lat" : [[NSNumber numberWithDouble:self.draggedCurrentMarkerCoordinates.latitude] stringValue],
                                     @"lng" : [[NSNumber numberWithDouble:self.draggedCurrentMarkerCoordinates.longitude] stringValue],
                                     @"tipo" : [[NSNumber numberWithLong:selectedRow] stringValue],
                                     @"usuario_id" : @"1",
                                     @"nr_onibus" : @"547",
                                     @"nr_ordem" : @""
                                     };
    }else {
    
        dictionary = @{
                                 @"lat" : [[NSNumber numberWithDouble:coordinate.latitude] stringValue],
                                 @"lng" : [[NSNumber numberWithDouble:coordinate.longitude] stringValue],
                                 @"tipo" : [[NSNumber numberWithLong:selectedRow] stringValue],
                                 @"usuario_id" : @"1",
                                 @"nr_onibus" : @"547",
                                 @"nr_ordem" : @""
                                 };
    }
    
//    
//    if (self.photo) {
//        NSLog(@"Photo = %@. Photo Metadata = %@",self.photo, self.photoMetadata);
//    }
    
    //envia
    [self postToServer:dictionary];

}
- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:0
                     animations:^{
        
        [popoverView_ setFrame:CGRectMake(50, -200, 275, 200)];
        viewDummy_.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.0];

    }
                     completion:^(BOOL finished) {
        
        [popoverView_ removeFromSuperview];
        [viewDummy_ removeFromSuperview];
        self.photo = nil;
        self.photoMetadata = nil;
        
    }];
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

#pragma mark - Camera

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]) { // se veio um VIDEO
        NSURL *urlOfVideo = info[UIImagePickerControllerMediaURL];
        NSLog(@"Video URL = %@",urlOfVideo);
        
    } else if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]){ // se veio uma IMAGEM
        // get the metadata
        
        self.photoMetadata = info[UIImagePickerControllerMediaMetadata];
        self.photo = info[UIImagePickerControllerOriginalImage];
        
        self.fotoButton.titleLabel.text = @"OK!";
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

#pragma mark - AFNetwork methods

- (void)postToServer:(NSDictionary *)parameters
{
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Enviando..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM postToServer:postInsertUrl
                parameters:parameters
             caseOfSuccess:^(NSString *success) {
                 
                 // SUCCESS
                 
                 [self showDialog:@"Enviado com sucesso!" dialogType:YES];
                 
                 [self updatePastOcurrencesFromServer];
                 
             }
             caseOfFailure:^(int errorType, NSString *error) {
                 
                 // FAILURE
                 
                 switch (errorType) {
                     case 1:
                         [self showDialog:@"Communication Error" dialogType:NO];
                         break;
                    
                     case 2:
                         [self showDialog:@"Authorization Denied" dialogType:NO];
                         break;
                         
                     case 3:
                         [self showDialog:@"You need to be logged in" dialogType:NO];
                         [self presentViewController:self.lvc animated:YES completion:nil];
                         break;
                         
                     default:
                         [self showDialog:@"Unknown Error" dialogType:NO];
                         break;
                 }
                 
             }];
    
}

- (void)updatePastOcurrencesFromServer
{
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    [sharedRM getFromServer:postGetAllUrl
              expectedClass:[NSArray class]
              caseOfSuccess:^(id responseObject) {
                  
                  // SUCCESS
                  
                  self.pastOccurrences = (NSArray *)responseObject;
                  
                  [self drawMarkers];
                  
                  [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
              }
              caseOfFailure:^(NSString *error) {
                  
                  // FAILURE
                  [self showDialog:@"Communication Error" dialogType:NO];
              }];
}

- (void)updateOcurrenceTypeFromServer
{
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM getFromServer:postGetOccurenceType
              expectedClass:[NSArray class]
              caseOfSuccess:^(id responseObject) {
                  
                  // SUCCESS
                  
                  //Update o tipoDeOcorrencia picker
                  self.tipoDeOccorencias = (NSArray *)responseObject;
                  
                  NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
                  for (NSDictionary *tipo in self.tipoDeOccorencias) {
                      [mutableArray addObject:[tipo objectForKey:@"nome"]];
                  }
                  
                  tipoDeOcorrencias_ = [NSArray arrayWithArray:mutableArray];

                  
              } caseOfFailure:^(NSString *error) {
                  
                  // FAILURE
        
                  [self showDialog:@"Communication Error" dialogType:NO];
    }];
    
}

- (void)testaSession
{
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM postToServer:@"http://passoudoponto.org/usuario/test_login/1"
                parameters:nil
             caseOfSuccess:^(NSString *success) {
                 
                 [self getOccurencesByCurrentUser];
             }
             caseOfFailure:^(int errorType, NSString *error) {
                 switch (errorType) {
                     case 1:
                         [self showDialog:error dialogType:NO];
                         break;
                         
                     case 2:
                         [self showDialog:@"Authorization Denied" dialogType:NO];
                         break;
                         
                     case 3:
                         [self showDialog:@"You need to be logged in" dialogType:NO];
                         [self presentViewController:self.lvc animated:YES completion:nil];
                         break;
                         
                     default:
                         [self showDialog:@"Unknown Error" dialogType:NO];
                         break;
                 }
                 
                 [self getOccurencesByCurrentUser];

             }];
    
}


- (void)getOccurencesByCurrentUser
{
    
    DERequestManager *sharedRM = [DERequestManager sharedRequestManager];
    
    [sharedRM getFromServer:postGetOccurenceByCurrentUser
              expectedClass:[NSDictionary class]
              caseOfSuccess:^(id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  NSLog(@"%@",dict);
              }
              caseOfFailure:^(NSString *error) {
                  [self showDialog:error dialogType:NO];
              }];
}


#pragma mark - "Passou do Ponto!" button Target

-(void)passouDoPontoButtonPressed
{
    // center map on where user wants to add ocorrencia
    if (self.currentPositionWasDragged) {
        [mapView_ animateToLocation:self.draggedCurrentMarkerCoordinates];
    } else [mapView_ animateToLocation:self.userCoordinates];
    
    viewDummy_ = [[UIView alloc] initWithFrame:self.view.bounds];
    viewDummy_.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.0];
    
    popoverView_ = [[[NSBundle mainBundle] loadNibNamed:@"DETipoDaOcorrenciaView"
                                                  owner:self
                                                options:nil] objectAtIndex:0];
    [popoverView_ setFrame:CGRectMake(50, -200, 275, 200)];
    
    
    [viewDummy_ addSubview:popoverView_];
    
    [self.view addSubview:viewDummy_];
    
    // Animating a entrada da view
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        popoverView_.center = viewDummy_.center;
        viewDummy_.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.7];
    } completion:NULL];
    
    
}


- (void)dismissOverlay
{
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
}


#pragma mark - Helper Methods

- (void)showDialog:(NSString *)text dialogType:(BOOL)success
{
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    
    if (success) {
        [MRProgressOverlayView showOverlayAddedTo:self.view title:text mode:MRProgressOverlayViewModeCheckmark animated:NO];
    } else [MRProgressOverlayView showOverlayAddedTo:self.view title:text mode:MRProgressOverlayViewModeCross animated:NO];
    
    
}

- (void)printServerCommunicationMessage:(NSData *)data
{
    const unsigned char *ptr = [data bytes];
    
    NSMutableString *texto = [[NSMutableString alloc] initWithString:@""];
    
    for (int i=0; i<[data length]; i++) {
        unsigned char c = *ptr++;
        [texto appendString:[NSString stringWithFormat:@"%c",c]];
    }
    
    NSLog(@"Texto: %@",texto);

}

- (void)waitSecondsAndExecute:(void (^)(void))block delayTime:(double)seconds
{
    double delayInSeconds = seconds;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        block();
    });
}


@end
