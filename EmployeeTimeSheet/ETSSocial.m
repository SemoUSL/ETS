//
//  ETSSocial.m
//  EmployeeTimeSheet
//
//  Created by Ismail on 21/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import "ETSSocial.h"

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
}
- (void)sendEmail{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setToRecipients:@[@"ismail.hassanein@gmail.com"]];
	[mailComposer setSubject:@"Latness Notification"];
	[mailComposer setMessageBody:@"Dear Sir\nUnfortunatly I could not come to work ontime due to a Train Delay." isHTML:NO];
    mailComposer.mailComposeDelegate = self;
    [self.presenterViewController presentViewController:mailComposer animated:YES completion:nil];
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
        
        messageComposer.recipients = @[@"07721594214"];
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
        [socialComposerSheet setInitialText:[NSString stringWithFormat:@"FindMeMasjid is the best App%@",socialComposerSheet.serviceType]];
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
