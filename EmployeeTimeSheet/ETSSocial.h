//
//  ETSSocial.h
//  EmployeeTimeSheet
//
//  Created by Ismail on 21/04/2014.
//  Copyright (c) 2014 Unbounded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Social/Social.h>

@interface ETSSocial : NSObject <UIActionSheetDelegate,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property(weak,nonatomic) UIViewController* presenterViewController;

@end
