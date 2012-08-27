//
//  AZViewController.m
//  GenieTest
//
//  Created by Jung Kim on 12. 8. 24..
//  Copyright (c) 2012년 AuroraPlanet. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AZViewController.h"

@interface AZViewController ()

@property (assign, nonatomic) bool isShow;
@property (weak, nonatomic) IBOutlet UIImageView *flowerView;
@property (weak, nonatomic) IBOutlet UIButton *targetButton;
- (IBAction)doClick:(id)sender;

@end

@implementation AZViewController
@synthesize genieView;
@synthesize flowerView;
@synthesize targetButton;
@synthesize isShow;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isShow = YES;
    UIImage *screenshot = [self screenshotForViewController];
    [self.genieView setDelegate:self];
    self.genieView.renderImage = screenshot;
    [self.genieView setRenderFrame:self.flowerView.frame andTargetFrame:self.targetButton.frame];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setFlowerView:nil];
    [self setTargetButton:nil];
    [self setGenieView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (UIImage *)screenshotForViewController
{
    UIGraphicsBeginImageContextWithOptions(self.flowerView.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [self.flowerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

- (void)geineAnimationDone
{
    if (self.isShow)
        self.flowerView.hidden = NO;
}

- (IBAction)doClick:(id)sender {
    self.isShow = !self.isShow;
    if (!self.isShow)
        self.flowerView.hidden = YES;
    [self.genieView genieAnimationShow:self.isShow withDuration:1];
}
@end
