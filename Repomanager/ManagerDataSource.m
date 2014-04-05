//
//  ManagerDataSource.m
//  Repomanager
//
//  Created by Tobias Witt on 05.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import "ManagerDataSource.h"

@implementation ManagerDataSource

-(id)initWithSource:(NSArray *)source
     requestManager:(AFHTTPRequestOperationManager *)requestManager
       andTableView:(NSTableView *)tableView {
    self = [super init];
    if (self) {
        self.source = source;
        self.requestManager = requestManager;
        self.tableView = tableView;
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        [self addObserver:self
               forKeyPath:@"source"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

-(void)didChangeValueForKey:(NSString *)key {
    if ([key isEqualToString:@"source"]) {
        [self.tableView reloadData];
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.source count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView * cellView = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                             owner:self];
    cellView.textField.stringValue = [self tableView:tableView
                           objectValueForTableColumn:tableColumn
                                                 row:row];
    return cellView;
}

-(void)tableView:(NSTableView *)tableView
sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    BOOL ascending = [[[tableView sortDescriptors] firstObject] ascending];
    self.source = [self sortedSource:ascending];
}

-(NSArray *)sortedSource:(BOOL)ascending {
    return [self sortedSourceFromArray:self.source ascending:ascending];
}

-(NSArray *)sortedSourceFromArray:(NSArray *)array ascending:(BOOL)ascending {
    return [array sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2) {
        int n1 = [self hexdec:o1];
        int n2 = [self hexdec:o2];
        
        if (n1 == n2) {
            return NSOrderedSame;
        } else if (n1 < n2) {
            return ascending ? NSOrderedAscending : NSOrderedDescending;
        } else {
            return ascending ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
}

-(int)hexdec:(id)item {
    NSString * number = [[item name] stringByReplacingOccurrencesOfString:@"team"
                                                               withString:@""];
    NSScanner * s = [NSScanner scannerWithString:number];
    unsigned int n;
    if (![s scanHexInt:&n]) {
        return -1;
    }
    return n;
}

-(void)update:(void (^)(BOOL success))done {
}

-(void)updateSourceForApiCall:(NSString *)call withCreator:(id (^)(NSDictionary *))creator
                   andDone:(void (^)(BOOL success))done {
    self.source = [[NSArray alloc] init];
    [self requestLink:[NSString stringWithFormat:@"orgs/%@/%@", self.propra, call]
       withParameters:@{@"per_page": @100}
              success:^(AFHTTPRequestOperation *operation, id response) {
                  NSMutableArray * newSource = [NSMutableArray arrayWithArray:self.source];
                  for (NSDictionary * item in response) {
                      [newSource addObject:creator(item)];
                  }
                  self.source = [self sortedSourceFromArray:newSource
                                         ascending:[self.tableView.sortDescriptors.firstObject ascending]];
                  NSLog(@"%d", [self.source count]);
                  done(YES);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"JSON: %@", error);
                  done(NO);
              }];
}

-(void)requestLink:(NSString *)link withParameters:(NSDictionary *)parameters
           success:(void (^)(AFHTTPRequestOperation *operation, id response))success
           failure:(void (^)(AFHTTPRequestOperation *operation, id response))failure {
    
    [self.requestManager GET:link parameters:parameters
                     success:^(AFHTTPRequestOperation * operation, id response) {
                         success(operation, response);
                         NSString * next = [self nextPageLinkFromHeaders:operation.response.allHeaderFields];
                         if (next) {
                             [self requestLink:next withParameters:parameters
                                       success:success failure:failure];
                         }
                     }
                     failure:failure];
}

-(NSString *)nextPageLinkFromHeaders:(NSDictionary *)headers {
    NSString * next = nil;
    
    NSArray * linkHeaders = [[headers objectForKey:@"Link"]
                             componentsSeparatedByString:@", "];
    for (NSString * linkHeader in linkHeaders) {
        if ([linkHeader hasSuffix:@"rel=\"next\""]) {
            next = [self linkFromLinkHeader:linkHeader];
        }
    }
    return next;
}

-(NSString *)linkFromLinkHeader:(NSString *)linkHeader {
    NSString * pattern = @".*<(.+)>.*";
    NSString * replace = @"$1";
    NSRange range = NSMakeRange(0, linkHeader.length);
    
    NSRegularExpression * regex = [NSRegularExpression
                                   regularExpressionWithPattern:pattern
                                   options:0 error:NULL];
    
    
    return [regex stringByReplacingMatchesInString:linkHeader options:0
                                             range:range
                                      withTemplate:replace];
}

-(void)forAllGroups:(int)numGroups andTeams:(int)numTeams
                 do:(void(^)(NSString * group, BOOL lastOne))block {
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

-(void)post:(NSString *)type lastOne:(BOOL)lastOne withParams:(NSDictionary *)parameters
       done:(void (^)(BOOL success))done andStep:(void (^)(int numRepos))step {
    [self.requestManager POST:[NSString stringWithFormat:@"orgs/%@/%@", self.propra, type]
                   parameters:parameters
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
}

@end
