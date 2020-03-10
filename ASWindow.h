#import <UIKit/UIKit.h>

@interface ASWindow : UIWindow
@property (nonatomic) BOOL touchInjection;
+ (instancetype)sharedInstance;
- (id)init;
@end
