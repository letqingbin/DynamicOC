//
//  ASTPropertyNode.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/15.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTNode.h"
#import "ASTHeader.h"

typedef enum {
    ASTPropertyHandleTypeDefaultGetter = 0,
    ASTPropertyHandleTypeDefualtSetter,
} ASTPropertyHandleType;

@interface ASTPropertyNode : ASTNode
@property(nonatomic,strong) ASTNode* invoker;
@property(nonatomic,copy) NSString* selector;	//property

@property(nonatomic,assign) ASTPropertyHandleType handleType;
@property(nonatomic,strong) id setterVaule;


@end

