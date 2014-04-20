//
//  Location.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class TimeCard;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * range;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSManagedObject *manager;
@property (nonatomic, retain) NSSet *timeCard;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addTimeCardObject:(TimeCard *)value;
- (void)removeTimeCardObject:(TimeCard *)value;
- (void)addTimeCard:(NSSet *)values;
- (void)removeTimeCard:(NSSet *)values;
+ (Location*)findByName:(NSString*)name context:(NSManagedObjectContext *)context;
+ (Location *)findOrBuildByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude inContext:(NSManagedObjectContext *)context;
+ (NSFetchedResultsController*) getLocationsIncontext:(NSManagedObjectContext*)context;
- (id)initWithContext:(NSManagedObjectContext *)context;
-(double) distanceFromLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude;
-(CLLocation*)geoLocation;


//- (void)unpackDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;



@end
