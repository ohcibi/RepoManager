//
//  Team.m
//  Repomanager
//
//  Created by Tobias Witt on 04.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import "Team.h"

@implementation Team

-(id)initWithId:(int)id name:(NSString *)name {
    if (self = [super init]) {
        self.id = id;
        self.name = name;
    }
    return self;
}

-(BOOL)hasRepo {
    return nil != self.repoName;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%i,%@", self.id, self.name];
}

@end
