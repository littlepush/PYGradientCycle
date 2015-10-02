//
//  PYGradientCycle.m
//  PYGradientCycle
//
//  Created by Push Chen on 9/30/15.
//  Copyright © 2015 PushLab. All rights reserved.
//

/*
 LGPL V3 Lisence
 This file is part of cleandns.
 
 PYControllers is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 PYData is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with cleandns.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 LISENCE FOR IPY
 COPYRIGHT (c) 2013, Push Chen.
 ALL RIGHTS RESERVED.
 
 REDISTRIBUTION AND USE IN SOURCE AND BINARY
 FORMS, WITH OR WITHOUT MODIFICATION, ARE
 PERMITTED PROVIDED THAT THE FOLLOWING CONDITIONS
 ARE MET:
 
 YOU USE IT, AND YOU JUST USE IT!.
 WHY NOT USE THIS LIBRARY IN YOUR CODE TO MAKE
 THE DEVELOPMENT HAPPIER!
 ENJOY YOUR LIFE AND BE FAR AWAY FROM BUGS.
 */

#import "PYGradientCycle.h"
#import <UIKit/UIKit.h>

#ifndef PYFLOATEQUAL
#define PYFLOATEQUAL( f1, f2 )                  (ABS((f1) - (f2)) < 0.001)
#endif

@interface PYGradientCycle ()
{
    //CGFloat                     _percentage;
    
    PYGradientCycleStyle        _lineStyle;
    CGFloat                     _cycleHeavy;
    NSInteger                   _subDivCount;
    CGFloat                     _divRadius;
    CGPoint                     _center;
    CGFloat                     _dim;
    
    BOOL                        _gradientFill;
    UIColor                     *_fillColor;
    
    UIBezierPath                *_cellPath;
    NSTimer                     *_needsRecalculatePathTimer;
    
    //CGContextRef                _cachedContext;
    UIImage                     *_cachedImage;
}

@end

@implementation PYGradientCycle

/*!
 @brief Math method to calculate a point on the circle.
 */
- (CGPoint)_pointForTrapezoidWithAngle:(CGFloat)angle raidus:(CGFloat)radius withCenter:(CGPoint)center {
    return CGPointMake(center.x + radius * cos(angle), center.y + radius * sin(angle));
}

/*!
 @brief calculate the path according to current percentage
 */
- (UIBezierPath *)_cyclePathForPercentage:(CGFloat)percentage
{
    CGFloat _endAngle = (M_PI * 2 * percentage);
    UIBezierPath *_cyclePath = [UIBezierPath bezierPath];
    [_cyclePath moveToPoint:CGPointMake(_center.x, _center.y - _dim)];
    [_cyclePath addArcWithCenter:_center
                          radius:(_dim / 2)
                      startAngle:(-M_PI_2)
                        endAngle:(_endAngle - M_PI_2)
                       clockwise:YES];
    CGPoint _innerCycleEndPoint = [self _pointForTrapezoidWithAngle:(_endAngle - M_PI_2)
                                                             raidus:(_dim / 2 - _cycleHeavy)
                                                         withCenter:_center];
    
    if ( _lineStyle == PYGradientCycleStyleRound ) {
        CGPoint _currentPoint = _cyclePath.currentPoint;
        CGPoint _rightCenter = CGPointMake((_innerCycleEndPoint.x + _currentPoint.x) / 2,
                                           (_innerCycleEndPoint.y + _currentPoint.y) / 2);
        [_cyclePath addArcWithCenter:_rightCenter
                              radius:(_cycleHeavy / 2)
                          startAngle:(_endAngle - M_PI_2)
                            endAngle:(_endAngle + M_PI_2)
                           clockwise:YES];
    }
    
    [_cyclePath addArcWithCenter:_center
                          radius:(_dim / 2 - _cycleHeavy)
                      startAngle:(_endAngle - M_PI_2)
                        endAngle:(-M_PI_2)
                       clockwise:NO];
    
    if ( _lineStyle == PYGradientCycleStyleRound ) {
        CGPoint _leftCenter = CGPointMake(_center.x, (_center.y - _dim) + (_cycleHeavy / 2));
        [_cyclePath addArcWithCenter:_leftCenter
                              radius:(_cycleHeavy / 2)
                          startAngle:(M_PI_2)
                            endAngle:(-M_PI_2)
                           clockwise:YES];
    }
    
    [_cyclePath closePath];
    return _cyclePath;
}

