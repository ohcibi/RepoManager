//
//  Repository.m
//  Repomanager
//
//  Created by Tobias Witt on 04.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import "Repository.h"

@implementation Repository
-(id)initWithName:(NSString *)name private:(BOOL)private {
    if (self = [super init]) {
        self.name = name;
        self.private = private;
    }
    return self;
}
@end
