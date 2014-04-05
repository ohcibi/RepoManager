//
//  AppDelegate.m
//  Repomanager
//
//  Created by Tobias Witt on 04.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self.window.contentView addSubview:self.mainViewController.view];
}

@end
