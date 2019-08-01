//
//  ASTVariable.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/21.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASTHeader.h"

@interface ASTVariable : NSObject
@property(nonatomic,assign) ASTNodeType type;
@property(nonatomic,strong) id name;
@property(nonatomic,strong) id value;

// ASTNodeTypeKeyword value
@property(nonatomic,copy) NSString* keyword;
@property(nonatomic,assign) BOOL hasPointer;
@property(nonatomic,assign) BOOL hasBlock;

// for i++/i--
@property(nonatomic,copy) void (^postOperation)(void);

// for return/continue/break
@property(nonatomic,assign) ASTJumpType jumpType;

- (instancetype)toMutableCopy;
@end

