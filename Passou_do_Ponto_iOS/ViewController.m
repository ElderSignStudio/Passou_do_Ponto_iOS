


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
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:16];
        
    }
    
    // Add a custom 'glow' marker around the current location.
    [mapView_ clear];
    GMSMarker *currentLocationMarker = [[GMSMarker alloc] init];
    currentLocationMarker.title = self.userName;
    currentLocationMarker.icon = [UIImage imageNamed:@"arrow"];
    currentLocationMarker.position = location.coordinate;
    currentLocationMarker.map = mapView_;
    
    // ABre a info windows do marker
    [mapView_ setSelectedMarker:currentLocationMarker];
    
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
    
    NSLog(@"Enviando.");
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Enviando..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    NSLog(@"%@",mapView_.myLocation);
    
    NSLog(@"Selected row: %ld", (long)[self.tipoDaOcorrenciaPicker selectedRowInComponent:0]);
    
    if (self.photo) {
        NSLog(@"Photo = %@. Photo Metadata = %@",self.photo, self.photoMetadata);
    }
    
    [MRProgressOverlayView dismissOverlayForView:self.view animated:NO];
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Enviado com sucesso!" mode:MRProgressOverlayViewModeCheckmark animated:NO];
    //[MRProgressOverlayView showOverlayAddedTo:self.view title:@"Não foi possivel enviar!" mode:MRProgressOverlayViewModeCross animated:NO]; QUANDO NAO CONSEGUE
    
    [self performSelector:@selector(dismissOverlay) withObject:nil afterDelay:1.0];
    
    [popoverView_ removeFromSuperview];
    [viewDummy_ removeFromSuperview];

}
- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    [popoverView_ removeFromSuperview];
    [viewDummy_ removeFromSuperview];
    self.photo = nil;
    self.photoMetadata = nil;
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

- (void)postToServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"foo": @"bar"};
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"http://example.com/resources.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark - "Passou do Ponto!" button Target

-(void)passouDoPontoButtonPressed
{
    
    viewDummy_ = [[UIView alloc] initWithFrame:self.view.bounds];
    viewDummy_.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.7];
    
    popoverView_ = [[[NSBundle mainBundle] loadNibNamed:@"DETipoDaOcorrenciaView"
                                                  owner:self
                                                options:nil] objectAtIndex:0];
    [popoverView_ setFrame:CGRectMake(-200, -200, 275, 200)];
    
    
    [viewDummy_ addSubview:popoverView_];
    
    [self.view addSubview:viewDummy_];
    
    // Animating a entrada da view
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.25
          initialSpringVelocity:0.0
                        options:0
                     animations:^{
                         
        popoverView_.center = viewDummy_.center;
    }
                     completion:NULL];
    
}


- (void)dismissOverlay
{
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
}

@end
