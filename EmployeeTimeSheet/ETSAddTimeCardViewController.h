//
//  ETSAddTimeCardViewController.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 03/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSAddTimeCardViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UIDatePicker *dpCheckIn;
@property (strong, nonatomic) IBOutlet UITextField *tfComment;
@property (strong, nonatomic) IBOutlet UIPickerView *pvLocations;
@property (weak, nonatomic)  NSManagedObjectContext* context;
@property (strong,nonatomic)    NSFetchedResultsController * fetchedesultsController;

- (IBAction)saveOldTimeCard:(UIBarButtonItem *)sender;
@end
