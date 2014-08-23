//
//  BWSettingsViewController.m
//  BREWise
//
//  Created by Jackson Keating on 8/21/14.
//  Copyright (c) 2014 Brewise. All rights reserved.
//

#import "BWSettingsViewController.h"

@interface BWSettingsViewController ()

@end

@implementation BWSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
