//
//  ASTUtil.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/14.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ASTNode.h"
#import "ASTHeader.h"

#import "ASTVariable.h"

#import "ASTPropertyNode.h"
#import "ASTMethodNode.h"
@class ASTType;

extern ASTNode* gblRootNode;
extern NSMutableDictionary* gblVariables;

@interface ASTUtil : NSObject

+ (ASTNode*) int_node:(int)value;
+ (ASTNode*) double_node:(double)value;
+ (ASTNode*) string_node:(NSString*)value;
+ (ASTNode*) bool_node:(BOOL)value;
+ (ASTNode*) keyword_node:(NSString*)value;
+ (ASTNode*) variable_node:(NSString*)value;
+ (ASTNode*) placeholder_node;

+ (ASTNode*) op_node:(ASTNodeType)type;
+ (ASTPropertyNode*) property_node;
+ (ASTNode*) unarySelector_node:(NSString*)value;

+ (void)castTypeFromValue:(ASTVariable*)objc;

+(BOOL)checkOCStructType:(id)objc;
+(void)defaultValueForOCStruct:(ASTVariable*)variable;

+(BOOL)checkOCContainerIndexType:(ASTNodeType)type;
+(BOOL)callCFunctionWhitelist:(NSString*)func;


+(ASTNode*)parseString:(NSString*)text;

+ (ASTType*)typeForNodeType:(ASTNodeType)type keyword:(NSString*)keyword;
+ (ASTContext*)linkContextToRoot:(ASTNode*)rootNode;
+ (void)registerVariableForYacc:(NSString*)key;
@end

