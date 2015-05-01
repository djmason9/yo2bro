//
//  ViewController.h
//  yo2bro
//
//  Created by Mason, Darren J on 4/30/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//
#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>
#import "Yo2BroProfilePictureButton.h"

@interface Yo2BroViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>
{
    @public
    ABRecordRef person;
}

@property (strong, nonatomic) IBOutlet UIPickerView *profileEmailPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *messagePicker;


@end

