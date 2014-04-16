//
//  LocationMonitor.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 15/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import <CoreLocation/CoreLocation.h>


static NSString* const kETSLocationChangeNotification = @"kETSLocationChangeNotification";
static NSString* const KETSDidEnterRegion             = @"KETSDidEnterRegion";
static NSString* const KETSDidExitRegion             = @"KETSDidExitRegion";

@interface LocationMonitor : NSObject <CLLocationManagerDelegate>

@property (strong,nonatomic) CLLocationManager * locManager;

+(LocationMonitor*)sharedLocatoinMonitor;
@end
