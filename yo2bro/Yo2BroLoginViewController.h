//
//  Scro2BroLoginViewController.h
//  scro2bro
//
//  Created by Darren Mason on 4/24/15.
//  Copyright (c) 2015 bitcows. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>

#import "Yo2BroProfilePictureButton.h"   

@interface Yo2BroLoginViewController : UIViewController<FBSDKLoginButtonDelegate>

@property (nonatomic, strong) IBOutlet Yo2BroProfilePictureButton *profilePictureButton;

@property (nonatomic, strong) IBOutlet FBSDKLoginButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *takeMeBack;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;

@end
