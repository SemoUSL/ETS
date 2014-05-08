//
//  ETSSocial.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 21/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "ETSSocial.h"
#import "Model/TimeCard.h"
#import "SDCoreDataController.h"

@implementation ETSSocial

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Send SMS"]) {
        //sendSMS
        [self SendSMS];
    }
    else if ([title isEqualToString:@"Send Email"]) {
        //sendEmail
        [self sendEmail];
    }
    if ([title isEqualToString:@"Tweet"]) {
        //Tweet
        [self tweet];
    }
    if ([title isEqualToString:@"Export TimeSheet"]) {
        //Tweet
        [self exportTimeSheet];
    }
}

- (void)sendEmail{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [mailComposer setToRecipients:@[[defaults objectForKey:@"manager_email"]]];
	[mailComposer setSubject:@"Lateness Notification"];
	[mailComposer setMessageBody:@"Dear Sir\nUnfortunately I could not come to work ontime due to a Train Delay." isHTML:NO];
    mailComposer.mailComposeDelegate = self;
    [self.presenterViewController presentViewController:mailComposer animated:YES completion:nil];
}
-(NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@",documentsDirectory);
    return [documentsDirectory stringByAppendingPathComponent:@"TimeSheet.csv"];
}

- (void)exportTimeSheet {
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]])
    // if I leave it, it appends in the same file.
    {
        [[NSFileManager defaultManager] createFileAtPath: [self dataFilePath] contents:nil attributes:nil];
        NSLog(@"Route created");
    }
    
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
    NSFetchedResultsController* ftc = [TimeCard getTimeSheetIncontext:[[SDCoreDataController sharedInstance] masterManagedObjectContext] ];
    NSArray* dataArray = ftc.fetchedObjects;
    
    for (TimeCard *card in dataArray) {
        NSString * locationName = [card.location valueForKey:@"name"];
        [writeString appendFormat:@"\"%@\" \"%@\" \"%@\" \"%@\" \n",locationName,card.checkIn,card.checkOut,card.comment];
    }
    
    
    //Moved this stuff out of the loop so that you write the complete string once and only once.
    NSLog(@"writeString :%@",writeString);
    
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForWritingAtPath: [self dataFilePath] ];
    //say to handle where's the file fo write
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    //position handle cursor to the end of file
    [handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
     UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"TimeSheet Saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
}
-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSString* message;
    switch (result)
	{
        
        case MFMailComposeResultSent:
            //mail sent
            message=@"Message Sent";
			break;
		case MFMailComposeResultCancelled:
            //mail cancelled
            message=@"Message Cancelled";
			break;
		case MFMailComposeResultSaved:
            //draft saved
            message=@"Message Saved";
			break;
		case MFMailComposeResultFailed:
            message=@"Message Failed";
            //failure
			break;
	}
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    [self.presenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)SendSMS
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        messageComposer.recipients = @[[defaults objectForKey:@"manager_phone"]];
        messageComposer.body = @"Dear Sir\nUnfortunatly I couldn not come to work ontime due to a Train Delay.";
        
        messageComposer.messageComposeDelegate = self;
        [self.presenterViewController presentViewController:messageComposer animated:YES completion:nil];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"It seems that your device can not send text." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    NSString*message;
    switch (result) {
        case MessageComposeResultCancelled:
            //cancelled
            message=@"Message Cancelled";

            break;
        case MessageComposeResultFailed:
            //failed
            message=@"Message Failed";

            break;
        case MessageComposeResultSent:
            //sent
            message=@"Message Sent";

            break;
    }
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    [self.presenterViewController dismissViewControllerAnimated:YES completion:nil];
}





- (void)tweet
{
    __block NSString *message;
    SLComposeViewController *socialComposerSheet;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        socialComposerSheet = [[SLComposeViewController alloc] init];
        socialComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [socialComposerSheet setInitialText:[NSString stringWithFormat:@"Hello Twitter!!"]];
        [self.presenterViewController presentViewController:socialComposerSheet animated:YES completion:nil];
    }
    else
    {
        message = @"It seems that you can't tweet right now";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    [socialComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
       
        switch (result) {
            case SLComposeViewControllerResultDone:
                //post worked
                message = @"Done..";
                break;
            case SLComposeViewControllerResultCancelled:
                //cancelled
                message = @"Cancelled!!";
                break;
        }
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

@end
