//
//  ASTContext.m
//  DynamicOC
//
//  Created by dKingbin on 2019/7/19.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTContext.h"

#import "ASTCallMethod.h"
#import "ASTVariable.h"

@interface ASTContext()
@property(nonatomic,strong) NSMutableArray* contexts;
@property(nonatomic,strong) NSMutableDictionary* currentCtx;
@end

@implementation ASTContext

- (void)pushValue:(id)value forKey:(NSString*)key
{
	if(!self.currentCtx)
	{
		[self pushContext];
	}

	if(value == nil)
	{
		value = [ASTCallMethod nilObj];
	}

	for(int i=(int)self.contexts.count-1;i>=0;i--)
	{
		id ctx = self.contexts[i];
		BOOL isKnown = [self isKnownKey:key At:ctx];
		if(isKnown)
		{
			[ctx setValue:value forKey:key];
			return;
		}
	}

	[self.currentCtx setValue:value forKey:key];
}

- (id)fetchValueFromKey:(NSString*)key
{
    ASTVariable* empty = [[ASTVariable alloc]init];
    empty.value = nil;
    
	if(self.contexts.count == 0) return empty;

	for(int i=(int)self.contexts.count-1;i>=0;i--)
	{
		id ctx = self.contexts[i];
		BOOL isKnown = [self isKnownKey:key At:ctx];
		if(isKnown)
		{
			return [ctx valueForKey:key];
		}
	}

	return empty;
}

- (BOOL)isKnownKey:(NSString*)key
{
	__block BOOL isKnown = NO;
	for(int i=(int)self.contexts.count-1;i>=0;i--)
	{
		id ctx = self.contexts[i];
		isKnown = [self isKnownKey:key At:ctx];
		if(isKnown)
		{
			break;
		}
	}

	return isKnown;
}

- (BOOL)isKnownKey:(NSString*)key At:(NSMutableDictionary*)ctx
{
	__block BOOL isKnown = NO;
	[ctx enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull var, id  _Nonnull obj, BOOL * _Nonnull stop) {
		if([var isEqualToString:key])
		{
			isKnown = YES;
			*stop = YES;
		}
	}];

	return isKnown;
}

- (void)pushContext
{
	NSMutableDictionary* ctx = [NSMutableDictionary dictionary];
	[self.contexts addObject:ctx];

	self.currentCtx = ctx;
}

- (void)pushDefinedContext:(NSMutableDictionary*)ctx
{
    if(!ctx) return;
    
    [self.contexts addObject:ctx];
    self.currentCtx = ctx;
}

- (void)popContext
{
	if(!self.currentCtx) return;

	[self.contexts removeLastObject];
	self.currentCtx = [self.contexts lastObject];
}

- (void)clearAllContexts
{
    self.currentCtx = nil;
    [self.contexts removeAllObjects];
}

- (NSMutableArray *)contexts
{
	if(!_contexts)
	{
		_contexts = [NSMutableArray array];
	}

	return _contexts;
}

@end
