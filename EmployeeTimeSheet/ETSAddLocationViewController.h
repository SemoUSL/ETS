//
//  ETSAddLocationViewController.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 30/03/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
//#import <l>

@interface ETSAddLocationViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *tfLocationName;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSaveLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblRabgeValue;
@property (strong, nonatomic) IBOutlet UISlider *sldRange;

@property (strong, nonatomic) IBOutlet UISearchBar *sbLocationSearch;
@property (strong, nonatomic) IBOutlet MKMapView *map;


@end
