//
//  ASTCallMethod.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/19.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASTCallMethod : NSObject

+ (id)nilObj;

+ (id)invokeWithCaller:(id)caller selectorName:(NSString *)selectorName argments:(NSArray *)arguments;
+ (id)invokeWithInvocation:(NSInvocation *)invocation argments:(NSArray *)arguments;

@end