/*!
 @brief Redraw the cache image according to the gradientCycleQuality, or frame changed
 */
- (void)_redrawCacheAndDisplay
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    CGContextRef _imageCtx = UIGraphicsGetCurrentContext();
    
    for ( int i = 0; i < _subDivCount; ++i ) {
        [self _internalDrawPieceCellAtIndex:i inContext:_imageCtx];
    }
    
    _cachedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplay];
}

/*!
 @brief Re-caclulate the div cell path, then re-draw the cache
 */
- (void)_calculateCellPath
{
    //PYLog(@"try to calculate cell path");
    _cellPath = [UIBezierPath bezierPath];
    [_cellPath moveToPoint:CGPointMake(_center.x, _center.y - _dim)];
    [_cellPath addArcWithCenter:_center radius:_dim / 2 startAngle:-M_PI_2 endAngle:_divRadius - M_PI_2 clockwise:YES];
    [_cellPath addLineToPoint:_center];
    [_cellPath closePath];
    
    // Reset the timer
    [_needsRecalculatePathTimer invalidate];
    _needsRecalculatePathTimer = nil;
    
    [self _redrawCacheAndDisplay];
}

/*!
 @brief Initialize
 */
- (void)_initializeDefaultParameters
{
    //_percentage = 0.f;
    _cycleHeavy = 10.f;
    _subDivCount = PYGradientCycleQualityNormal;
    _divRadius = M_PI * 2 / _subDivCount;
    _gradientFill = YES;
    _fillColor = [UIColor redColor];
    _lineStyle = PYGradientCycleStyleRound;
    
    _cellPath = nil;
    _needsRecalculatePathTimer = nil;
    _cachedImage = nil;
    [self setNeedsRecalculateCellPath];
    
    self.percentage = 0.f;
}

/*!
 @brief Re-calculate the path in the next runloop fire date.
 */
- (void)setNeedsRecalculateCellPath
{
    if ( _needsRecalculatePathTimer != nil ) return;
    _needsRecalculatePathTimer = [NSTimer
                                  timerWithTimeInterval:0
                                  target:self
                                  selector:@selector(_calculateCellPath)
                                  userInfo:nil
                                  repeats:NO];
    [[NSRunLoop currentRunLoop]
     addTimer:_needsRecalculatePathTimer
     forMode:NSRunLoopCommonModes];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    _dim = MIN(frame.size.width, frame.size.height);
    [self setNeedsRecalculateCellPath];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    _center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    _dim = MIN(bounds.size.width, bounds.size.height);
    [self setNeedsRecalculateCellPath];
}

@dynamic percentage;

@synthesize lineStyle = _lineStyle;
- (void)setLineStyle:(PYGradientCycleStyle)lineStyle
{
    [self willChangeValueForKey:@"lineStyle"];
    
    _lineStyle = lineStyle;
    [self setNeedsDisplay];
    
    [self didChangeValueForKey:@"lineStyle"];
}

@synthesize cycleHeavy = _cycleHeavy;
- (void)setCycleHeavy:(CGFloat)cycleHeavy
{
    [self willChangeValueForKey:@"cycleHeavy"];
    _cycleHeavy = cycleHeavy;
    [self setNeedsDisplay];
    
    [self didChangeValueForKey:@"cycleHeavy"];
}

@synthesize isGradientFill = _gradientFill;
- (void)setIsGradientFill:(BOOL)isGradientFill
{
    [self willChangeValueForKey:@"isGradientFill"];
    _gradientFill = isGradientFill;
    //[self _recalculatePercentagePath];
    [self setNeedsDisplay];
    
    [self didChangeValueForKey:@"isGradientFill"];
}

@synthesize gradientCycleQuality = _subDivCount;
- (void)setGradientCycleQuality:(NSInteger)gradientCycleQuality
{
    [self willChangeValueForKey:@"gradientCycleQuality"];
    _subDivCount = gradientCycleQuality;
    _divRadius = M_PI * 2 / _subDivCount;
    [self setNeedsRecalculateCellPath];
    
    [self didChangeValueForKey:@"gradientCycleQuality"];
}

