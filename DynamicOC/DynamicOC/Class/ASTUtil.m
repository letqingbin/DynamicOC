//
//  ASTUtil.m
//  DynamicOC
//
//  Created by dKingbin on 2019/7/14.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTUtil.h"
#import "ASTType.h"

ASTNode* gblRootNode = nil;
NSMutableDictionary* gblVariables = nil;

@interface ASTUtil()

@end

@implementation ASTUtil

+ (void)load
{
	if(!gblVariables)
	{
		gblVariables = [NSMutableDictionary dictionary];
	}

	//self/super initial as variable
	[gblVariables setObject:@"" forKey:@"self"];
	[gblVariables setObject:@"" forKey:@"super"];
}

+ (ASTNode*)int_node:(int)value
{
    ASTNode* node = [[ASTNode alloc]init];
    node.type = ASTNodeTypeInt;
    node.value = @(value);
    return node;
}

+ (ASTNode*)double_node:(double)value
{
    ASTNode* node = [[ASTNode alloc]init];
    node.type = ASTNodeTypeDouble;
    node.value = @(value);
    return node;
}

+ (ASTNode*)string_node:(NSString*)value
{
    ASTNode* node = [[ASTNode alloc]init];
    node.type = ASTNodeTypeString;
    node.value = value;
    return node;
}

+ (ASTNode*)bool_node:(BOOL)value
{
    ASTNode* node = [[ASTNode alloc]init];
    node.type = ASTNodeTypeBOOL;
    node.value = @(value);
    return node;
}

+ (ASTNode*) keyword_node:(NSString*)value
{
	ASTNode* node = [[ASTNode alloc]init];
	node.type = ASTNodeTypeKEYWORD;
    node.keyword = value;
	return node;
}

+ (ASTNode*)variable_node:(NSString*)value
{
	ASTNode* node = [[ASTNode alloc]init];
	node.type = ASTNodeTypeVariable;
	node.value = value;
	return node;
}

+ (ASTNode*) op_node:(ASTNodeType)type
{
    ASTNode* node = [[ASTNode alloc]init];
    node.type = type;
    return node;
}

+ (ASTPropertyNode*)property_node
{
	ASTPropertyNode* node = [[ASTPropertyNode alloc]init];
	node.type = ASTNodeTypeProperty;
	return node;
}

+ (ASTNode*)unarySelector_node:(NSString*)value
{
	ASTNode* node = [[ASTNode alloc]init];
	node.type = ASTNodeTypeUnarySelector;
	node.value = value;
	return node;
}

+ (ASTNode*)placeholder_node
{
    ASTNode* node = [[ASTNode alloc]init];
    node.type = ASTNodeTypePlaceholder;
    
    return node;
}


+(NSString*)nodeKey:(ASTNodeType)type keyword:(NSString*)keyword
{
    if(type != ASTNodeTypeKEYWORD) keyword = nil;
    if(keyword == nil) keyword = @"";
    
    NSString* key = [NSString stringWithFormat:@"%d##%@",type,keyword];
    return key;
}

