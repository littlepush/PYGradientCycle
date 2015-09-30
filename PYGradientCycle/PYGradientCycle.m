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
    CGFloat                     _percentage;
    
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
    
    CGFloat                     _percentageBeforeAnimation;
    CGFloat                     _percentageAfterAnimation;
    CADisplayLink               *_percentageDisplayLink;
    CGFloat                     _percentageAnimationDuration;
}

@end

@implementation PYGradientCycle

- (CGPoint)pointForTrapezoidWithAngle:(CGFloat)angle raidus:(CGFloat)radius withCenter:(CGPoint)center {
    return CGPointMake(center.x + radius * cos(angle), center.y + radius * sin(angle));
}

- (void)_calculateCellPath
{
    //PYLog(@"try to calculate cell path");
    _cellPath = [UIBezierPath bezierPath];
    [_cellPath moveToPoint:CGPointMake(_center.x, 0)];
    [_cellPath addArcWithCenter:_center radius:_dim / 2 startAngle:-M_PI_2 endAngle:_divRadius - M_PI_2 clockwise:YES];
    CGPoint _innerArcEndPoint = [self pointForTrapezoidWithAngle:_divRadius - M_PI_2 raidus:_dim / 2 - _cycleHeavy withCenter:_center];
    
    if ( _lineStyle == PYGradientCycleStyleRound ) {
        CGPoint _currentPoint = _cellPath.currentPoint;
        CGPoint _rightCenter = CGPointMake((_innerArcEndPoint.x + _currentPoint.x) / 2, (_innerArcEndPoint.y + _currentPoint.y) / 2);
        [_cellPath addArcWithCenter:_rightCenter radius:_cycleHeavy / 2 startAngle:(_divRadius - M_PI_2) endAngle:(_divRadius + M_PI_2) clockwise:YES];
    } else {
        [_cellPath addLineToPoint:_innerArcEndPoint];
    }
    
    [_cellPath addArcWithCenter:_center radius:_dim / 2 - _cycleHeavy startAngle:_divRadius - M_PI_2 endAngle:-M_PI_2 clockwise:NO];
    
    if ( _lineStyle == PYGradientCycleStyleRound ) {
        CGPoint _leftCenter = CGPointMake(_center.x, _cycleHeavy / 2);
        [_cellPath addArcWithCenter:_leftCenter radius:_cycleHeavy / 2 startAngle:M_PI_2 endAngle:-M_PI_2 clockwise:YES];
    }
    
    [_cellPath closePath];
    
    // Reset the timer
    [_needsRecalculatePathTimer invalidate];
    _needsRecalculatePathTimer = nil;
    
    [self setNeedsDisplay];
}

- (void)_initializeDefaultParameters
{
    _percentage = 0.f;
    _cycleHeavy = 10.f;
    _subDivCount = PYGradientCycleQualityNormal;
    _divRadius = M_PI * 2 / _subDivCount;
    _gradientFill = YES;
    _fillColor = [UIColor redColor];
    _lineStyle = PYGradientCycleStyleRound;
    
    _cellPath = nil;
    _needsRecalculatePathTimer = nil;
    [self setNeedsRecalculateCellPath];
}

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

@synthesize percentange = _percentage;
- (void)setPercentange:(CGFloat)percentange
{
    [self willChangeValueForKey:@"percentage"];
    
    if ( percentange > 1.f ) percentange = 1.f;
    // Set the percentage
    _percentage = percentange;
    [self setNeedsDisplay];
    
    [self didChangeValueForKey:@"percentage"];
}

@synthesize lineStyle = _lineStyle;
- (void)setLineStyle:(PYGradientCycleStyle)lineStyle
{
    [self willChangeValueForKey:@"lineStyle"];
    
    _lineStyle = lineStyle;
    [self setNeedsRecalculateCellPath];
    
    [self didChangeValueForKey:@"lineStyle"];
}
@synthesize cycleHeavy = _cycleHeavy;
- (void)setCycleHeavy:(CGFloat)cycleHeavy
{
    [self willChangeValueForKey:@"cycleHeavy"];
    _cycleHeavy = cycleHeavy;
    [self didChangeValueForKey:@"cycleHeavy"];
    [self setNeedsRecalculateCellPath];
}

@synthesize isGradientFill = _gradientFill;
- (void)setIsGradientFill:(BOOL)isGradientFill
{
    [self willChangeValueForKey:@"isGradientFill"];
    _gradientFill = isGradientFill;
    [self didChangeValueForKey:@"isGradientFill"];
    [self setNeedsDisplay];
}

@synthesize gradientCycleQuality = _subDivCount;
- (void)setGradientCycleQuality:(NSInteger)gradientCycleQuality
{
    [self willChangeValueForKey:@"gradientCycleQuality"];
    _subDivCount = gradientCycleQuality;
    _divRadius = M_PI * 2 / _subDivCount;
    [self didChangeValueForKey:@"gradientCycleQuality"];
    [self setNeedsRecalculateCellPath];
    if ( _gradientFill ) [self setNeedsDisplay];
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
    }
    return self;
}

- (void)setPercentange:(CGFloat)percentange animateDuration:(CGFloat)duration
{
    if ( percentange > 1.f ) percentange = 1.f;
    _percentageBeforeAnimation = _percentage;
    _percentageAfterAnimation = percentange;
    _percentageAnimationDuration = duration;
    
    if ( _percentageDisplayLink ) return;
    _percentageDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_percentageAnimationEvent)];
    [_percentageDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)_percentageAnimationEvent
{
    if ( PYFLOATEQUAL(_percentage, _percentageAfterAnimation) ) {
        [_percentageDisplayLink invalidate];
        _percentageDisplayLink = nil;
        return;
    }
    CGFloat _deltaPercentage = (_percentageAfterAnimation - _percentageBeforeAnimation);
    CGFloat _deltaEachTime = _percentageAnimationDuration / _percentageDisplayLink.duration;
    CGFloat _deltaPercentageEachTime = _deltaPercentage / _deltaEachTime;
    _percentage += _deltaPercentageEachTime;
    [self setNeedsDisplay];
}

- (void)_internalDrawPieceCellAtIndex:(NSInteger)index inContext:(CGContextRef)ctx
{
    // Transform
    CGContextTranslateCTM(ctx, self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGContextRotateCTM(ctx, index * _divRadius);
    CGContextTranslateCTM(ctx, -self.bounds.size.width / 2, -self.bounds.size.height / 2);
    
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
    int _pieceCount = _subDivCount * self.percentange;
    for ( NSInteger i = 0; i < _pieceCount; ++i ) {
        [self _internalDrawPieceCellAtIndex:(int)i inContext:ctx];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
