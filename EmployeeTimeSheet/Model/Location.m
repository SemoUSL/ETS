//
//  Location.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "Location.h"
#import "TimeCard.h"


@implementation Location

@dynamic name;
@dynamic range;
@dynamic address;
@dynamic latitude;
@dynamic longitude;
@dynamic manager;
@dynamic timeCard;



+ (Location *)findOrBuildByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees )longitude inContext:(NSManagedObjectContext *)context
{
    if (latitude || longitude) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
        fetchRequest.fetchLimit = 1;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"latitude = %@ AND logitude = %@",latitude,longitude];
        
        NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
        
        if (results.count > 0) {
            return [results objectAtIndex:0];
        }
    }
    Location * location = [[Location alloc] initWithContext:context];
    location.latitude = [NSNumber numberWithDouble:latitude];
    location.longitude = [NSNumber numberWithDouble:longitude];
    return location;
    
}
- (id)initWithContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:context];
    self = (Location*)[super initWithEntity:entity insertIntoManagedObjectContext:context];
    return self;
}

//- (void)unpackDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context
//{
//    NSString *itemId       = [[dictionary objectForKey:@"id"] stringValue];
//    NSString *itemName     = [dictionary objectForKey:@"name"];
//    NSString *categoryName = [dictionary objectForKey:@"category"];
//    
//    
//    self.remote_id   = [NSNumber numberWithInteger:  [itemId integerValue]];
//    self.name     = itemName;
//    self.category = categoryName;
//}

@end
