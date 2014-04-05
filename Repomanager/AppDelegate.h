//
//  AppDelegate.h
//  Repomanager
//
//  Created by Tobias Witt on 04.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet MainViewController *mainViewController;

@end
