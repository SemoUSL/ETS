//
//  ETSAddLocationViewController.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "ETSAddLocationViewController.h"
#import "Location.h"
#import "TimeCard.h"
#import "Manager.h"
@interface ETSAddLocationViewController ()
{
    MKPointAnnotation * pin;
    MKCircle *circle;
    __block NSString * _address;
}

@end

@implementation ETSAddLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tfLocationName.placeholder = @"Enter Location Name";
        self.tfAddress.placeholder = @"Search for Location";
//    [self.map setMapType:MKMapTypeHybrid];
    pin = [[MKPointAnnotation alloc] init];
    circle = [[MKCircle alloc] init];
    
    UILongPressGestureRecognizer* lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0f; //user needs to press for 2 seconds
//    lpgr.delegate = self;
    [self.map addGestureRecognizer:lpgr];
    // Do any additional setup after loading the view.
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.map];
    CLLocationCoordinate2D touchMapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
    
    [self AddMapAnnotation:touchMapCoordinate];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addMapOverLay:(CLLocationCoordinate2D)point
{
    if(circle)
    {
        [self.map removeOverlay:circle];
    }
    circle=[MKCircle circleWithCenterCoordinate:point radius:self.sldRange.value];
    [self.map addOverlay:circle];
}

- (void)AddMapAnnotation:(CLLocationCoordinate2D)point
{
    //             CLLocationCoordinate2D pointt = region.center;
    
    [self addMapOverLay:point];
    pin.coordinate = point;
    pin.title = self.tfLocationName.text.length>0?self.tfLocationName.text:@"Location Name";
    pin.subtitle = [NSString stringWithFormat:@"latlon: %f  %f",pin.coordinate.latitude,pin.coordinate.longitude];
    [self.map addAnnotation:pin];
    [self reverseGeoForLatitude:point.latitude andLongitude:point.longitude];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    
    [textField resignFirstResponder];
    if ([textField isEqual:self.tfLocationName]) {
        pin.title = self.tfLocationName.text.length>0?self.tfLocationName.text:@"Location Name";
    }
    else if ([textField isEqual:self.tfAddress])
    {
        
        
        //    [self.mapView setShowsUserLocation:YES];
        NSString * address = self.tfAddress.text;
        
        //    if ([address isEqualToString:@"Ismail"]) {
        [self.map setShowsUserLocation:YES];
        //        [self reverseGeo];
        //        return YES;
        //
        //    }
        
        CLGeocoder * geocoder = [[CLGeocoder alloc]init];
        [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
         {
             CLPlacemark * placeMark = [placemarks objectAtIndex:0];
             
             CLLocationCoordinate2D point = ((CLCircularRegion*)placeMark.region).center;
             
             
             MKCoordinateRegion region;
             region.center= point;
             
             
             MKCoordinateSpan span;
             double radius = ((CLCircularRegion*)placeMark.region).radius/200;
             span.latitudeDelta = radius/112.0;
             region.span = span;
             [self.map setRegion:region animated:YES];
             
             [self AddMapAnnotation:point];
         }];
    }
    return YES;
}

//implement the viewForOverlay delegate method...
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor blueColor];
    circleView.lineWidth = 2;
    return circleView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil)
    {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = YES;
        pav.canShowCallout = YES;
    }
    else
    {
        pav.annotation = annotation;
    }
    
    return pav;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateDragging)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        pin.title = self.tfLocationName.text.length>0?self.tfLocationName.text:@"Location Name";
        pin.subtitle = [NSString stringWithFormat:@"latlon: %f  %f",droppedAt.latitude,droppedAt.longitude];
        [self addMapOverLay:droppedAt];
        //        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
}

-(void)reverseGeoForLatitude:(CLLocationDegrees) latitude andLongitude: (CLLocationDegrees)longitude
{
    // create the geocoder and location manager object.
    CLGeocoder * geoCoder = [[CLGeocoder alloc]init];
//    CLLocationManager * lm = [[CLLocationManager alloc]init];
//    lm.delegate = self;
//    lm.desiredAccuracy = kCLLocationAccuracyBest;
//    [lm startUpdatingLocation];
//    
    //get the current address.

    [geoCoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        //current address.
        CLPlacemark*placeMark =[placemarks objectAtIndex:0];

//        NSLog(@"PlaceMark Array: %@",placeMark.addressDictionary);
        
        NSString* locatedAddress = [[placeMark.addressDictionary objectForKeyedSubscript:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        _address =locatedAddress;
        //        self.tfAddress.text =locatedAddress;
        //        [self textFieldShouldReturn:self.tfAddress];
//        NSLog(@"current address is: %@",locatedAddress);
    }];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)sldRangeValueChanged:(UISlider *)sender {
    self.lblRabgeValue.text = [NSString stringWithFormat:@"%i",(int)sender.value];
}

- (IBAction)saveLocation:(UIBarButtonItem *)sender
{
    if(self.tfLocationName.text.length>0 && !(pin.coordinate.latitude == 0 && pin.coordinate.longitude ==0))
    {
        self.location = [Location findOrBuildByLatitude:0 longitude:0 inContext:self.context];
        self.location.name     = self.tfLocationName.text;
        self.location.range    = [NSNumber numberWithFloat: self.sldRange.value];
        self.location.latitude = [NSNumber numberWithDouble:pin.coordinate.latitude];
        self.location.longitude= [NSNumber numberWithDouble:pin.coordinate.longitude];
        self.location.address = _address;
        [self.delegate addLocation:self.location withSave:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
