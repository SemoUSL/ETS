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
@dynamic syncStatus;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic objectid;



+ (Location*)findByName:(NSString*)name context:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
    if (results.count > 0) {
        return [results objectAtIndex:0];
    }
    return nil;
}
+ (Location*)findByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude context:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(abs(latitude - %f) < 0.00001) AND (abs(longitude - %f) <0.00001)",latitude,longitude];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
    if (results.count > 0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

+ (Location *)findOrBuildByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees )longitude inContext:(NSManagedObjectContext *)context
{
    if (latitude || longitude)
    {
        Location * location =[self findByLatitude:latitude longitude:longitude context:context];
        if(!location)
        {
            location = [[Location alloc] initWithContext:context];
            location.latitude = [NSNumber numberWithDouble:latitude];
            location.longitude = [NSNumber numberWithDouble:longitude];
           
        }
         return location;
    }
    return [[Location alloc] initWithContext:context];;
}
+ (NSFetchedResultsController*) getLocationsIncontext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc]initWithKey:@"name" ascending:NO]];
    NSFetchedResultsController* frc = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    NSError* error;
    [frc performFetch:&error];
    if (error) {
        NSLog(@"ERR:%@",error);
        return nil;
    }
    return frc;
    
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:context];
    self = (Location*)[super initWithEntity:entity insertIntoManagedObjectContext:context];
    return self;
}


-(double) distanceFromLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    return [[self geoLocation] distanceFromLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
}
-(CLLocation*)geoLocation
{
    return [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
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
