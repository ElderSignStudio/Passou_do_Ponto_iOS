


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

static CGFloat kOverlayHeight = 100.0f;
static NSString *postUrl = @"http://passoudoponto.org/ocorrencia/insert";

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
    
    // Populate de array of Tipo de Ocorrencias
    tipoDeOcorrencias_ = [NSArray arrayWithObjects:@"Passou do ponto", @"Atropelou o pedestre", @"Cuspiu na minha cara", @"Não abriu a porta", nil];
    
    
    // Create a GMSCameraPosition object that specifies the center and zoom level of the map.
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];

    
    //mapView_.delegate = self;
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
        DELoginViewController *lvc = [[DELoginViewController alloc] initWithNibName:@"DELoginViewController" bundle:appBundle];
        lvc.delegate = self;
        [self presentViewController:lvc animated:YES completion:nil];
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
    
    [self drawUserFirstName];
    
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
        
    } else [self drawUserFirstName];
    
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
    long selectedRow = [self.tipoDaOcorrenciaPicker selectedRowInComponent:0];
    
    NSDictionary *dictionary = @{
                                 @"lat" : [[NSNumber numberWithDouble:coordinate.latitude] stringValue],
                                 @"lng" : [[NSNumber numberWithDouble:coordinate.longitude] stringValue],
                                 @"tipo" : @"2",//[[NSNumber numberWithLong:selectedRow] stringValue],
                                 @"usuario_id" : @"1",
                                 @"nr_onibus" : @"547",
                                 @"nr_ordem" : @""
                                 };
    
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // Pede pro manager fazer o Post
    [manager POST:postUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // progress bar
        [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Enviando..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        
        // Post funcionou
        
        NSError *json_error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&json_error];
        
        
        if (json_error != nil) { // Erro no Parser JSON
            
            NSData *jsonData = responseObject;
            const unsigned char *ptr = [jsonData bytes];
            
            NSMutableString *texto = [[NSMutableString alloc] initWithString:@""];
            
            for (int i=0; i<[jsonData length]; i++) {
                unsigned char c = *ptr++;
                [texto appendString:[NSString stringWithFormat:@"%c",c]];
            }
            
            NSLog(@"JSON Parser Error! Texto: %@ / Erro: %@",texto, json_error);
            
            [self showDialog:@"Communication Error" dialogType:NO];
            
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSString *status = [object objectForKey:@"status"];
                                
            if ([status isEqual: @"OK"]) {
                NSLog(@"OK Msg: %@",[object objectForKey:@"msg"]);
                
                [self showDialog:@"Enviado com sucesso!" dialogType:YES];
                
            } else if ([status isEqual: @"ERROR"]){
                NSLog(@"Server Error: %@",[object objectForKey:@"msg"]);
                
                [self showDialog:@"Server Error" dialogType:NO];
                
            }
        } else NSLog(@"JSON Parser Error, Object is not a dictionary!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Erro no POST
        
        NSLog(@"Post Request Error: %@", error);
        
        [self showDialog:@"Communication Error" dialogType:NO];
    }];

    
}

#pragma mark - "Passou do Ponto!" button Target

-(void)passouDoPontoButtonPressed
{
    
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

- (void)drawUserFirstName
{
    // Add a custom 'glow' marker around the current location.
    [mapView_ clear];
    GMSMarker *currentLocationMarker = [[GMSMarker alloc] init];
    currentLocationMarker.title = self.userName;
    currentLocationMarker.icon = [UIImage imageNamed:@"arrow"];
    currentLocationMarker.position = self.userCoordinates;
    currentLocationMarker.map = mapView_;
    
    // ABre a info windows do marker
    [mapView_ setSelectedMarker:currentLocationMarker];
}

- (void)showDialog:(NSString *)text dialogType:(BOOL)success
{
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    
    if (success) {
        [MRProgressOverlayView showOverlayAddedTo:self.view title:text mode:MRProgressOverlayViewModeCheckmark animated:NO];
    } else [MRProgressOverlayView showOverlayAddedTo:self.view title:text mode:MRProgressOverlayViewModeCross animated:NO];
    
    
}

@end
