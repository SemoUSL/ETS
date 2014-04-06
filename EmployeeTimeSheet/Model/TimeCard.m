//
//  TimeCard.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "TimeCard.h"


@implementation TimeCard

@dynamic checkIn;
@dynamic checkOut;
@dynamic comment;
@dynamic manualUpdated;
@dynamic location;



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
    timeCard.manualUpdated = [NSNumber numberWithBool: isManual];
    return timeCard;
    
}
+(BOOL)isAtWorkInContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeCard"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"checkOut = NULL"];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
    if (results.count > 0) {
        return YES;
    }
    return NO;

}
- (id)initWithContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeCard" inManagedObjectContext:context];
    self = (TimeCard*)[super initWithEntity:entity insertIntoManagedObjectContext:context];
    return self;
}
@end
