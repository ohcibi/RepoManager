//
//  RepositoryTableView.h
//  Repomanager
//
//  Created by Tobias Witt on 05.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import "ManagerDataSource.h"
#import "Repository.h"

@interface RepositoryDataSource : ManagerDataSource
-(void)createAllForGroups:(int)numGroups teams:(int)numTeams asPrivate:(BOOL)private withDone:(void(^)(BOOL success))done andStep:(void(^)(int numRepos))step;
@end
