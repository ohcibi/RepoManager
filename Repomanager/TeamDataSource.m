//
//  TeamDataSource.m
//  Repomanager
//
//  Created by Tobias Witt on 05.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import "TeamDataSource.h"

@implementation TeamDataSource

-(id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
                 row:(NSInteger)row {
    Team * team = self.source[row];

    if ([tableColumn.identifier isEqualToString:@"teamColumn"]) {
        return team.name;
    } else {
        return [NSString stringWithFormat:@"%i", team.id];
    }
}

-(void)update:(void(^)(BOOL success))done {
    [self updateSourceForApiCall:@"teams" withCreator:(id)^(NSDictionary * team) {
        return [[Team alloc] initWithId:[[team objectForKey:@"id"] intValue]
                                   name:[team objectForKey:@"name"]];
    } andDone:done];
}

-(void)createAllForGroups:(int)numGroups andTeams:(int)numTeams
                 withDone:(void (^)(BOOL))done andStep:(void (^)(int))step {
    [self forAllGroups:numGroups
              andTeams:numTeams
                    do:^(NSString *group, BOOL lastOne) {
                        [self post:@"teams" lastOne:lastOne
                        withParams:@{@"name": group, @"repo_names": @[[NSString stringWithFormat:@"%@/%@",
                                                                       self.propra, group]],
                                     @"permission": @"push"}
                              done:^(BOOL success) {
                                  step(1);
                                  if (lastOne) {
                                      done(YES);
                                  }
                              } andStep:^(int numRepos) {
                                  step(1);
                                  if (lastOne) {
                                      done(NO);
                                  }
                              }];
                    }];
}

-(void)forAllTeamsDo:(void(^)(Team * team, BOOL lastOne))block {
    NSArray * teams = [self.source filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name != 'Owners'"]];
    for (int i = 0; i < [teams count]; i++) {
        Team * team = teams[i];
        block(team, i == [teams count] - 1);
    };
}

-(void)deleteAllTeamsWithDone:(void (^)(BOOL))done andStep:(void (^)(int))step {
    [self forAllTeamsDo:^(Team * team, BOOL lastOne) {
        [self.requestManager DELETE:[NSString stringWithFormat:@"teams/%i", team.id]
                         parameters:nil
                            success:^(AFHTTPRequestOperation * operation, id response) {
                                step(1);
                                if (lastOne) {
                                    done(YES);
                                }
                            }
                            failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                                NSLog(@"JSON: %@", error);
                                step(1);
                                if (lastOne) {
                                    done(NO);
                                }
                            }];
    }];
}

-(void)grantWrite:(void (^)(BOOL))done {
    [self grant:@"push" withDone:done];
}

-(void)grantRead:(void (^)(BOOL))done {
    [self grant:@"pull" withDone:done];
}

-(void)grant:(NSString *)permission withDone:(void (^)(BOOL))done {
    [self forAllTeamsDo:^(Team *team, BOOL lastOne) {
        [self.requestManager
         PATCH:[NSString stringWithFormat:@"teams/%i", team.id]
         parameters:@{@"permission": permission} success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if (lastOne) {
                 done(YES);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (lastOne) {
                 done(NO);
             }
         }];
    }];
}

@end
