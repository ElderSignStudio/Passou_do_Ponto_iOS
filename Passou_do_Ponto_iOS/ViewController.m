


//
//  ViewController.m
//  Passou_do_Ponto_iOS
//
//  Created by Dan Eisenberg on 29/03/15.
//  Copyright (c) 2015 Elder Sign Studio. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

static CGFloat kOverlayHeight = 100.0f;

@implementation ViewController {
    GMSMapView *mapView_;
    UIView *overlay_;
    BOOL firstLocationUpdate_;
    UIActivityIndicatorView *activityIndicator_;
}

-(void)loadView
{
    [super loadView];
    
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
    
    // Button delegate method
    [passouDoPontoButton addTarget:self action:@selector(passouDoPontoPressed) forControlEvents:UIControlEventTouchUpInside];
    
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

-(void)passouDoPontoPressed
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirma"
                                                                   message:@"Confirma a passada de ponto?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Passou!" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self enviaCoordenadas];
                                                          }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ops" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)enviaCoordenadas
{
    self.view.alpha = 0.5;
    
    CGRect b = self.view.bounds;
    activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                 UIActivityIndicatorViewStyleWhiteLarge];
    //center the indicator in the view
    activityIndicator_.frame = CGRectMake((b.size.width - 20) / 2, (b.size.height - 20) / 2, 20, 20);
    //activityIndicator_.frame = CGRectMake(0,0,100,100);
    [self.view addSubview:activityIndicator_];
    [activityIndicator_ startAnimating];
    

    
}

@end
