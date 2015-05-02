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

#define PICKER_EMAIL 0
#define PICKER_MESSAGES 1

@interface Yo2BroViewController ()


#pragma mark - message arrays
@property (strong, nonatomic) NSMutableArray *contactInfoArray;
@property (strong, nonatomic) NSMutableArray *messageArray;
#pragma mark -
@property (nonatomic,strong) IBOutlet UIImageView *profilePic;
@property (nonatomic,strong) IBOutlet UILabel *profileUserName;
@property (nonatomic,strong) IBOutlet UILabel *profileUserEmail;

@property (strong, nonatomic) NSString *selectedEmail;
@property (strong, nonatomic) NSString *selectedMessage;
@property (strong, nonatomic) IBOutlet UILabel *yoSentLabel;
@property (strong, nonatomic) IBOutlet UIButton *inviteSendBro;

@end

@implementation Yo2BroViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *path = [[NSBundle mainBundle] pathForResource: @"messages" ofType:@"plist"];
    
    // Build the array from the messages plist
    _messageArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    _profilePic.layer.cornerRadius = 50;
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

#pragma mark - Actions
- (IBAction)sendScro:(id)sender {
    UIButton *theButton = (UIButton*)sender;
    
    if(theButton.tag == 0){
        
        [theButton setUserInteractionEnabled:NO];
    
        if(!_selectedMessage){
            _selectedMessage = [_messageArray firstObject];
        }
        
        int row = (int)[_profileEmailPicker selectedRowInComponent:0];
        //
        if(_selectedEmail && [_contactInfoArray[row][CONTATCT_DETAIL_ISUSER] integerValue]){
            [PFUser logInWithUsernameInBackground:_selectedEmail password:@"password"
                                            block:^(PFUser *user, NSError *error) {
                if (user) {
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"userId" equalTo:[user objectId]];
                
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                [push setMessage:_selectedMessage];
                [((UIButton*)sender) setEnabled:NO];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * __nullable error) {
                    [((UIButton*)sender) setEnabled:YES];
                    
                    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                                     animations:^{
                                         _yoSentLabel.alpha = 1;
                                         [((UIButton*)sender) setUserInteractionEnabled:YES];
                                         
                                         [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseIn
                                                          animations:^{
                                                              _yoSentLabel.alpha = 0;
                                                              [((UIButton*)sender) setUserInteractionEnabled:YES];
                                                          } completion:nil];
                                         
                                         
                                    } completion:nil];
                    
                    
                    
                }];
            }
     }];
    
    }else{
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Oops!"
                                                         message:@"This email is not registered."
                                                        delegate:self
                                               cancelButtonTitle:@"Sorry"
                                               otherButtonTitles: nil];
        [alert show];
    }
    }else{
        //invite
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
            
            [mailCont setSubject:@"Try out Yo! 2 Bro"];
            [mailCont setToRecipients:[NSArray arrayWithObject:_selectedEmail]];
            [mailCont setMessageBody:@"Hey Bro! install this app so we can send messages to each other! http://www.bitcows.com" isHTML:NO];
            
            [self presentViewController:mailCont animated:YES completion:nil];
        }
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Private Functions
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
            int selectedRow=0;
            
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
                    _selectedEmail = email;
                    selectedRow = i;
                    [_inviteSendBro setTitle:@"Send Yo!" forState:UIControlStateNormal];
                }else{
                    contactDetails[CONTATCT_DETAIL_ISUSER] = @(NO);
                }
                
                [_contactInfoArray addObject:contactDetails];
                
            }
            
            if(_contactInfoArray.count > 1){
                [_profileEmailPicker setHidden:NO];
                [_profileUserEmail setHidden:YES];
                [_profileEmailPicker reloadComponent:0];
                [_profileEmailPicker selectRow:selectedRow inComponent:0 animated:YES];
                
            }else{
                [_profileEmailPicker setHidden: YES];
                [_profileUserEmail setHidden:NO];
                _selectedEmail = email;
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
    
    if(pickerView.tag == PICKER_EMAIL)
        return _contactInfoArray.count;
    else
        return _messageArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if(pickerView.tag == PICKER_EMAIL){
        if(_contactInfoArray.count-1 >= row)
            return _contactInfoArray[row][CONTATCT_DETAIL_EMAIL];
        else
            return [_contactInfoArray lastObject][CONTATCT_DETAIL_EMAIL];
    }else{
        return _messageArray[row];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UIView *pickerCustomView = (id)view;
     UILabel *pickerViewLabel;
    
    UIImageView *pickerImageView;
    
    if (!pickerCustomView) {
        pickerCustomView= [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        pickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 35.0f, 35.0f)];
        pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        [pickerViewLabel setTextAlignment:NSTextAlignmentCenter];
        // the values for x and y are specific for my example
        [pickerCustomView addSubview:pickerImageView];
        [pickerCustomView addSubview:pickerViewLabel];
    }
    
    if(pickerView.tag == PICKER_EMAIL){
        if([_contactInfoArray[row][CONTATCT_DETAIL_ISUSER] integerValue]){
            pickerImageView.image = [UIImage imageNamed:@"scrohands.png"];
        }
        
        pickerViewLabel.text = _contactInfoArray[row][CONTATCT_DETAIL_EMAIL];
    }else{
        pickerViewLabel.text = _messageArray[row];
    }
    
    return pickerCustomView;
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerView.tag == PICKER_EMAIL){
        _selectedEmail = _contactInfoArray[row][CONTATCT_DETAIL_EMAIL];
        
        if([_contactInfoArray[row][CONTATCT_DETAIL_ISUSER] integerValue]){
            [_inviteSendBro setTitle:@"Send Yo!" forState:UIControlStateNormal];
            _inviteSendBro.tag = 0;
        }
        else{
            [_inviteSendBro setTitle:@"Invite Bro" forState:UIControlStateNormal];
            _inviteSendBro.tag = 1;
        }
        
        NSLog(@"Picked: %@", _selectedEmail);
    }else{
        _selectedMessage = _messageArray[row];
    }
}


@end
