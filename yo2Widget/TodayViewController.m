//
//  TodayViewController.m
//  yo2Widget
//
//  Created by Darren Mason on 5/10/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (strong, nonatomic) NSMutableArray *messageArray;
@property (strong, nonatomic) IBOutlet UITextField *yoText;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.preferredContentSize = CGSizeMake(0, 65);
    NSString *path = [[NSBundle mainBundle] pathForResource: @"messages" ofType:@"plist"];
    
    // Build the array from the messages plist
    _messageArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
}
- (IBAction)sendYo:(id)sender {
    NSExtensionContext *myExtension=[self extensionContext];
    [myExtension openURL:[NSURL URLWithString:@"com.bitcows.yo2bro.URL://sendYO"] completionHandler:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}


@end
