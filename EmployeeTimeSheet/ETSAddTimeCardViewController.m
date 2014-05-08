//
//  ETSAddTimeCardViewController.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 03/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "ETSAddTimeCardViewController.h"
#import "Location.h"
#import "TimeCard.h"
//#import "SDSyncEngine.h"

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
    

    
    pvLocations.delegate = self;
    self.tfComment.delegate=self;
    // can't checkin in the future !!.
    self.dpCheckIn.maximumDate = [NSDate date];
    
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
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

- (IBAction)saveTimeCard:(UIBarButtonItem *)sender {
    
    //get location
    Location* loc = [fetchedesultsController.fetchedObjects objectAtIndex:[pvLocations selectedRowInComponent:0]];
    
    [TimeCard BuildByCheckIn:[self.dpCheckIn date] location:loc comment:self.tfComment .text manual:YES inContext:context];
    NSError * error;
    [context save:&error];
    if (error) {
        NSLog(@"ERR:%@",error);
    }
    [self.navigationController popViewControllerAnimated:YES];
//    [[SDSyncEngine sharedEngine] startSync];
    
}
@end
