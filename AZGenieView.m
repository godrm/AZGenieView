//
//  AZGenieView.m
//  GenieTest
//
//  Created by Jung Kim on 12. 8. 24..
//  Copyright (c) 2012년 AuroraPlanet. All rights reserved.
//

#import "AZGenieView.h"

@implementation AZGenieView

//For before Xcode 4.4
@synthesize renderImage;
@synthesize renderPath;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.renderPath = nil;
    }
    return self;
}

- (void)awakeFromNib
{
    self.renderPath = nil;
}

#if DRAW_PATH
- (void)drawRect:(CGRect)rect
{
    if (self.renderPath==nil)
    {
        [super drawRect:rect];
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(ctx, self.renderPath);
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    CGContextFillPath(ctx);
}
#endif

- (void)setImageSlices
{
    //Set Image Slices
	CGImageRef viewCG = self.renderImage.CGImage;
    sliceHeight = 1;//(self.renderImage.size.height/AZANIMATION_SLICE);
	slices = [[NSMutableArray alloc] initWithCapacity:self.renderImage.size.height*[[UIScreen mainScreen] scale]];
	for (int i=0; i < self.renderImage.size.height*[[UIScreen mainScreen] scale]; i++) {
		[slices addObject:[UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewCG, CGRectMake(0, i*sliceHeight, self.renderImage.size.width*[[UIScreen mainScreen] scale], sliceHeight))
                                              scale:[[UIScreen mainScreen] scale]
                                        orientation:UIImageOrientationUp]];
	}
}