//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
+ (void)castTypeFromValue:(ASTVariable*)objc
{
    if(![objc.value respondsToSelector:@selector(objCType)])
    {
        return;
    }
    
    const char* c = [objc.value objCType];
    
    #define DC_CAST_TYPE(_val, _typeString, _nodeType, _keyword) \
        if(strcmp(_typeString, _val) == 0) { \
            objc.type = _nodeType;  \
            objc.keyword = _keyword;\
            return;\
        }
    
    DC_CAST_TYPE(c, @encode(char), ASTNodeTypeChar, nil)
    DC_CAST_TYPE(c, @encode(unsigned char), ASTNodeTypeUnsignedChar, nil)
    DC_CAST_TYPE(c, @encode(short), ASTNodeTypeShort, nil)
    DC_CAST_TYPE(c, @encode(unsigned short), ASTNodeTypeUnsignedShort, nil)
    DC_CAST_TYPE(c, @encode(int), ASTNodeTypeInt, nil)
    DC_CAST_TYPE(c, @encode(unsigned int), ASTNodeTypeUnsignedInt, nil)
    DC_CAST_TYPE(c, @encode(long), ASTNodeTypeLong, nil)
    DC_CAST_TYPE(c, @encode(unsigned long), ASTNodeTypeUnsignedLong, nil)
    DC_CAST_TYPE(c, @encode(float), ASTNodeTypeFloat, nil)
    DC_CAST_TYPE(c, @encode(double), ASTNodeTypeDouble, nil)
    DC_CAST_TYPE(c, @encode(BOOL), ASTNodeTypeBOOL, nil)
    DC_CAST_TYPE(c, @encode(void), ASTNodeTypeVoid, nil)
    DC_CAST_TYPE(c, @encode(CGFloat), ASTNodeTypeFloat, nil)
    DC_CAST_TYPE(c, @encode(void), ASTNodeTypeVoid, nil)
    DC_CAST_TYPE(c, @encode(id), ASTNodeTypeKEYWORD, @"id")
    DC_CAST_TYPE(c, @encode(size_t), ASTNodeTypeKEYWORD, @"size_t")
    DC_CAST_TYPE(c, @encode(CGSize), ASTNodeTypeKEYWORD, @"CGSize")
    DC_CAST_TYPE(c, @encode(CGRect), ASTNodeTypeKEYWORD, @"CGRect")
    DC_CAST_TYPE(c, @encode(CGPoint), ASTNodeTypeKEYWORD, @"CGPoint")
    DC_CAST_TYPE(c, @encode(NSRange), ASTNodeTypeKEYWORD, @"NSRange")
    DC_CAST_TYPE(c, @encode(CGVector), ASTNodeTypeKEYWORD, @"CGVector")
    DC_CAST_TYPE(c, @encode(Class), ASTNodeTypeKEYWORD, @"Class")
    DC_CAST_TYPE(c, @encode(SEL), ASTNodeTypeKEYWORD, @"SEL")
    DC_CAST_TYPE(c, @encode(void*), ASTNodeTypeKEYWORD, @"void*")
}

+(BOOL)checkOCStructType:(id)objc
{
	if(![objc respondsToSelector:@selector(objCType)])
	{
		return NO;
	}

	const char* c = [objc objCType];

#define DC_CHECK_STRUCT_TYPE(_val, _typeString) \
if(strcmp(_typeString, _val) == 0) { \
return YES; \
}

	DC_CHECK_STRUCT_TYPE(c, @encode(CGSize))
	DC_CHECK_STRUCT_TYPE(c, @encode(CGRect))
	DC_CHECK_STRUCT_TYPE(c, @encode(CGPoint))
	DC_CHECK_STRUCT_TYPE(c, @encode(CGVector))
	DC_CHECK_STRUCT_TYPE(c, @encode(NSRange))
	DC_CHECK_STRUCT_TYPE(c, @encode(UIEdgeInsets))
	DC_CHECK_STRUCT_TYPE(c, @encode(UIOffset))
	DC_CHECK_STRUCT_TYPE(c, @encode(CGAffineTransform))

	return NO;
}

+(void)defaultValueForOCStruct:(ASTVariable*)variable
{
	if(variable.type != ASTNodeTypeKEYWORD || ![ASTUtil checkOCStructType:variable.value]) return;

	#define DC_OCSTRUCT_DEFAULT(_type, _caller, _default) \
	if ([_type isEqualToString:_caller.keyword]){ \
		_caller.value = (_default);\
        [ASTUtil castTypeFromValue:_caller];\
		return; \
	}

	DC_OCSTRUCT_DEFAULT(@"CGSize", variable, @(CGSizeZero))
	DC_OCSTRUCT_DEFAULT(@"CGRect", variable, @(CGRectZero))
	DC_OCSTRUCT_DEFAULT(@"CGPoint", variable, @(CGSizeZero))
	DC_OCSTRUCT_DEFAULT(@"CGVector",variable, @(CGVectorMake(0, 0)))

	DC_OCSTRUCT_DEFAULT(@"UIEdgeInsets", variable, [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero])
	DC_OCSTRUCT_DEFAULT(@"NSRange", variable, [NSValue valueWithRange:NSMakeRange(0, 0)])
	DC_OCSTRUCT_DEFAULT(@"UIOffset", variable, [NSValue valueWithUIOffset:UIOffsetMake(0, 0)])
	DC_OCSTRUCT_DEFAULT(@"CGAffineTransform", variable, [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity])
}

+(BOOL)checkOCContainerIndexType:(ASTNodeType)type
{
	if(type >= ASTNodeTypeShort && type <= ASTNodeTypeUnsignedLong)
	{
		//array
		return YES;
	}

	//dictionary
	return NO;
}

