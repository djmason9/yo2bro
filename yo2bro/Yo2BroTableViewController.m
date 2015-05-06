//
//  Yo2BroTableViewController.m
//  yo2bro
//
//  Created by Mason, Darren J on 4/30/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Yo2BroTableViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Yo2BroViewController.h"
#import "Yo2BroAppDelegate.h"

@import AddressBook;

#define CONTATCT_DETAIL_EMAIL @"email"
#define CONTATCT_DETAIL_ISUSER @"isUser"

@interface Yo2BroTableViewController ()
{
    ABRecordRef selectedPerson;
}

@property(strong,nonatomic)UIView *spinnerView;
@property (nonatomic,strong) NSArray *allContacts;
@property (nonatomic,strong) NSMutableArray *filteredContacts;
@property (strong, nonatomic) NSString *choosenEmail;

@end

@implementation Yo2BroTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allContacts   = [self getAllContacts];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)addRemoveSpinner:(BOOL)isAdd{
    if(isAdd){
        _spinnerView = [[[NSBundle mainBundle] loadNibNamed:@"SpinnerView" owner:self options:nil] objectAtIndex:0];
        _spinnerView.layer.opacity = 0.5;
        _spinnerView.frame = self.tableView.frame;
        [self.navigationController.view addSubview:_spinnerView];
        [self.tableView setUserInteractionEnabled:NO];
    }else{
        [_spinnerView removeFromSuperview];
        [self.tableView setUserInteractionEnabled:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showHideAllContacts:(id)sender {
    if(((UIButton*)sender).tag == 0){
        ((UIButton*)sender).tag = 1;
        [((UIButton*)sender) setTitle:@"Yo 2 Bro Contacts" forState:UIControlStateNormal];
        self.allContacts = [self getAllContacts];
        [self.tableView reloadData];
    }else{
        ((UIButton*)sender).tag = 0;
        [((UIButton*)sender) setTitle:@"All Contacts" forState:UIControlStateNormal];
        [self addRemoveSpinner:YES];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            //Load your data here
            self.allContacts   = [self getAllRegisteredUsers];
            //Dispatch back to the main queue once your data is loaded.
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update your UI here, or transition to the data centric view controller. The data loaded above is available at the time this block runs
                [self.tableView reloadData];
                [self addRemoveSpinner:NO];
            });
        });
    }
}

-(NSArray*) getAllEmails:(ABRecordRef)person{
    
    NSMutableArray *contactInfoArray = [NSMutableArray array];
    
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    if(emailsRef){
            NSString *email;
            
            for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
                NSMutableDictionary *contactDetails =[NSMutableDictionary dictionary];
//                CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
                CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
                
                email = (__bridge NSString *)currentEmailValue;
                
                //set email
                contactDetails[CONTATCT_DETAIL_EMAIL] = email;
            
//                NSLog(@"Email: %@",email);
                
//                CFRelease(currentEmailLabel);
                CFRelease(currentEmailValue);
                //check each user to see if they are a YO! user
                PFUser *scroUser = [PFUser logInWithUsername:email password:@"password"];
                if(scroUser){
                    NSLog(@"%@ is a user.",email);
                    contactDetails[CONTATCT_DETAIL_ISUSER] = @(YES);
                    _choosenEmail = email;
                }else{
                    contactDetails[CONTATCT_DETAIL_ISUSER] = @(NO);
                }
                
                [contactInfoArray addObject:contactDetails];
                
            }
    }
    return  contactInfoArray;
}

-(NSArray*)getAllRegisteredUsers{
    
    if(!_filteredContacts){
        NSArray *items = [self getAllContacts];
        _filteredContacts = [NSMutableArray array];
        
        for (NSInteger i = 0; i < items.count; i++) {
            ABRecordRef person = (__bridge ABRecordRef)items[i];
            NSArray *emails = [self getAllEmails:person];
            for (NSDictionary *emailDict in emails ) {
                if([_allUsers containsObject:emailDict[CONTATCT_DETAIL_EMAIL]]){
                    NSLog(@"FILTERED EMAIL: %@",emailDict[CONTATCT_DETAIL_EMAIL]);
                    [_filteredContacts addObject:(__bridge NSArray*)person];
                }
            }
        }
    }
    
    
    return _filteredContacts;
}

- (NSArray *)getAllContacts {
    
    CFErrorRef *error = nil;
    NSArray* items;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
        //  ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
//        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
//        items = [NSMutableArray arrayWithCapacity:nPeople];
        
       items = (__bridge NSArray*)allPeople;
        
//        for (NSInteger i = 0; i < nPeople; i++) {
//            ABRecordRef person = (__bridge ABRecordRef)items[i];
//            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
//            NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
//            NSLog(@"%@ %@", firstName, lastName);
//        }
    }
    return items;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.allContacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier =@"contactCell";
    NSString *displayName;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ABRecordRef person = (__bridge ABRecordRef)[self.allContacts objectAtIndex:indexPath.row];
    NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
    NSString *company = CFBridgingRelease(ABRecordCopyValue(person, kABPersonOrganizationProperty));
    
    if(firstName && lastName)
       displayName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    else if(firstName && !lastName){
        displayName = firstName;
    }else if(lastName && !firstName){
        displayName = lastName;
    }else if(company && !firstName & !lastName){
        displayName = company;
    }
        
    

    if(ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge NSData*) ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        UIImage *img = [[UIImage alloc] initWithData:contactImageData];
        cell.imageView.image = img;
    }else{
        cell.imageView.image =  [UIImage imageNamed:@"blank_profile.png"];
    }
    
    // Configure the cell.
    cell.textLabel.text = displayName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell.textLabel.text);
    selectedPerson = (__bridge ABRecordRef)[self.allContacts objectAtIndex:indexPath.row];
    NSArray *emails = [self getAllEmails:selectedPerson];
    if(emails.count>0)
        NSLog(@"EMAIL: %@",emails[0][@"email"]); //first email
    
    [self performSegueWithIdentifier: @"showDetails" sender: self];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"showDetails"]){
        Yo2BroViewController *vc = [segue destinationViewController];
        vc->person = selectedPerson;
    }
}


@end

