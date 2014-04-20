//
//  ETSViewLocatinosMapViewController.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 02/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//
#import "ETSAppDelegate.h"
#import "ETSViewLocatinosMapViewController.h"
#import "LocationMonitor.h"
#import "TimeCard.h"

#define CHECK_IN_ALERT_TITLE @"Check-In?"
#define CHECK_OUT_ALERT_TITLE @"Check-Out?"
@interface ETSViewLocatinosMapViewController ()
@property(strong,nonatomic) NSManagedObjectContext * context;
@property (strong,nonatomic)NSFetchedResultsController* fetchedResultsController;
@property (strong,nonatomic) CLLocationManager * locationManager;
@property (strong,nonatomic) NSString* currentLocationStatus;
@property (strong,nonatomic) Location* currentRegionLocation;

@end

static NSString* KETSInsideRegion = @"KETSInsideRegion";
static NSString* KETSOutsideRegion = @"KETSOutsideRegion";
static NSString* KETSDidEnterRegionWithoutCheckIn = @"KETSDidEnterRegionWithoutCheckIn";
static NSString* KETSDidExitRegionWithoutCheckOut = @"KETSDidExitRegionWithoutCheckOut";

@implementation ETSViewLocatinosMapViewController
{
    MKPointAnnotation * userAnnotation;
}
@synthesize context;//,locationManager;

#pragma mark - view controller
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
    userAnnotation = [[MKPointAnnotation alloc]init];
    ETSAppDelegate *appD = [[UIApplication sharedApplication]delegate];
    context = [appD managedObjectContext];
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Can not fetch Locations ERORR::::%@",error);
        exit(1);
    }
    else
    {
        //remove monitored region and add it agian. to make sure that all of them added.
        NSArray*regions = [[self.locationManager monitoredRegions] allObjects];
        for (CLCircularRegion* region in regions) {
            [self.locationManager stopMonitoringForRegion:region];
        }
        //add the fetched locations to the map.
        for (Location* loc in self.fetchedResultsController.fetchedObjects) {
            [self addMapAnnotationForLocation:loc];
        }
    }
    self.tabBarController.delegate =self;
    
//    // locationManager
//    self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    [self.locationManager startUpdatingLocation];
    
    // observe locatoin updated
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kETSLocationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterRegion:) name:KETSDidEnterRegion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitRegion:) name:KETSDidExitRegion object:nil];
    
//    if(self.locationManager.location)
    {
        MKCoordinateRegion region = { { 0.0f, 0.0f }, { 0.0f, 0.0f } };
        region.center = self.map.userLocation.coordinate;
        region.span.longitudeDelta = 0.15f;
        region.span.latitudeDelta = 0.15f;
        [self.map setRegion:region animated:YES];
    }
    
    
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - fetchedResultsController
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
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self addMapAnnotationForLocation:[self.fetchedResultsController objectAtIndexPath:newIndexPath]];
            break;
            
            //        case NSFetchedResultsChangeDelete:
            //            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //            break;
            //
            //        case NSFetchedResultsChangeUpdate:
            //            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            //            break;
            //
            //        case NSFetchedResultsChangeMove:
            //            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //            break;
    }
}


#pragma mark - map view

-(void)addMapAnnotationForLocation:(Location*)location{
    
    [self registerRegionForLocation:location];
    
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
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

//implement the viewForOverlay delegate method...
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor blueColor];
    circleView.lineWidth = 2;
    
    return circleView;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    mapView.centerCoordinate = userLocation.coordinate;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // get the destination view controller.
    ETSAddLocationViewController * addViewController = segue.destinationViewController;
    
    //set self to its delegate.
    addViewController.delegate = self;
    
    if ([[segue identifier] isEqualToString:@"AddLocation"]) {
        // create a new location and pass it to Addviewcontroller.
        addViewController.context  = self.fetchedResultsController.managedObjectContext;
        
    }
}

