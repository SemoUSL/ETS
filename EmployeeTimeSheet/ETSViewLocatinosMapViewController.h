//
//  ETSViewLocatinosMapViewController.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 02/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSAddLocationViewController.h"
#import "Location.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
//@protocol AddLocationDelegate;

@protocol AddLocationDelegate <NSObject>

-(void)addLocation:(Location *)location withSave:(BOOL)save;

@end

@interface ETSViewLocatinosMapViewController : UIViewController<MKMapViewDelegate, AddLocationDelegate,NSFetchedResultsControllerDelegate,UITabBarControllerDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *map;

@end

