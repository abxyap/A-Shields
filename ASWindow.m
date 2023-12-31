#import "ASWindow.h"
#import "ASViewController.h"
#import "./ASScanner.h"

@interface UIWindowScene
@end
@interface UIWindow (iOS13)
@property (nonatomic, assign) UIWindowScene *windowScene;
@end
@interface UIApplication (iOS13)
-(NSSet *)connectedScenes;
@end
@interface ASAlertController : UIAlertController
@end

@implementation ASWindow

- (instancetype)init {
  self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
  float version = [[[UIDevice currentDevice] systemVersion] floatValue];
  if(version >= 13) [self setWindowScene:[[[[UIApplication sharedApplication] connectedScenes] allObjects] firstObject]];
  if (self != nil){
  	[self setHidden:NO];
    [self setWindowLevel:UIWindowLevelAlert];
  	[self setBackgroundColor:[UIColor clearColor]];
  	[self setUserInteractionEnabled:YES];
    [self setRootViewController:[ASViewController sharedInstance]];
  }
  return self;
}

-(void)makeKeyAndVisible {
  [super makeKeyAndVisible];
  return;
}

- (BOOL)shouldAutorotate {
  return FALSE;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *hitTestResult = [super hitTest:point withEvent:event];
  if ([[self subviews] count] == 1) return nil;
  // if (self.touchInjection == false && ![hitTestResult isKindOfClass:[ASAlertController class]]) return nil;
  return hitTestResult;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedSelf = nil;
  dispatch_once(&p, ^{
    _sharedSelf = [[self alloc] init];
  });
  return _sharedSelf;
}

@end
