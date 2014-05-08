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
//#import "SDSyncEngine.h"
@interface ETSAddLocationViewController ()
{
    MKPointAnnotation * newPin;
    MKCircle *newCircle;
    __block NSString * _address;
}
@property(strong,nonatomic) NSFetchedResultsController * fetchedResultsController;
@end

@implementation ETSAddLocationViewController
@synthesize context;

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
    //3D Maps
    self.map.delegate = self;
    self.map.centerCoordinate = CLLocationCoordinate2DMake(37.78275123, -122.40416442);
    self.map.camera.altitude = 200;
    self.map.camera.pitch = 70;
    self.map.showsBuildings = YES;
    

//    [self.map setMapType:MKMapTypeHybrid];
    newPin = [[MKPointAnnotation alloc] init];
    newCircle = [[MKCircle alloc] init];
    
    UILongPressGestureRecognizer* lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0f; //user needs to press for 2 seconds
//    lpgr.delegate = self;
    [self.map addGestureRecognizer:lpgr];

    //load saved locations.
    NSError * error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Can not fetch Locations ERORR::::%@",error);
        exit(1);
    }
    else
    {
       
        //add the fetched locations to the map.
        for (Location* loc in self.fetchedResultsController.fetchedObjects) {
            [self addMapAnnotationForLocation:loc];
        }
    }
    
}
-(void)addMapAnnotationForLocation:(Location*)location{
    
    
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake((CLLocationDegrees)[location.latitude doubleValue], (CLLocationDegrees)[location.longitude doubleValue]);
    
    
    [self addMapOverLay:point radius:[location.range integerValue]];
    MKPointAnnotation * pin = [[MKPointAnnotation alloc]init];
    pin.coordinate = point;
    pin.title = location.name;
    pin.subtitle = location.address;
    [self.map addAnnotation:pin];
    
    
    
}
- (void)addMapOverLay:(CLLocationCoordinate2D)point radius:(NSInteger) radius{
    MKCircle *circle=[ MKCircle circleWithCenterCoordinate:point radius:radius];
    [self.map addOverlay:circle];
    [self.map reloadInputViews];
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
    [self.map addOverlay:newCircle?newCircle:[MKCircle circleWithCenterCoordinate:point radius:self.sldRange.value]];
    [self.map reloadInputViews];
}

- (void)AddMapAnnotation:(CLLocationCoordinate2D)point
{
    //             CLLocationCoordinate2D pointt = region.center;
    
    [self addMapOverLay:point];
    newPin.coordinate = point;
    newPin.title = self.tfLocationName.text.length>0?self.tfLocationName.text:@"Location Name";
    newPin.subtitle = [NSString stringWithFormat:@"latlon: %f  %f",newPin.coordinate.latitude,newPin.coordinate.longitude];
    [self.map addAnnotation:newPin];
    [self reverseGeoForLatitude:point.latitude andLongitude:point.longitude];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    
    [textField resignFirstResponder];
    if ([textField isEqual:self.tfLocationName]) {
        newPin.title = self.tfLocationName.text.length>0?self.tfLocationName.text:@"Location Name";
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
             
             [self.map setCenterCoordinate:point animated:YES];
//             MKCoordinateSpan span;
//             double radius = ((CLCircularRegion*)placeMark.region).radius/200;
//             span.latitudeDelta = radius/112.0;
//             region.span = span;
//             [self.map setRegion:region animated:YES];
             
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
        pav.draggable = NO;
        pav.canShowCallout = YES;
    }
    else
    {
        pav.annotation = annotation;
    }
    
    return pav;
}

//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
//{
//    if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateDragging)
//    {
//        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
//        newPin.title = self.tfLocationName.text.length>0?self.tfLocationName.text:@"Location Name";
//        newPin.subtitle = [NSString stringWithFormat:@"latlon: %f  %f",droppedAt.latitude,droppedAt.longitude];
//        [self addMapOverLay:droppedAt];
//        //        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
//    }
//}

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
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
//    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


- (IBAction)sldRangeValueChanged:(UISlider *)sender {
    self.lblRabgeValue.text = [NSString stringWithFormat:@"%i",(int)sender.value];
}

- (IBAction)saveLocation:(UIBarButtonItem *)sender
{
    NSString* message =@"";
    if (self.tfLocationName.text.length== 0) {
        message = [message stringByAppendingString:@"Please Enter Location Name!.\n"];
    }
    if(newPin.coordinate.latitude == 0 && newPin.coordinate.longitude ==0)
    {
         message = [message stringByAppendingString:@"Please Long Press on Map to Set Location Coordinates!.\n"];
    }
    if (message.length>0) {
         UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
        self.location = [Location findOrBuildByLatitude:0 longitude:0 inContext:self.context];
        self.location.name     = self.tfLocationName.text;
        self.location.range    = [NSNumber numberWithFloat: self.sldRange.value];
        self.location.latitude = [NSNumber numberWithDouble:newPin.coordinate.latitude];
        self.location.longitude= [NSNumber numberWithDouble:newPin.coordinate.longitude];
        self.location.address = _address;
//        self.location.syncStatus = @(SDObjectCreated);
        // add to parse
        [self.location sendToParseAPI];
        [self.delegate addLocation:self.location withSave:YES];
        [self.navigationController popViewControllerAnimated:YES];
    
}
@end
