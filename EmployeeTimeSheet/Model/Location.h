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

+ (Location *)findOrBuildByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude inContext:(NSManagedObjectContext *)longitude;
- (id)initWithContext:(NSManagedObjectContext *)context;
//- (void)unpackDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;



@end