#pragma mark - Location delegate
-(void)addLocation:(Location *)location withSave:(BOOL)save{
    NSError *error;
    if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(1);
    }
    [self registerRegionForLocation:location];
    
}
#pragma mark - Regions
-(void) registerRegionForLocation:(Location*)location{
    CLLocationDegrees radius = [location.range doubleValue];
    if (radius > self.locationManager.maximumRegionMonitoringDistance) {
        radius = self.locationManager.maximumRegionMonitoringDistance;
    }
    if (radius < 100.0) {
        radius = 100.0;
    }
    // Create the geographic region to be monitored.
    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                   initWithCenter: CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue])
                                   radius:radius
                                   identifier:location.name];
    [self.locationManager startMonitoringForRegion:geoRegion];
}
#pragma mark - Tab Bar Controller handlers
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController.tabBarItem.title isEqualToString:@"TimeSheet"])
    {
        //check if there is no locatoins don't open the timesheet view controller.
        if( self.fetchedResultsController.fetchedObjects.count==0)
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert"
                                                            message:@"You need first to add at least one location!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Add Location", nil];
            [alert show];
            return NO;
        }
        
    }
    return YES;
}

#pragma mark Alet view handler
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
    if([alertView.title isEqualToString:@"Alert"])
    {
        
        if([title isEqualToString:@"Add Location"]&&![self.navigationController.visibleViewController isKindOfClass:[ETSAddLocationViewController class]] )
        {
            ETSAddLocationViewController  *addViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ETSAddLocationViewController"];
            addViewController.delegate = self;
            
            
            // create a new location and pass it to Addviewcontroller.
            addViewController.context  = self.fetchedResultsController.managedObjectContext;
            
            
            [self.navigationController pushViewController:addViewController animated:YES];
        }
    }
    else if([alertView.title isEqualToString:CHECK_IN_ALERT_TITLE])
    {
        if([title isEqualToString:@"Check-In"])
        {
            //check in.
            //create a new time card entity and fill it with.current time . region location, auto, unpaid,comment = auto.
            TimeCard* newTimeCard = [TimeCard BuildByCheckIn:[NSDate date]
                                                    location:self.currentRegionLocation
                                                     comment:@"Checked-in automatically."
                                                      manual:NO
                                                   inContext:context
                                     ];
            if(newTimeCard)
            {
                NSError * error;
                [context save:&error];
                if (error)
                {
                    NSLog(@"ERR:%@",error);
                }
                
            }
            
        }
        //stop updating location.
        self.currentLocationStatus =KETSInsideRegion;
        [self.locationManager stopUpdatingLocation];
    }
    else if([alertView.title isEqualToString:CHECK_OUT_ALERT_TITLE])
    {
        if([title isEqualToString:@"Check-Out"])
        {
            //check out.
            //find the Open time card and make sure it is belong to the current location.
            TimeCard* openTimeCard = [TimeCard isAtWorkInContext:self.context];
            if(openTimeCard)
            {
                [openTimeCard setCheckOutInContext:self.context];
                NSError * error;
                [context save:&error];
                if (error)
                {
                    NSLog(@"ERR:%@",error);
                }
                
            }
            
        }
        //stop updating location.
        self.currentLocationStatus =KETSInsideRegion;
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)sendAlertOrNotificationForCheck:(NSString*)in_out
{
    // became inside the range .. Lets Tell him to check int.
    if ([self isInBackGround])
    {
        //send notificatoin
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        
        if (localNotif != nil)
        {
            localNotif.fireDate = [NSDate date];
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            localNotif.alertBody =[NSString stringWithFormat:@"You Are Now inside the %@ range.\nPlease,Remmeber to Check-%@.",self.currentRegionLocation.name,in_out];
            
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.alertAction = [NSString stringWithFormat: @"Check%@",in_out];
            localNotif.alertAction = @"Cancel";
            
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        }
        
    }
//    else // Active
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[in_out isEqualToString:@"In"]?CHECK_IN_ALERT_TITLE:CHECK_OUT_ALERT_TITLE
                                                        message:[NSString stringWithFormat:@"You Are Now inside the %@ range.\nPlease,Remmeber to Check-%@.",self.currentRegionLocation.name,in_out]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles: [NSString stringWithFormat:@"Check-%@",in_out],nil];
        [alert show];
    }
    self.currentLocationStatus= nil;
}

