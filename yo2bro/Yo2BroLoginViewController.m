//
//  Scro2BroLoginViewController.m
//  scro2bro
//
//  Created by Darren Mason on 4/24/15.
//  Copyright (c) 2015 bitcows. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "Yo2BroLoginViewController.h"
#import "Yo2broSettings.h"
#import "Yo2BroTableViewController.h"

@interface Yo2BroLoginViewController ()
{
    BOOL _viewDidAppear;
    BOOL _viewIsVisible;
    BOOL _animationRan;
}

@property (strong, nonatomic) IBOutlet UIImageView *profilePicWrapper;
@property (strong, nonatomic) NSMutableArray *allUsers;
@property (strong, nonatomic) IBOutlet UIImageView *mainBg;
@property (strong, nonatomic) IBOutlet UIImageView *splashImage1;
@property (strong, nonatomic) IBOutlet UIImageView *splashImage2;
@property (strong, nonatomic) IBOutlet UIView *orView;

@end

@implementation Yo2BroLoginViewController

- (IBAction)takeMeBack:(id)sender {
    if(!_allUsers)
        [_loginSpinner startAnimating];
    
    [self performSegueWithIdentifier:@"showMain" sender:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _animationRan = NO;
    
    self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.profilePictureButton.profileID = @"me";
    self.loginButton.layer.borderColor = [UIColor colorWithRed:45.0/255 green:69.0/255 blue:122.0/255 alpha:1].CGColor;
    self.loginButton.layer.borderWidth = 1;
    self.loginButton.layer.masksToBounds = YES;
    
    [self.view bringSubviewToFront:self.mainBg];
    [self.view bringSubviewToFront:self.splashImage1];
    [self.view bringSubviewToFront:self.splashImage2];
    
    _profilePictureButton.layer.cornerRadius = 75;
    _profilePictureButton.layer.masksToBounds = YES;
    _profilePictureButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _profilePictureButton.layer.borderWidth  = 4;
  
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!_animationRan){
    
    //3. animate the open
    [UIView animateWithDuration:1.0
                          delay:0.3
                        options:(UIViewAnimationCurveEaseOut)
                     animations:^{
                        
                        self.splashImage1.frame = CGRectMake(self.splashImage1.frame.origin.x, self.splashImage1.frame.origin.y+20, 229, 171);
                        self.splashImage2.frame = CGRectMake(self.splashImage2.frame.origin.x, self.splashImage2.frame.origin.y-20, 229, 171);
                         
                     } completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.5
                                               delay:0.0
                                             options:(UIViewAnimationCurveEaseOut)
                                          animations:^{
                                              self.splashImage2.alpha = 0;
                                              self.splashImage1.alpha = 0;
                                             
                                              } completion:^(BOOL finished){
                                                  _animationRan= YES;
                                                     //remove that imageview from the view
                                                     [self.splashImage1 setHidden:YES];
                                                     [self.splashImage2 setHidden:YES];
                                                     [self.view sendSubviewToBack:self.mainBg];
                                                   [self finalizeLoad];
                                              }];
    
    
                     }];
    }else{
        [self finalizeLoad];
    }
}

-(void)finalizeLoad{
    self.profilePictureButton.pictureCropping = FBSDKProfilePictureModeSquare;
    
    Yo2broSettings *settings = [Yo2broSettings defaultSettings];
    if (_viewDidAppear) {
        _viewIsVisible = YES;
        [_takeMeBack setHidden:NO];
        [_orView setHidden:NO];
        // reset
        settings.shouldSkipLogin = NO;
    } else {
        if (settings.shouldSkipLogin || [FBSDKAccessToken currentAccessToken]) {
            [_loginSpinner startAnimating];
            [self collectAllUsers];
            [_takeMeBack setHidden:YES];
            [_orView setHidden:YES];
        } else {
            _viewIsVisible = YES;
        }
        _viewDidAppear = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [Yo2broSettings defaultSettings].shouldSkipLogin = YES;
    _viewIsVisible = NO;
}

#pragma mark - Logout
- (IBAction)showLogin:(UIStoryboardSegue *)segue
{
    // This method exists in order to create an unwind segue to this controller.
}

#pragma mark - Login Delegates
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [_takeMeBack setHidden:YES];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    //welcome back from shitbook.. did you get the stuff?
    if(error){
        //shitbook gave an error!
        NSLog(@"Unexpected login error: %@", error);
        NSString *alertMessage = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?: @"There was a problem logging in. Please try again later.";
        NSString *alertTitle = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops";
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
    }else{
        
        if (_viewIsVisible) {
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            
            UIApplication *application = [UIApplication sharedApplication];
            
            if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                UIUserNotificationTypeBadge |
                                                                UIUserNotificationTypeSound);
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                         categories:nil];
                [application registerUserNotificationSettings:settings];
                [application registerForRemoteNotifications];
            } else
#endif
            {
                [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                 UIRemoteNotificationTypeAlert |
                                                                 UIRemoteNotificationTypeSound)];
            }
            [self collectAllUsers];
        }
    }

}

- (void)collectAllUsers{
    //    //gets all the users in the table to compare contacts with.
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _allUsers = [NSMutableArray array];
        if (!error) {
            // The find succeeded. The first 100 objects are available in objects
            NSLog(@"%@", objects);
            for (PFUser *obj in objects){
                [_allUsers addObject:obj[@"email"]];
            }
           
            [_loginSpinner stopAnimating];
            [self performSegueWithIdentifier:@"showMain" sender:self];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"showMain"]){
        UINavigationController *nc = [segue destinationViewController];
        Yo2BroTableViewController *vc = nc.viewControllers[0];
        vc.allUsers = [_allUsers copy];
    }
}



@end
