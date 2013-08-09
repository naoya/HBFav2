//
//  ChromeProgressBar.m
//  ChromeProgressBar
//
//  Created by Mario Nguyen on 01/12/11.
//  Copyright (c) 2012 Mario Nguyen. All rights reserved.
//

#import "ChromeProgressBar.h"

@implementation ChromeProgressBar

- (void)drawRect:(CGRect)rect {
        
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect progressRect = rect;

    //change bar width on progress value (%)
    progressRect.size.width *= [self progress];
 
    //Fill color
    CGContextSetFillColorWithColor(ctx, [_tintColor CGColor]);
    CGContextFillRect(ctx, progressRect);
    
    //Hide progress with fade-out effect
    if (self.progress == 1.0f &&
        _animationTimer == nil) {
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(hideWithFadeOut) userInfo:nil repeats:YES];
    }

}

- (void) hideWithFadeOut {
    //initialize fade animation 
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [self.layer addAnimation:animation forKey:nil];
    
    //Do hide progress bar
    self.hidden = YES;
    
    if (_animationTimer != nil) {
        [_animationTimer invalidate];
        _animationTimer = nil;    
    }
}

- (void) setProgress:(CGFloat)value animated:(BOOL)animated {
    if ((!animated && value > self.progress) || animated) {
        self.progress = value;
    }
}

- (ChromeProgressBar *)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
        //set bar color
        _tintColor = [[UIColor colorWithRed:51.0f/255.0f green:153.0f/255.0f blue:255.0f/255.0f alpha:1] retain];
		self.progress = 0;
	}
    
	return self;
}

- (void)dealloc {
    [_tintColor release];
    [_animationTimer release];    
	[super dealloc];
}


@end
