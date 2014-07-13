//
//  MainViewController.m
//  Repomanager
//
//  Created by Tobias Witt on 04.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#define kGithubApiURL @"https://api.github.com"

#import "MainViewController.h"
#import "Team.h"
#import "Repository.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(void)awakeFromNib {
    if (!requestManager) {
        requestManager = [[AFHTTPRequestOperationManager alloc]
                          initWithBaseURL:[NSURL URLWithString:kGithubApiURL]];
        requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
        requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [requestManager.operationQueue setMaxConcurrentOperationCount:1];
        [requestManager.requestSerializer setValue:[NSString stringWithFormat:@"token %@",
                                                    [self.apiTokenField stringValue]]
                                forHTTPHeaderField:@"Authorization"];
    }
    
    if (!self.repoDataSource) {
        self.repoDataSource = [[RepositoryDataSource alloc] initWithSource:[NSArray array]
                                                            requestManager:requestManager
                                                              andTableView:self.repoTable];
        [self.repoDataSource bind:@"propra" toObject:[NSUserDefaultsController sharedUserDefaultsController]
                      withKeyPath:@"values.propra" options:nil];
    }
    
    if (!self.teamDataSource) {
        self.teamDataSource = [[TeamDataSource alloc] initWithSource:[NSArray array]
                                                      requestManager:requestManager
                                                        andTableView:self.teamTable];
        [self.teamDataSource bind:@"propra" toObject:[NSUserDefaultsController sharedUserDefaultsController]
                      withKeyPath:@"values.propra" options:nil];
    }
}

-(void)controlTextDidChange:(NSNotification *)notification {
    NSTextField * textField = [notification object];
    if (textField == self.apiTokenField) {
        [requestManager.requestSerializer setValue:[NSString stringWithFormat:@"token %@",
                                                    [self.apiTokenField stringValue]]
                                forHTTPHeaderField:@"Authorization"];
    }
}

-(IBAction)updateRepos:(id)sender {
    [self.updatingReposIndicator startAnimation:self];
    [self.repoDataSource update:^(BOOL success) {
        [self.updatingReposIndicator stopAnimation:self];
    }];
}

- (IBAction)updateTeams:(id)sender {
    [self.updatingTeamsIndicator startAnimation:self];
    [self.teamDataSource update:^(BOOL success) {
        [self.updatingTeamsIndicator stopAnimation:self];
    }];
}

-(void)forAllTeamsAndReposDo:(void(^)(NSString * group, BOOL lastOne))block {
    int numGroups = [self.groupsField intValue];
    int numTeams = [self.teamsField intValue];
    
    [self.updateProgressIndicator setDoubleValue:0];
    self.updateProgressIndicator.maxValue = numGroups * numTeams;
    [self.updateProgressIndicator startAnimation:self];
    
    for (unsigned long group = 1; group <= numGroups; group++) {
        for (int team = 1; team <= numTeams + (group == 4 ? 1 : 0); team++) {
            if (group == 4 && team == 2) {
                continue;
            }
            block([NSString stringWithFormat:@"team%lX%i", group, team],
                  group == numGroups && team == numTeams);
        }
    }
}

- (IBAction)createAllRepos:(id)sender {
    [self.updatingReposIndicator startAnimation:self];
    
    [self.updateProgressIndicator setDoubleValue:0];
    self.updateProgressIndicator.maxValue = [self.groupsField intValue] * [self.teamsField intValue];
    [self.updateProgressIndicator startAnimation:self];
    
    [self.repoDataSource createAllForGroups:[self.groupsField intValue]
                                      teams:[self.teamsField intValue]
                                  asPrivate:[self.privateRepoCheckbox state] == NSOnState
                                   withDone:^(BOOL success) {
                                       [self.updateProgressIndicator stopAnimation:self];
                                       [self updateRepos:nil];
                                       [self updateTeams:nil];
                                   }
                                    andStep:^(int numRepos) {
                                        [self.updateProgressIndicator incrementBy:numRepos];
                                    }];
}

- (IBAction)deleteAllRepos:(id)sender {
    [self.updatingReposIndicator startAnimation:self];
    [self forAllTeamsAndReposDo:^(NSString *group, BOOL lastOne) {
        [requestManager DELETE:[NSString stringWithFormat:@"repos/%@/%@",
                                [self.propraField stringValue], group]
                    parameters:nil
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           [self.updateProgressIndicator incrementBy:1];
                           if (lastOne) {
                               [self.updateProgressIndicator stopAnimation:self];
                               [self updateRepos:nil];
                               [self updateTeams:nil];
                           }
                       }
                       failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                           NSLog(@"JSON: %@", error);
                           [self.updateProgressIndicator incrementBy:1];
                       }];
    }];
}

- (IBAction)createAllTeams:(id)sender {
    [self.updatingTeamsIndicator startAnimation:self];
    
    [self.updateProgressIndicator setDoubleValue:0];
    self.updateProgressIndicator.maxValue = [self.groupsField intValue] * [self.teamsField intValue];
    [self.updateProgressIndicator startAnimation:self];
    
    [self.teamDataSource createAllForGroups:[self.groupsField intValue]
                                   andTeams:[self.teamsField intValue]
                                   withDone:^(BOOL success) {
                                       [self.updateProgressIndicator stopAnimation:self];
                                       [self updateRepos:nil];
                                       [self updateTeams:nil];
                                   }
                                    andStep:^(int numRepos) {
                                        [self.updateProgressIndicator incrementBy:numRepos];
                                    }];
}

- (IBAction)deleteAllTeams:(id)sender {
    [self.updatingTeamsIndicator startAnimation:self];
    [self.teamDataSource deleteAllTeamsWithDone:^(BOOL success) {
        [self.updateProgressIndicator stopAnimation:self];
        [self updateRepos:nil];
        [self updateTeams:nil];
    } andStep:^(int numUpdates) {
        [self.updateProgressIndicator incrementBy:numUpdates];
    }];
}

- (IBAction)grantWrite:(id)sender {
    [self.updatingTeamsIndicator startAnimation:self];
    [self.updateProgressIndicator setDoubleValue:0];
    self.updateProgressIndicator.maxValue = [self.groupsField intValue] * [self.teamsField intValue];
    [self.updateProgressIndicator startAnimation:self];
    [self.teamDataSource grantWrite:^(BOOL success){
        [self.updatingTeamsIndicator stopAnimation:self];
    }];
}

- (IBAction)grantRead:(id)sender {
    [self.updatingTeamsIndicator startAnimation:self];
    [self.updateProgressIndicator setDoubleValue:0];
    self.updateProgressIndicator.maxValue = [self.groupsField intValue] * [self.teamsField intValue];
    [self.updateProgressIndicator startAnimation:self];
    [self.teamDataSource grantRead:^(BOOL success){
        [self.updatingTeamsIndicator stopAnimation:self];
    }];
}
@end