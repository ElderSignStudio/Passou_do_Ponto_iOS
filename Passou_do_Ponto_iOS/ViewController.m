


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

-(void)loadView
{
    [super loadView];
    
    // Populate de array of Tipo de Ocorrencias
    tipoDeOcorrencias_ = [NSArray arrayWithObjects:@"Passou do ponto", @"Atropelou o pedestre", @"Cuspiu na minha cara", @"Não abriu a porta", nil];
    
    
    // Create a GMSCameraPosition object that specifies the center and zoom level of the map.
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];

    
    //mapView_.delegate = self;
    //mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
    // Disable gestures
    mapView_.settings.scrollGestures = NO;
    mapView_.settings.zoomGestures = NO;
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
    [passouDoPontoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    passouDoPontoButton.backgroundColor = [UIColor redColor];
    
    // Button target method
    [passouDoPontoButton addTarget:self action:@selector(enviaCoordenadas) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:16];
        
        // Add a custom 'glow' marker around the current location.
        GMSMarker *currentLocationMarker = [[GMSMarker alloc] init];
        currentLocationMarker.title = @"Eu!";
        currentLocationMarker.icon = [UIImage imageNamed:@"arrow"];
        currentLocationMarker.position = location.coordinate;
        currentLocationMarker.map = mapView_;
        
    }
}

//#pragma mark - GMSMapViewDelegate
//
//- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
//
//    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
//}

-(void)enviaCoordenadas
{

//    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Enviando..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
//    NSLog(@"%@",mapView_.myLocation);
//    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    
//    [self performSegueWithIdentifier:@"presentEnviaInfo" sender:self];
    
    viewDummy_ = [[UIView alloc] initWithFrame:self.view.bounds];
    viewDummy_.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.7];
    
    popoverView_ = [[[NSBundle mainBundle] loadNibNamed:@"DETipoDaOcorrenciaView"
                                          owner:self
                                        options:nil] objectAtIndex:0];
    [popoverView_ setFrame:CGRectMake(0, 0, 275, 200)];
    
    popoverView_.center = viewDummy_.center;
    
    [viewDummy_ addSubview:popoverView_];
    
    [self.view addSubview:viewDummy_];
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

- (IBAction)enviarButtonPressed:(UIButton *)sender {
    
    NSLog(@"Enviando.");
}
- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    [popoverView_ removeFromSuperview];
    [viewDummy_ removeFromSuperview];
}

- (IBAction)fotoButtonPressed:(UIButton *)sender {
    
    NSLog(@"Foto.");
}

@end
