#import "Appearance.h"

@implementation Appearance

+ (void)configureNavigationBar
{
    UIImage *navigationBackgroundImage = [UIImage imageNamed:@"UINavigationBarBackGround.png"];
    [[UINavigationBar appearance] setBackgroundImage:navigationBackgroundImage forBarMetrics:UIBarMetricsDefault];    
}

+ (void)configureBarButtonItem
{
    UIImage *barButtonItemBackgroundImage = [UIImage imageNamed:@"UIBarButtonItemBarBackGround.png"];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:barButtonItemBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];    
}

+ (void)configure
{
    [self configureNavigationBar];
    [self configureBarButtonItem];
}

@end