@synthesize fillColor = _fillColor;
- (void)setFillColor:(UIColor *)fillColor
{
    [self willChangeValueForKey:@"fillColor"];
    _fillColor = fillColor;
    [self didChangeValueForKey:@"fillColor"];
    
    if ( _gradientFill == NO ) [self setNeedsDisplay];
}

- (id)init
{
    self = [super init];
    if ( self ) {
        self.contentsScale = [UIScreen mainScreen].scale;
        [self _initializeDefaultParameters];
        [self setMasksToBounds:YES];
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if ( self ) {
        if ( [layer isKindOfClass:[PYGradientCycle class]] ) {
            PYGradientCycle *_other = (PYGradientCycle *)layer;
            //_percentage = _other->_percentage;
            _cycleHeavy = _other->_cycleHeavy;
            _subDivCount = _other->_subDivCount;
            _divRadius = _other->_divRadius;
            _gradientFill = _other->_gradientFill;
            _fillColor = [_other->_fillColor copy];
            _lineStyle = _other->_lineStyle;
            _dim = _other->_dim;
            
            _cellPath = nil;
            _needsRecalculatePathTimer = nil;
            _cachedImage = [_other->_cachedImage copy];
            if ( _cachedImage == nil ) {
                [self _calculateCellPath];
            }
            
            self.percentage = _other.percentage;
            self.bounds = _other.bounds;
            //self.percentage = 0.f;
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ( [key isEqualToString:@"percentage"] ) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    if ( [event isEqualToString:@"percentage"] ) {
        CABasicAnimation *_anim = [CABasicAnimation animationWithKeyPath:event];
        _anim.fromValue = @([[self presentationLayer] percentage]);
        _anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _anim.duration = .5f;
        
        return _anim;
    }
    return [super actionForKey:event];
}

- (void)setPercentange:(CGFloat)percentange animateDuration:(CGFloat)duration
{
    if ( percentange > 1.f ) percentange = 1.f;
    
    CABasicAnimation *_percentageAnim = [CABasicAnimation animationWithKeyPath:@"percentage"];
    _percentageAnim.fromValue = @(self.percentage);
    _percentageAnim.toValue = @(percentange);
    _percentageAnim.duration = duration;
    _percentageAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self setPercentage:percentange];
    [self addAnimation:_percentageAnim forKey:@"percentage"];
}

- (void)_internalDrawPieceCellAtIndex:(NSInteger)index inContext:(CGContextRef)ctx
{
    // Transform
    CGContextTranslateCTM(ctx, self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGContextRotateCTM(ctx, index * _divRadius);
    CGContextTranslateCTM(ctx, -self.bounds.size.width / 2, -self.bounds.size.height / 2);
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    if ( _gradientFill ) {
        UIColor *_gColor = [UIColor colorWithHue:(float)index / _subDivCount saturation:1 brightness:1 alpha:1];
        CGContextSetFillColorWithColor(ctx, _gColor.CGColor);
    } else {
        CGContextSetFillColorWithColor(ctx, _fillColor.CGColor);
    }
    
    CGContextAddPath(ctx, _cellPath.CGPath);
    CGContextFillPath(ctx);
    
    CGContextTranslateCTM(ctx, self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGContextRotateCTM(ctx, -index * _divRadius);
    CGContextTranslateCTM(ctx, -self.bounds.size.width / 2, -self.bounds.size.height / 2);
}

- (void)drawInContext:(CGContextRef)ctx
{
    UIBezierPath *_circlePath = [self _cyclePathForPercentage:self.percentage];
    
    if ( _gradientFill ) {
        //[self _percentageCircleMaskImage];
        CGContextAddPath(ctx, _circlePath.CGPath);
        CGContextClip(ctx);
        CGContextDrawImage(ctx, self.bounds, _cachedImage.CGImage);
        //CGContextDrawImage(ctx, self.bounds, _maskedImage.CGImage);
    } else {
        CGContextSetFillColorWithColor(ctx, _fillColor.CGColor);
        CGContextAddPath(ctx, _circlePath.CGPath);
        CGContextFillPath(ctx);
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
