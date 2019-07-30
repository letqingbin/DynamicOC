//
//  ASTContext.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/19.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASTContext : NSObject

- (void)pushValue:(id)value forKey:(NSString*)key;
- (id)fetchValueFromKey:(NSString*)key;

- (void)pushContext;
- (void)pushDefinedContext:(NSMutableDictionary*)ctx;
- (void)popContext;
- (void)clearAllContexts;

- (BOOL)isKnownKey:(NSString*)key;
- (BOOL)isKnownKey:(NSString*)key At:(NSMutableDictionary*)ctx;

@end

