//
//  Team.h
//  Repomanager
//
//  Created by Tobias Witt on 04.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Team : NSObject
@property (assign) int id;
@property (strong) NSString * name;
@property (strong) NSString * repoName;

-(id)initWithId:(int)id name:(NSString *)name;
-(BOOL)hasRepo;
@end
