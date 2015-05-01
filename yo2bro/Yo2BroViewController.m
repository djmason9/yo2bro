//
//  ViewController.m
//  yo2bro
//
//  Created by Mason, Darren J on 4/30/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//


#import "Yo2BroViewController.h"


#define CONTATCT_DETAIL_EMAIL @"email"
#define CONTATCT_DETAIL_ISUSER @"isUser"

@interface Yo2BroViewController ()
{
    BOOL isContactABro;
}
@property (strong, nonatomic) NSMutableArray *contactInfoArray;
@property (nonatomic,strong) IBOutlet UIImageView *profilePic;
@property (nonatomic,strong) IBOutlet UILabel *profileUserName;
@property (nonatomic,strong) IBOutlet UILabel *profileUserEmail;

@property (strong, nonatomic) NSString *choosenEmail;

@end

@implementation Yo2BroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isContactABro = NO;
    
    _profilePic.layer.cornerRadius = 75;
    _profilePic.layer.masksToBounds = YES;
    _profilePic.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _profilePic.layer.borderWidth  = 2;
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [self displayPerson];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendScro:(id)sender {
    
    //
    if(_choosenEmail && isContactABro){
        [PFUser logInWithUsernameInBackground:_choosenEmail password:@"password"
                                        block:^(PFUser *user, NSError *error) {
            if (user) {
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"userId" equalTo:[user objectId]];
                
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                [push setMessage:@"Scro?"];
                [((UIButton*)sender) setEnabled:NO];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * __nullable error) {
                    [((UIButton*)sender) setEnabled:YES];
                    
                    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@""
                                                                     message:@"Scro Sent!"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles: nil];
                    [alert show];
                    
                }];
            } else {
                // The login failed. Check error to see why.
            }
        }];
    }else{
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Oops!"
                                                         message:@"No email selected."
                                                        delegate:self
                                               cancelButtonTitle:@"Sorry"
                                               otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void)displayPerson
{
    _contactInfoArray = [NSMutableArray array];
    
    NSString* f_name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSLog(@"NAME: %@",f_name);
    
    NSString* l_name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSLog(@"NAME: %@",l_name);
    
    
    _profileUserName.text = [NSString stringWithFormat:@"%@ %@",f_name,l_name];
    
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    if(emailsRef){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSString *email;
            
            for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
                NSMutableDictionary *contactDetails =[NSMutableDictionary dictionary];
                CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
                CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
                
                email = (__bridge NSString *)currentEmailValue;
                
                //set email
                contactDetails[CONTATCT_DETAIL_EMAIL] = email;
                
                _profileUserEmail.text = email;
                NSLog(@"Email: %@",email);
                
                CFRelease(currentEmailLabel);
                CFRelease(currentEmailValue);
                
                PFUser *scroUser = [PFUser logInWithUsername:email password:@"password"];
                if(scroUser){
                    NSLog(@"%@ is a user.",email);
                    contactDetails[CONTATCT_DETAIL_ISUSER] = @(YES);
                    _choosenEmail = email;
                }else{
                    contactDetails[CONTATCT_DETAIL_ISUSER] = @(NO);
                }
                
                [_contactInfoArray addObject:contactDetails];
                
            }
            
            if(_contactInfoArray.count > 1){
                [_profileEmailPicker setHidden:NO];
                [_profileUserEmail setHidden:YES];
                [_profileEmailPicker reloadComponent:0];
            }else{
                [_profileEmailPicker setHidden: YES];
                [_profileUserEmail setHidden:NO];
                _choosenEmail = email;
            }
            
            CFRelease(emailsRef);
        }];
    }
    
    if(ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge NSData*) ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        UIImage *img = [[UIImage alloc] initWithData:contactImageData];
        _profilePic.image = img;
    }
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if(phoneNumbers){
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            phone = (__bridge_transfer NSString*)
            ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        } else {
            phone = @"[None]";
        }
        
        NSLog(@"PHONE: %@",phone);
        
        CFRelease(phoneNumbers);
    }
    

    
}

#pragma mark - Picker Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _contactInfoArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if(_contactInfoArray.count-1 >= row)
        return _contactInfoArray[row][CONTATCT_DETAIL_EMAIL];
    else
        return [_contactInfoArray lastObject][CONTATCT_DETAIL_EMAIL];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UIView *pickerCustomView = (id)view;
    UILabel *pickerViewLabel;
    UIImageView *pickerImageView;
    
    if (!pickerCustomView) {
        pickerCustomView= [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        pickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 35.0f, 35.0f)];
        pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(37.0f, 0.0f, [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        // the values for x and y are specific for my example
        [pickerCustomView addSubview:pickerImageView];
        [pickerCustomView addSubview:pickerViewLabel];
    }
    
    if([_contactInfoArray[row][CONTATCT_DETAIL_ISUSER] integerValue]){
        pickerImageView.image = [UIImage imageNamed:@"scrohands.png"];
    }
    
    pickerViewLabel.text = _contactInfoArray[row][CONTATCT_DETAIL_EMAIL];
    
    return pickerCustomView;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _choosenEmail = _contactInfoArray[row][CONTATCT_DETAIL_EMAIL];
    isContactABro = [_contactInfoArray[row][CONTATCT_DETAIL_ISUSER] integerValue];
    
    NSLog(@"Picked: %@", _choosenEmail);
}


@end