- (void)setAnimationFrames
{
    CGPoint rightBottom;
    float renderLeftUnit, renderRightUnit, renderCurrentX;
    int numFrames = AZANIMATION_FRAMERATE/2;
    int nFrame = 0;
    
    CGContextRef        bitmap;
    CGImageAlphaInfo    alphaInfo;
    alphaInfo = kCGImageAlphaPremultipliedFirst;
    // Build a bitmap context that's the size of the thumbRect
    CGFloat bytesPerRow;
    int nScale = [[UIScreen mainScreen] scale];
    bytesPerRow = 4 * self.frame.size.width*nScale;
    // Draw into the context, this scales the image
    for(nFrame=0; nFrame < AZANIMATION_FRAMERATE/2; nFrame++)
    {
        CGColorSpaceRef colorRGB = CGColorSpaceCreateDeviceRGB();
        bitmap = CGBitmapContextCreate( NULL,
                                       self.frame.size.width*nScale,       // width
                                       targetFrame.origin.y*nScale,      // height
                                       8,  // really needs to always be 8
                                       bytesPerRow,    // rowbytes
                                       colorRGB,
                                       kCGImageAlphaPremultipliedFirst );
        CGContextTranslateCTM(bitmap, 0, targetFrame.origin.y*nScale);
        CGContextScaleCTM(bitmap, 1.0*nScale, -1.0*nScale);
        for (NSInteger idx = 0; idx < self.renderImage.size.height ; idx++)
        {
            renderLeftUnit = (leftX[idx]-renderFrame.origin.x)/numFrames;
            rightBottom = CGPointMake((renderFrame.origin.x+renderFrame.size.width),
                                      (renderFrame.origin.y+renderFrame.size.height));
            renderRightUnit = (rightBottom.x-rightX[idx])/numFrames ;
            renderCurrentX = (renderFrame.origin.x+renderLeftUnit*nFrame);
            CGRect clipBox = CGRectMake(renderCurrentX, (renderFrame.origin.y+ idx*sliceHeight),
                                        (rightBottom.x-renderCurrentX)-renderRightUnit*nFrame, sliceHeight);
            CGContextSaveGState(bitmap);
            CGContextClipToRect(bitmap, clipBox);
            CGContextDrawImage(bitmap, clipBox, [[slices objectAtIndex:idx*nScale] CGImage]);
            CGContextRestoreGState(bitmap);
        }
        CGColorSpaceRelease(colorRGB);
        CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
        UIImage*    result = [UIImage imageWithCGImage:ref scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
        [allFrames addObject:result];
        CGContextRelease(bitmap);   
        CGImageRelease(ref);
    }

    int dropY = (targetFrame.origin.y-renderFrame.origin.y)/(AZANIMATION_FRAMERATE/2);
    for(nFrame=0; nFrame < AZANIMATION_FRAMERATE/2; nFrame++)
    {
        CGColorSpaceRef colorRGB = CGColorSpaceCreateDeviceRGB();
        bitmap = CGBitmapContextCreate( NULL,
                                       self.frame.size.width*nScale,       // width
                                       targetFrame.origin.y*nScale,      // height
                                       8,  // really needs to always be 8
                                       bytesPerRow,    // rowbytes
                                       colorRGB,
                                       kCGImageAlphaPremultipliedFirst );
        CGContextTranslateCTM(bitmap, 0, targetFrame.origin.y*nScale);
        CGContextScaleCTM(bitmap, 1.0*nScale, -1.0*nScale);
        for (NSInteger idx = 0; idx < self.renderImage.size.height ; idx++)
        {
            NSInteger newIndex = idx + dropY*nFrame;
            if (newIndex>=targetFrame.origin.y) newIndex = targetFrame.origin.y;
            renderLeftUnit = (leftX[newIndex]-renderFrame.origin.x)/numFrames;
            rightBottom = CGPointMake(renderFrame.origin.x+renderFrame.size.width, renderFrame.origin.y+renderFrame.size.height);
            renderRightUnit = (rightBottom.x-rightX[newIndex])/numFrames;
            renderCurrentX = leftX[newIndex];
            CGRect clipBox = CGRectMake(leftX[newIndex], renderFrame.origin.y+ idx*sliceHeight+ dropY*nFrame,
                                        rightX[newIndex]-leftX[newIndex], sliceHeight);
            CGContextSaveGState(bitmap);
            CGContextClipToRect(bitmap, clipBox);
            CGContextDrawImage(bitmap, clipBox, [[slices objectAtIndex:idx*nScale] CGImage]);
            CGContextRestoreGState(bitmap);
        }
        CGColorSpaceRelease(colorRGB);
        CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
        UIImage*    result = [UIImage imageWithCGImage:ref scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
        [allFrames addObject:result];
        CGContextRelease(bitmap);   
        CGImageRelease(ref);
    }
    
    reverseFrames = [[NSMutableArray alloc] initWithCapacity:allFrames.count];
    for(nFrame=allFrames.count-1;nFrame>=0;nFrame--)
    {
        UIImage* aImage = [allFrames objectAtIndex:nFrame];
        [reverseFrames addObject:aImage];
    }
}

- (void)setRenderFrame:(CGRect)iRenderFrame andTargetFrame:(CGRect)iTargetFrame
{
    // calculate the bezier path
    CGMutablePathRef pathRef = CGPathCreateMutable();
    self.renderPath = pathRef;
	CGPathRetain(pathRef);
    renderFrame = iRenderFrame;
    targetFrame = iTargetFrame;
    allFrames = [[NSMutableArray alloc] initWithCapacity:15];
    
    CGPoint rightTop, leftBottom, rightBottom;
    rightTop = CGPointMake(renderFrame.origin.x+renderFrame.size.width, renderFrame.origin.y);
    rightBottom = CGPointMake(renderFrame.origin.x+renderFrame.size.width, renderFrame.origin.y+renderFrame.size.height);
    leftBottom = CGPointMake(renderFrame.origin.x, renderFrame.origin.y+renderFrame.size.height);
    CGPoint targetRight = CGPointMake(targetFrame.origin.x+targetFrame.size.width, targetFrame.origin.y);
    
    
    CGPathMoveToPoint(pathRef, NULL, renderFrame.origin.x, renderFrame.origin.y);
    CGPathAddCurveToPoint(pathRef, NULL,
                          targetFrame.origin.x*0.3, renderFrame.origin.y+renderFrame.size.height*0.6,
                          targetFrame.origin.x*0.6, renderFrame.origin.y+renderFrame.size.height*0.3,
                          targetFrame.origin.x+5, targetFrame.origin.y-5);
    CGPathAddLineToPoint(pathRef, NULL, targetRight.x-5,targetRight.y-5);
    CGPathAddCurveToPoint(pathRef, NULL,
                          rightBottom.x*0.9, renderFrame.origin.y+renderFrame.size.height*0.3,
                          rightBottom.x, renderFrame.origin.y+renderFrame.size.height*0.6,
                          rightTop.x, rightTop.y);    CGPathCloseSubpath(pathRef);

    [self setImageSlices];
    
    float x, y;
    int nIndex;
    y=rightTop.y;
    for(nIndex=0; y<targetFrame.origin.y; y=y+sliceHeight, nIndex++)
    {
    
        for (x=0; x < self.bounds.size.width; ++x)
        {
            if (CGPathContainsPoint(pathRef, NULL, CGPointMake(x, y), NO))
            {
                leftX[nIndex] = x;
                break;
            }
        }
		if (x == self.bounds.size.width) {
			leftX[nIndex] = 0;
		}
        for (x=self.bounds.size.width; x>leftX[nIndex]; x--)
        {
            if (CGPathContainsPoint(pathRef, NULL, CGPointMake(x, y), NO))
            {
                rightX[nIndex] = x;
                break;
            }
        }
		if (x <= leftX[nIndex]) {
			rightX[nIndex] = leftX[nIndex];
		}
    }
    
    [self setAnimationFrames];
    
    
}

- (void)animationDone:(NSTimer*)timer
{
    if (self.delegate)
    {
        [self.delegate geineAnimationDone];
    }
    if (animationView)
    {
        [animationView removeFromSuperview];
        animationView = nil;
    }
    isAnimation = NO;
}

- (void)genieAnimationShow:(bool)showing withDuration:(NSTimeInterval)duration
{
    if (isAnimation)
        return;
#if PROCESS_ANIMATION
    isAnimation = YES;
    animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, targetFrame.origin.y)];
    
    NSArray *newImages;
    if (showing)
    {
        newImages = [NSArray arrayWithArray:reverseFrames];
    }
    else
    {
        newImages = [NSArray arrayWithArray:allFrames];
    }
    animationView.animationImages = newImages;
    animationView.animationDuration = duration;
    animationView.animationRepeatCount = 1;
    [animationView startAnimating];
    [self addSubview:animationView];
    
    doneTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(animationDone:) userInfo:nil repeats:NO];
#else
    animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, targetFrame.origin.y)];
    [animationView setImage:[allFrames objectAtIndex:AZANIMATION_FRAMERATE/2]];
    [self addSubview:animationView];
#endif
#if DRAW_PATH
    [self setNeedsDisplay];
#endif
}

@end
