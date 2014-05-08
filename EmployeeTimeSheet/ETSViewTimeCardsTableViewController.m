//
//  ETSViewTimeCardsTableViewController.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 06/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "ETSViewTimeCardsTableViewController.h"
#import "ETSAddTimeCardViewController.h"
#import "TimeCard.h"
#import "ETSAppDelegate.h"
//#import "SDSyncEngine.h"
#import "SDCoreDataController.h"
//#import "AFNetworkActivityIndicatorManager.h"
#import "Parse/Parse.h"

@interface ETSViewTimeCardsTableViewController ()

@property(strong,nonatomic) NSManagedObjectContext * context;
@property (strong,nonatomic)NSFetchedResultsController* fetchedResultsController;


@end

@implementation ETSViewTimeCardsTableViewController
@synthesize context;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    ETSAppDelegate *appD = [[UIApplication sharedApplication]delegate];
//    context = [appD managedObjectContext];
    context = [[SDCoreDataController sharedInstance] masterManagedObjectContext];
     NSError* error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Can not fetch Locations ERORR::::%@",error);
        exit(1);
    }
    // add gesture recognizer to the table view  to check out.
    UILongPressGestureRecognizer * lpgrCheckOut = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(checkOut:)];
    [self.tableView addGestureRecognizer:lpgrCheckOut];
    
    [self downloadLocationsFromParseAPIInBackGround];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkSyncStatus];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SDSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        //reload core data.
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }];
//    [[SDSyncEngine sharedEngine] addObserver:self forKeyPath:@"syncInProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SDSyncEngineSyncCompleted" object:nil];
//    [[SDSyncEngine sharedEngine] removeObserver:self forKeyPath:@"syncInProgress"];
}
- (void)checkSyncStatus {
//    [AFNetworkActivityIndicatorManager sharedManager].enabled =YES;
    //    if ([[SDSyncEngine sharedEngine] syncInProgress]) {
    //        [self replaceRefreshButtonWithActivityIndicator];
    //    } else {
    //        [self removeActivityIndicatorFromRefreshButton];
    //    }
}


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeCard" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checkIn" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"location.name" cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Gesture Recognizer

-(void)checkOut:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // getting the affected cell indexPath.
        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
//        UITableViewCell* activCell = [self.tableView cellForRowAtIndexPath:indexPath];
        TimeCard* activeTimeCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [activeTimeCard setCheckOutInContext:context];
        
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
    return self.fetchedResultsController.sections.count;
    
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"syncInProgress"]) {
//        [self checkSyncStatus];
//    }
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeCardCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    TimeCard* tc = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM-dd HH:mm";
//    [formatter setDateStyle:NSDateFormatterShortStyle];

    cell.textLabel.text = [NSString stringWithFormat: @"In:%@", [formatter stringFromDate:tc.checkIn]];
    if (tc.checkOut)
    {
            formatter.dateFormat = @"HH:mm";
        cell.textLabel.text =[cell.textLabel.text  stringByAppendingString: [NSString stringWithFormat: @"-Out:%@", [formatter stringFromDate:tc.checkOut]]];
                cell.backgroundColor = [UIColor lightTextColor];
    }
    else
    {
    cell.textLabel.text = [cell.textLabel.text  stringByAppendingString: @" -Out: Current"];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Comment: %@", tc.comment?tc.comment:@"No Comment!"];
}


/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    ETSAddTimeCardViewController* vc = [segue destinationViewController];
    vc.context = context;
    // Pass the selected object to the new view controller.
}
#pragma mark - Parse
-(void)downloadLocationsFromParseAPIInBackGround
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self downloadFromAPI];
    });
}
- (void)syncWithCoreData:(NSArray *)objects
{
   
    BOOL updated=NO;
    for (PFObject * tc in objects)
    {
        //check it's not in core data.
        TimeCard * timeCard= [TimeCard findOrBuildByCheckIn:tc[@"checkIn"]  InContext:context];
       
        updated=YES;
        if([tc[@"checkOut"] isKindOfClass: [NSDate class]])
            timeCard.checkOut=tc[@"checkOut"];
        timeCard.comment=tc[@"comment"];
        timeCard.manualUpdated=tc[@"manualUpdated"];
        // location
        PFObject* loc = tc[@"location"];
        Location*location= [Location findOrBuildByLatitude:[loc[@"latitude"] doubleValue] longitude:[loc[@"longitude"] doubleValue] inContext:context];

        location.name = loc[@"name"];
        location.address = loc[@"address"];
        location.range = loc[@"range"];
        
        timeCard.location = location;
    }
    if (updated) {
        // save
        [context save:nil];
    }
}

-(void)downloadFromAPI
{
    PFQuery *query = [PFQuery queryWithClassName:@"TimeCard"];
    [query whereKey:@"employee" equalTo:[PFUser currentUser]];
    [query includeKey:@"location"];

//    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self syncWithCoreData:objects];
        }
        else {
            // The network was inaccessible and we have no cached data for
            // this query.
        }
    }];
}


@end
