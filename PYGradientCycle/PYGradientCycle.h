//
//  PYGradientCycle.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PYGradientCycleQuality) {
    PYGradientCycleQualityLow = 128,
    PYGradientCycleQualityNormal = 256,
    PYGradientCycleQualityHigh = 512,
    PYGradientCycleQualityUltra = 1024
};

typedef NS_ENUM(NSInteger, PYGradientCycleStyle) {
    PYGradientCycleStyleHard,
    PYGradientCycleStyleRound,
};

@interface PYGradientCycle : CALayer

/*!
 @brief If support implict animation, default is NO;
 */
@property (nonatomic, assign)   BOOL                    isSupportImplictAnimation;

/*!
 @brief The percentage of the cycle. 0 - 1, in float
 */
@property (nonatomic)           CGFloat                 percentage;

/*!
 @brief The syle of the line, default is PYGradientCycleStyleRound
 */
@property (nonatomic, assign)   PYGradientCycleStyle    lineStyle;

/*!
 @brief The heavy of the cycle, default is 10px
 */
@property (nonatomic, assign)   CGFloat                 cycleHeavy;

/*!
 @brief if use a gradient color to fill the cycle. Default is YES
 */
@property (nonatomic, assign)   BOOL                    isGradientFill;

/*!
 @brief the quality of the gradient, default is PYGradientCycleQualityNormal
 */
@property (nonatomic, assign)   NSInteger               gradientCycleQuality;

/*!
 @brief the color to fill the cycle when not gradient fill. Default is RED
 */
@property (nonatomic, strong)   UIColor                 *fillColor;

/*!
 @brief update the percentage of the cycle in specified duration.
 */
- (void)setPercentage:(CGFloat)percentage animateDuration:(CGFloat)duration;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