+(BOOL)callCFunctionWhitelist:(NSString*)func
{
	static NSMutableArray* whitelist = nil;
	if(!whitelist)
	{
		whitelist = [NSMutableArray array];
        
        [whitelist addObject:@"CGRectZero"];
        [whitelist addObject:@"CGPointZero"];
        [whitelist addObject:@"CGSizeZero"];
        [whitelist addObject:@"UIEdgeInsetsZero"];
		[whitelist addObject:@"dispatch_after"];
	}

	if([whitelist containsObject:func]) return YES;

	return NO;
}

static NSMutableDictionary* _typeEncodeDict = nil;
+ (ASTType*)typeForNodeType:(ASTNodeType)type keyword:(NSString*)keyword
{
    if(!_typeEncodeDict)
    {
        _typeEncodeDict = [NSMutableDictionary dictionary];
        
       
        #define DC_TYPE_MAP_NODETYPE(_nodeType, _type, _typeString) { \
            ASTType* ast_ = [[ASTType alloc]init]; \
            ast_.type = _nodeType; \
            ast_.keyword = _typeString; \
            ast_.typeEncode = [NSString stringWithUTF8String:@encode(_type)]; \
            NSString* key_ = [ASTUtil nodeKey:_nodeType keyword:ast_.keyword]; \
            [_typeEncodeDict setObject:ast_ forKey:key_]; }
        
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeChar, char, @"char")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeUnsignedChar,unsigned char, @"unsigned char")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeShort, short, @"short")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeUnsignedShort, unsigned short, @"unsigned char")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeInt, int, @"int")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeUnsignedInt, unsigned int, @"unsigned int")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeLong, long, @"long")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeUnsignedLong, unsigned long, @"unsigned long")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeFloat, float, @"float")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeDouble, double, @"double")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeBOOL, BOOL, @"BOOL")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeVoid, void, @"void")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, id, @"id")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, size_t, @"size_t")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, CGSize, @"CGSize")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, CGRect, @"CGRect")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, CGPoint, @"CGPoint")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, CGVector, @"CGVector")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, NSRange, @"NSRange")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, Class, @"Class")
        DC_TYPE_MAP_NODETYPE(ASTNodeTypeKEYWORD, SEL, @"SEL")
    }

    NSString* key = [ASTUtil nodeKey:type keyword:keyword];

    return _typeEncodeDict[key];
}

+ (ASTContext*)linkContextToRoot:(ASTNode*)rootNode
{
    rootNode.context = [ASTContext new];
	[ASTUtil linkAllContext:rootNode ctx:rootNode.context];
	return rootNode.context;
}

+ (void)linkAllContext:(ASTNode*)root ctx:(ASTContext*)context
{
	for(ASTNode* node in root.allChilds)
	{
		node.context = context;
		[ASTUtil linkAllContext:node ctx:context];
	}

	if(root.value != nil && [root.value isKindOfClass:ASTNode.class])
	{
		ASTNode* node = root.value;
		node.context  = context;
		[ASTUtil linkAllContext:node ctx:context];
	}
    
    if([root isMemberOfClass:ASTPropertyNode.class])
    {
        ASTPropertyNode* propertyNode = (ASTPropertyNode*)root;
        ASTNode* node = propertyNode.invoker;
        node.context  = context;
        [ASTUtil linkAllContext:node ctx:context];
    }
    
    if([root isMemberOfClass:ASTMethodNode.class])
    {
        ASTMethodNode* methodNode = (ASTMethodNode*)root;
        ASTNode* node = methodNode.argument;
        node.context  = context;
        [ASTUtil linkAllContext:node ctx:context];
    }
}

+ (void)registerVariableForYacc:(NSString*)key
{
	if(!gblVariables)
	{
		gblVariables = [NSMutableDictionary dictionary];
	}

	[gblVariables setValue:@"" forKey:key];
}

+(ASTNode*)parseString:(NSString*)text
{
	gblRootNode = nil;

	YY_BUFFER_STATE buf;
	buf = yy_scan_string([text cStringUsingEncoding:NSUTF8StringEncoding]);
	yyparse();
	yy_delete_buffer(buf);

    [ASTUtil linkContextToRoot:gblRootNode];
    
	return gblRootNode;
}


@end
