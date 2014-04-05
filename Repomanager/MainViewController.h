//
//  MainViewController.h
//  Repomanager
//
//  Created by Tobias Witt on 04.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AFNetworking/AFNetworking.h>

#import "RepositoryDataSource.h"
#import "TeamDataSource.h"

@interface MainViewController : NSViewController <NSTextFieldDelegate> {
    AFHTTPRequestOperationManager * requestManager;
    NSArray * repos;
    NSArray * teams;
}
- (IBAction)updateRepos:(id)sender;
- (IBAction)updateTeams:(id)sender;
- (IBAction)createAllRepos:(id)sender;
- (IBAction)deleteAllRepos:(id)sender;
- (IBAction)createAllTeams:(id)sender;
- (IBAction)deleteAllTeams:(id)sender;

@property (weak) IBOutlet NSTextField *apiTokenField;
@property (weak) IBOutlet NSTableView *teamTable;
@property (weak) IBOutlet NSTableView *repoTable;
@property (weak) IBOutlet NSTextField *propraField;
@property (weak) IBOutlet NSTextField *groupsField;
@property (weak) IBOutlet NSTextField *teamsField;
@property (weak) IBOutlet NSProgressIndicator *updatingTeamsIndicator;
@property (weak) IBOutlet NSProgressIndicator *updatingReposIndicator;
@property (weak) IBOutlet NSProgressIndicator *updateProgressIndicator;
@property (weak) IBOutlet NSButton *privateRepoCheckbox;

@property (strong) RepositoryDataSource * repoDataSource;
@property (strong) TeamDataSource * teamDataSource;

@end
