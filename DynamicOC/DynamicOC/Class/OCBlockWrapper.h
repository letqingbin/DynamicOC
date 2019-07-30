//
//  JPBlockWrapper.h
//  JSPatch
//
//  Created by bang on 1/19/17.
//  Copyright © 2017 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASTNode.h"
#import "ASTBlockNode.h"

@interface OCBlockWrapper : NSObject

+ (instancetype)blockWrapperWithNode:(ASTBlockNode *)node;
- (void *)blockPtr;
+ (id)excuteBlock:(id)block withParams:(NSArray *)params;
@end
