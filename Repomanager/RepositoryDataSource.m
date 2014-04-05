//
//  RepositoryTableView.m
//  Repomanager
//
//  Created by Tobias Witt on 05.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import "RepositoryDataSource.h"

@implementation RepositoryDataSource

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
           row:(NSInteger)row {
    Repository * repo = self.source[row];
    
    if ([tableColumn.identifier isEqualToString:@"nameColumn"]) {
        return repo.name;
    } else {
        return repo.private ? @"✔" : @"✘";
    }
}

-(void)update:(void(^)(BOOL success))done {
    [self updateSourceForApiCall:@"repos" withCreator:(id)^(NSDictionary * repo) {
        return [[Repository alloc] initWithName:[repo objectForKey:@"name"]
                                        private:[[repo objectForKey:@"private"] boolValue]];
    } andDone:done];
}

-(void)createAllForGroups:(int)numGroups teams:(int)numTeams asPrivate:(BOOL)private
                      withDone:(void (^)(BOOL success))done
                       andStep:(void (^)(int numRepos))step {
    [self forAllGroups:numGroups andTeams:numTeams
                    do:^(NSString * group, BOOL lastOne) {
                        [self post:@"repos" lastOne:lastOne
                        withParams:@{@"name": group, @"private": @(private)}
                              done:done andStep:step];
    }];
    
}

@end
