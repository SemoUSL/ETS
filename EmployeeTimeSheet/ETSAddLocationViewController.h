//
//  ETSAddLocationViewController.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Location.h"
#import "ETSViewLocatinosMapViewController.h"

@protocol AddLocationDelegate;

@interface ETSAddLocationViewController : UIViewController<UITextFieldDelegate,MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *tfLocationName;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSaveLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblRabgeValue;
@property (strong, nonatomic) IBOutlet UISlider *sldRange;
@property (strong, nonatomic) IBOutlet UITextField *tfAddress;
@property (strong, nonatomic) IBOutlet MKMapView *map;

@property (weak, nonatomic) id <AddLocationDelegate> delegate;
@property (strong, nonatomic) Location * location;
@property(weak ,nonatomic)  NSManagedObjectContext* context;
- (IBAction)sldRangeValueChanged:(UISlider *)sender;

- (IBAction)saveLocation:(UIBarButtonItem *)sender;


@end