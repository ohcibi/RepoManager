//
//  ManagerDataSource.h
//  Repomanager
//
//  Created by Tobias Witt on 05.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface ManagerDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate>

-(id)initWithSource:(NSArray *)source requestManager:(AFHTTPRequestOperationManager *)requestManager andTableView:(NSTableView *)tableView;

-(NSArray *)sortedSourceFromArray:(NSArray *)array ascending:(BOOL)ascending;
-(NSArray *)sortedSource:(BOOL)ascending;
-(void)updateSourceForApiCall:(NSString *)call withCreator:(id (^)(NSDictionary *))creator andDone:(void(^)(BOOL success))done;
-(void)update:(void(^)(BOOL success))done;

-(void)forAllGroups:(int)numGroups andTeams:(int)numTeams do:(void(^)(NSString * group, BOOL lastOne))block;
-(void)post:(NSString *)type lastOne:(BOOL)lastOne withParams:(NSDictionary *)parameters done:(void (^)(BOOL success))done andStep:(void (^)(int numRepos))step;

@property (strong) NSArray * source;
@property (strong) AFHTTPRequestOperationManager * requestManager;
@property (strong) NSTableView * tableView;

@property (strong) NSString * propra;

@end
