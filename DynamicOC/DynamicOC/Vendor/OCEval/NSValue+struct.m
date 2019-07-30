//
//  NSValue+struct.m
//  OCEval
//
//  Created by sgcy on 2018/11/27.
//
#import "NSValue+struct.h"

@implementation NSValue(structt)

//CGPoint,CGSize,CGRect
- (id)setX:(CGFloat)x
{
	CGPoint point = [self CGPointValue];
	point.x = x;
	return [NSValue valueWithCGPoint:point];
}

- (CGFloat)x
{
	CGPoint point = [self CGPointValue];
    return point.x;
}

- (id)setY:(CGFloat)y
{
	CGPoint point = [self CGPointValue];
	point.y = y;
	return [NSValue valueWithCGPoint:point];
}

- (CGFloat)y
{
	CGPoint point = [self CGPointValue];
	return point.y;
}

- (id)setWidth:(CGFloat)width
{
    CGSize size = [self CGSizeValue];
    size.width = width;
    return [NSValue valueWithCGSize:size];
}

- (CGFloat)width
{
    CGSize size = [self CGSizeValue];
    return size.width;
}

- (id)setHeight:(CGFloat)height
{
    CGSize size = [self CGSizeValue];
    size.height = height;
    return [NSValue valueWithCGSize:size];
}

- (CGFloat)height
{
    CGSize size = [self CGSizeValue];
    return size.height;
}

- (id)setOrigin:(CGPoint)origin
{
    CGRect rect = [self CGRectValue];
    rect.origin = origin;
    
    return [NSValue valueWithCGRect:rect];
}

- (id)setSize:(CGSize)size
{
    CGRect rect = [self CGRectValue];
    rect.size = size;
    
    return [NSValue valueWithCGRect:rect];
}

- (CGPoint)origin
{
    CGRect rect = [self CGRectValue];
    return rect.origin;
}

- (CGSize)size
{
    CGRect rect = [self CGRectValue];
    return rect.size;
}

//NSRange
- (id)setLocation:(NSUInteger)location
{
    NSRange range = [self rangeValue];
    range.location = location;
    return [NSValue valueWithRange:range];
}

- (NSUInteger)location
{
    NSRange range = [self rangeValue];
    return range.location;
}

- (id)setLength:(NSUInteger)length
{
    NSRange range = [self rangeValue];
    range.length = length;
    return [NSValue valueWithRange:range];
}

- (NSUInteger)length
{
    NSRange range = [self rangeValue];
    return range.length;
}

//UIOffset
- (id)setHorizontal:(CGFloat)horizontal
{
    UIOffset offset = [self UIOffsetValue];
    offset.horizontal = horizontal;
    return [NSValue valueWithUIOffset:offset];
}

- (CGFloat)horizontal
{
    UIOffset offset = [self UIOffsetValue];
    return offset.horizontal;
}

- (id)setVertical:(CGFloat)vertical
{
    UIOffset offset = [self UIOffsetValue];
    offset.vertical = vertical;
    return [NSValue valueWithUIOffset:offset];
}

- (CGFloat)vertical
{
    UIOffset offset = [self UIOffsetValue];
    return offset.vertical;
}

//UIEdgeInsets
- (id)setTop:(CGFloat)top
{
	UIEdgeInsets inset = [self UIEdgeInsetsValue];
	inset.top = top;
	return [NSValue valueWithUIEdgeInsets:inset];
}

- (CGFloat)top
{
	UIEdgeInsets inset = [self UIEdgeInsetsValue];
	return inset.top;
}

- (id)setLeft:(CGFloat)left
{
	UIEdgeInsets inset = [self UIEdgeInsetsValue];
	inset.left = left;
	return [NSValue valueWithUIEdgeInsets:inset];
}

- (CGFloat)left
{
	UIEdgeInsets inset = [self UIEdgeInsetsValue];
	return inset.left;
}

- (id)setBottom:(CGFloat)bottom
{
	UIEdgeInsets inset = [self UIEdgeInsetsValue];
	inset.bottom = bottom;
	return [NSValue valueWithUIEdgeInsets:inset];
}

- (CGFloat)bottom
{
	UIEdgeInsets inset = [self UIEdgeInsetsValue];
	return inset.bottom;
}

- (id)setRight:(CGFloat)right
{
	UIEdgeInsets inset = [self UIEdgeInsetsValue];
	inset.right = right;
	return [NSValue valueWithUIEdgeInsets:inset];
}

- (CGFloat)right
{
	UIEdgeInsets inset = [self UIEdgeInsetsValue];
	return inset.right;
}

//CGVector
- (id)setDx:(CGFloat)dx
{
    CGVector vector = [self CGVectorValue];
    vector.dx = dx;
    return [NSValue valueWithCGVector:vector];
}

- (CGFloat)dx
{
    CGVector vector = [self CGVectorValue];
    return vector.dx;
}

- (id)setDy:(CGFloat)dy
{
    CGVector vector = [self CGVectorValue];
    vector.dy = dy;
    return [NSValue valueWithCGVector:vector];
}

- (CGFloat)dy
{
    CGVector vector = [self CGVectorValue];
    return vector.dy;
}



@end
