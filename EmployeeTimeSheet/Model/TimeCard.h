//
//  TimeCard.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeCard : NSManagedObject

@property (nonatomic, retain) NSDate * checkIn;
@property (nonatomic, retain) NSDate * checkOut;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * manualUpdated;
@property (nonatomic, retain) NSManagedObject *location;

@end
