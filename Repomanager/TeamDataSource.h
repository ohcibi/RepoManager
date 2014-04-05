//
//  TeamDataSource.h
//  Repomanager
//
//  Created by Tobias Witt on 05.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import "ManagerDataSource.h"
#import "Team.h"

@interface TeamDataSource : ManagerDataSource

-(void)createAllForGroups:(int)numGroups andTeams:(int)numTeams withDone:(void(^)(BOOL success))done andStep:(void(^)(int numRepos))step;
-(void)deleteAllTeamsWithDone:(void(^)(BOOL success))done andStep:(void(^)(int numTeams))step;

@end