#pragma mark - Location manager
- (void)locationDidChange:(NSNotification *)note
{
    CLLocation *newLocation = [note.userInfo[@"locations"] lastObject];
    
    if ([self.currentLocationStatus isEqualToString:KETSDidEnterRegionWithoutCheckIn])
    {
        // Now employee comming to work location.
        if (self.currentRegionLocation)
        {
            // I need to sign him in when the the distance become < range.
            
            CLLocationDistance currentDistance = [newLocation distanceFromLocation:[self.currentRegionLocation geoLocation]];
            
            if(currentDistance < [self.currentRegionLocation.range doubleValue])
            {
                [self sendAlertOrNotificationForCheck:@"In"];
                
                
            }
            
            
            
        }
        
    }
    
    
    
    
    self.map.centerCoordinate = newLocation.coordinate;
    
    
//    CLLocationCoordinate2D point =self.locationManager.location.coordinate;
//    
//    [self addMapOverLay:point radius:[self.locationManager.location distanceFromLocation: [[self nearestLocation] geoLocation]]];
////    userAnnotation = [[MKPointAnnotation alloc]init];
//    userAnnotation.coordinate = point;
//    userAnnotation.title = [self nearestLocation].name;
//    userAnnotation.subtitle = [@([self.locationManager.location distanceFromLocation: [[self nearestLocation] geoLocation]]) stringValue] ;
//    [self.map addAnnotation:userAnnotation];
//    
   
    
}
-(Location*)nearestLocation
{
    NSArray * locations = [self.fetchedResultsController.fetchedObjects sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
        CLLocation * loc1 = [[CLLocation alloc]initWithLatitude: [((Location*)obj1).latitude doubleValue] longitude:[((Location*)obj1).longitude doubleValue]];
        CLLocation * loc2 = [[CLLocation alloc]initWithLatitude: [((Location*)obj2).latitude doubleValue] longitude:[((Location*)obj2).longitude doubleValue]];
        if([self.locationManager.location distanceFromLocation:loc1] < [self.locationManager.location distanceFromLocation:loc2])
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedDescending;
        }
    }];
    return locations[0];
}
- (void)didEnterRegion:(NSNotification *)note
{
    CLCircularRegion *region = note.userInfo[@"region"];
    self.currentRegionLocation =[Location findByName:region.identifier context:context];
    //    if(self.currentRegionLocation && self.locationManager.location)
    //    {
    //        CLLocationDistance currentDistance = [[self.currentRegionLocation geoLocation] distanceFromLocation:self.locationManager.location];
    
    if([self.currentRegionLocation.range integerValue]>=100)//currentDistance < [self.currentRegionLocation.range doubleValue])
    {
        [self sendAlertOrNotificationForCheck:@"In"];
    }
    else
    {
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager startUpdatingLocation];
        self.currentLocationStatus = KETSDidEnterRegionWithoutCheckIn;
    }
    
    //    NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
    
    //     UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:event delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //        [alert show];
    
}


- (void)didExitRegion:(NSNotification *)note
{
    if ([TimeCard isAtWorkInContext:self.context]) {
        self.currentLocationStatus = KETSOutsideRegion;
    }
    else{
        self.currentLocationStatus = KETSDidExitRegionWithoutCheckOut;
    }
    
    CLCircularRegion *region = note.userInfo[@"region"];
    self.currentRegionLocation =[Location findByName:region.identifier context:context];
    TimeCard * currentTimeCard = [TimeCard isAtWorkInContext:context];
    if(currentTimeCard && [currentTimeCard.location isEqual:self.currentRegionLocation] )
        [self sendAlertOrNotificationForCheck:@"Out"];
    //    CLRegion* region = note.userInfo[@"region"];
    //    NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
    //    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:event delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //    [alert show];
    //    [self updateWithEvent:event];
}

-(CLLocationManager*)locationManager{
    return [LocationMonitor sharedLocatoinMonitor].locManager;
}


#pragma mark - Applicatoin Status
-(BOOL)isInBackGround
{
    return [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground;
}

@end
