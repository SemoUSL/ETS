//
//  ETSAddTimeCardViewController.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 03/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "ETSAddTimeCardViewController.h"
#import "Location.h"

@interface ETSAddTimeCardViewController ()

@end

@implementation ETSAddTimeCardViewController
@synthesize context,fetchedesultsController,pvLocations;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - Picker View
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnStr = @"";
    if (pickerView == pvLocations)
    {
        returnStr = ((Location*)[[fetchedesultsController fetchedObjects ]objectAtIndex:row]).name;
    }
    
    return returnStr;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == pvLocations)
    {
        return [[fetchedesultsController fetchedObjects] count];
    }
    return  0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
#pragma mark
- (void)viewDidLoad
{
    [super viewDidLoad];
    // get the locations from CoreData.
     fetchedesultsController = [Location getLocationsIncontext:context];
//    NSLog(@"%i",fetchedesultsController.fetchedObjects.count);
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveOldTimeCard:(UIBarButtonItem *)sender {
}
@end
