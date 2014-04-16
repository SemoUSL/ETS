//
//  LocationMonitor.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 15/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "LocationMonitor.h"

@implementation LocationMonitor
#pragma mark - Shared Objec
+(LocationMonitor*)sharedLocatoinMonitor
{
    static LocationMonitor *_sharedLocationMonitor = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLocationMonitor = [[self alloc]init];
    });
    
    return _sharedLocationMonitor;
}
-(id)init
{
    self = [super init];
    if (self) {
        self.locManager = [[CLLocationManager alloc]init];
        [self.locManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locManager setDistanceFilter:10.0f];
        self.locManager.delegate = self;

    }
    return self;
}
#pragma mark - Location manager delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kETSLocationChangeNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[locations lastObject] forKey:@"location"]];

}
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KETSDidEnterRegion
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:region
                                                                                           forKey:@"region"
                                                                ]
     ];
    
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KETSDidExitRegion
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:region
                                                                                           forKey:@"region"
                                                                ]
     ];
    
}


@end
