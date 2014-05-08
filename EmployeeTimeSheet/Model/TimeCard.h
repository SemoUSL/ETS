//
//  TimeCard.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Location.h"



@interface TimeCard : NSManagedObject

@property (nonatomic, retain) NSDate * checkIn;
@property (nonatomic, retain) NSDate * checkOut;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * locationId;



@property (nonatomic, retain) NSNumber * manualUpdated;
@property (nonatomic, retain) NSManagedObject *location;

-(void)sendToParseAPI;
+ (NSFetchedResultsController*) getTimeSheetIncontext:(NSManagedObjectContext*)context;
+(TimeCard*)findOrBuildByCheckIn:(NSDate*)checkin InContext:(NSManagedObjectContext*) context;
+ (TimeCard *)BuildByCheckIn:(NSDate*)checkInTime location:(Location*)checkInlocatoin comment:(NSString*)checkInComment manual:(BOOL)isManual inContext:(NSManagedObjectContext*) context;
+(TimeCard*)isAtWorkInContext:(NSManagedObjectContext*) context;
-(BOOL) setCheckOutInContext:(NSManagedObjectContext*)context;
@end
