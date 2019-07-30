//
//  ASTNode.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/11.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASTHeader.h"
#import "ASTContext.h"
#import "ASTCallMethod.h"

@interface ASTNode : NSObject

@property(nonatomic,strong) NSMutableArray *allChilds;
@property(nonatomic,assign) ASTNodeType type;
@property(nonatomic,copy) NSString* keyword;

@property(nonatomic,assign) BOOL hasPointer;
@property(nonatomic,assign) BOOL hasBlock;
@property(nonatomic,strong) id value;

@property(nonatomic,strong) ASTContext* context;

- (void)addChild:(ASTNode *)node;
- (id)execute;

- (id)handleProperty;
@end

