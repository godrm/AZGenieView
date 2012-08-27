//
//  AZGenieView.h
//  GenieTest
//
//  Created by Jung Kim on 12. 8. 24..
//  Copyright (c) 2012년 AuroraPlanet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AZANIMATION_FRAMERATE 30
#define DRAW_PATH 1
#define PROCESS_ANIMATION 1

@protocol AZGenieAnimationDelegate
@optional
- (void)geineAnimationDone;
@end

@interface AZGenieView : UIView
{
    bool isAnimation;
    NSMutableArray *allFrames;
    NSMutableArray *reverseFrames;
    NSMutableArray *slices;
    CGRect renderFrame;
    CGRect targetFrame;
    float  sliceHeight;
    float  leftX[960], rightX[960];
    NSTimer *doneTimer;
    UIImageView *animationView;
}

@property (strong, nonatomic) UIImage *renderImage;
@property (assign, nonatomic) CGPathRef renderPath;
@property (assign, nonatomic) id<AZGenieAnimationDelegate> delegate;

- (void)setRenderFrame:(CGRect)renderFrame andTargetFrame:(CGRect)targetFrame;
- (void)genieAnimationShow:(bool)showing withDuration:(NSTimeInterval)duration;

@end
