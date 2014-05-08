//
//  TimeCard.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//
#import "Parse/Parse.h"
#import "TimeCard.h"


@implementation TimeCard

@dynamic checkIn;
@dynamic checkOut;
@dynamic comment;
@dynamic manualUpdated;
@dynamic location;
@dynamic syncStatus;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic objectId;
@dynamic locationId;


+ (NSFetchedResultsController*) getTimeSheetIncontext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeCard"];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc]initWithKey:@"checkIn" ascending:NO]];
    // get from the 1st day in the current month.
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [gregorian dateFromComponents:comp];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"checkIn >= %@", firstDayOfMonthDate];
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController* frc = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    NSError* error;
    [frc performFetch:&error];
    if (error) {
        NSLog(@"ERR:%@",error);
        return nil;
    }
    return frc;
    
}

+ (TimeCard *)BuildByCheckIn:(NSDate*)checkInTime location:(Location*)checkInlocatoin comment:(NSString*)checkInComment manual:(BOOL)isManual inContext:(NSManagedObjectContext*) context
{
    if ([TimeCard isAtWorkInContext:context])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You Have already checked in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return nil;
    }
    TimeCard * timeCard = [[TimeCard alloc] initWithContext:context];
    timeCard.checkIn = checkInTime;
    timeCard.location = checkInlocatoin;
    timeCard.comment = checkInComment;
    timeCard.manualUpdated = @(isManual);
    timeCard.manualUpdated = [NSNumber numberWithBool: isManual];
    
    //send to Parse
    [timeCard sendToParseAPI];
    return timeCard;
    
}
+(TimeCard*)findOrBuildByCheckIn:(NSDate*)checkin InContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeCard"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"checkIn = %@",checkin];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
    if (results.count > 0) {
        return results[0];
    }
    TimeCard * timeCard = [[TimeCard alloc] initWithContext:context];
    timeCard.checkIn = checkin;
    return timeCard;
    
}
+(TimeCard*)isAtWorkInContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeCard"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"checkOut = NULL"];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
    if (results.count > 0) {
        return results[0];
    }
    return nil;

}
- (id)initWithContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeCard" inManagedObjectContext:context];
    self = (TimeCard*)[super initWithEntity:entity insertIntoManagedObjectContext:context];
//    self.context = context;
    return self;
}
#pragma mark - Check out.
-(BOOL) setCheckOutInContext:(NSManagedObjectContext*)context
{
    // validating the check in and out
    // check in must not be nil
    // check out must be nil
    BOOL valid=( self.checkIn && !self.checkOut);
    if (valid){
        //set checkout date time Now.
        self.checkOut = [NSDate date];
        
        // save
        [context save:nil];
//        NSLog(@"%@",[self ]);
        
        PFQuery *postQuery = [PFQuery queryWithClassName:@"TimeCard"];
        [postQuery whereKey:@"checkIn" equalTo: self.checkIn];
        
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count>0) {
                PFObject * card = objects[0];
                [card setObject:self.checkOut forKey:@"checkOut"];
//                [card setObject:objects[0] forKey:@"location"];
                [card saveInBackground];
                
                
            }
        }];


    }
    return valid;
}

-(void)sendToParseAPI
{
    PFObject *newTimeCard = [PFObject objectWithClassName:NSStringFromClass([self class])];
    [newTimeCard setObject:self.checkIn forKey:@"checkIn"];
    [newTimeCard setObject:self.checkOut?self.checkOut:[NSNull null] forKey:@"checkOut"];
    [newTimeCard setObject:self.comment forKey:@"comment"];
    [newTimeCard setObject:self.manualUpdated forKey:@"manualUpdated"];
    
    
    [newTimeCard setObject:[PFUser currentUser] forKey:@"employee"]; // One-to-Many relationship created here!
    
    // Set ACL permissions for added security
    PFACL *timeCardACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [timeCardACL setPublicReadAccess:YES];
    
    [newTimeCard setACL:timeCardACL];
    
    // Save new TimeCard object in Parse
//    [newTimeCard saveEventually];
    
    //location
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Location"];
    [postQuery whereKey:@"name" equalTo: ((Location*)self.location).name];
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [newTimeCard setObject:objects[0] forKey:@"location"];
            [newTimeCard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //update objectId ,createdAt, updatedAt.
//                NSLog(@"%@",newTimeCard);
            }];

            
        }
    }];
}
@end
