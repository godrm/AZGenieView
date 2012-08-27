//
//  AZViewController.h
//  GenieTest
//
//  Created by Jung Kim on 12. 8. 24..
//  Copyright (c) 2012년 AuroraPlanet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZGenieView.h"

@interface AZViewController : UIViewController <AZGenieAnimationDelegate>
@property (strong, nonatomic) IBOutlet AZGenieView *genieView;

@end
