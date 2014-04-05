//
//  Repository.h
//  Repomanager
//
//  Created by Tobias Witt on 04.04.14.
//  Copyright (c) 2014 this.done. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Repository : NSObject
@property (strong) NSString * name;
@property (assign) BOOL private;

-(id)initWithName:(NSString *)name private:(BOOL)private;
@end
