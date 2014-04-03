//
//  ETSViewLocatinosMapViewController.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 02/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//
#import "ETSAppDelegate.h"
#import "ETSViewLocatinosMapViewController.h"

@interface ETSViewLocatinosMapViewController ()
@property(strong,nonatomic) NSManagedObjectContext * context;
@property (strong,nonatomic)NSFetchedResultsController* fetchedResultsController;

@end

@implementation ETSViewLocatinosMapViewController
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
        //add the fetched locations to the map.
        for (Location* loc in self.fetchedResultsController.fetchedObjects) {
            [self addMapAnnotationForLocation:loc];
        }
    }
    // Do any additional setup after loading the view.
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



-(void)addMapAnnotationForLocation:(Location*)location
{
    {
//        [[CLLocationDegrees alloc]init]
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake((CLLocationDegrees)[location.latitude doubleValue], (CLLocationDegrees)[location.longitude doubleValue]);
        
        [self addMapOverLay:point radius:[location.range integerValue]];
        MKPointAnnotation * pin = [[MKPointAnnotation alloc]init];
        pin.coordinate = point;
        pin.title = location.name;
        pin.subtitle = location.address;
        [self.map addAnnotation:pin];

    }

    
}

- (void)addMapOverLay:(CLLocationCoordinate2D)point radius:(NSInteger) radius
{
    
    MKCircle *circle=[MKCircle circleWithCenterCoordinate:point radius:radius];
    [self.map addOverlay:circle];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
-(void)addLocation:(Location *)location withSave:(BOOL)save
{
    NSError *error;
    if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(1);
    }

}
@end
