#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListItemsController.h>

@interface PSListController (Private)
-(void)_returnKeyPressed:(id)arg1;
-(void)popRecursivelyToRootController;
-(void)viewWillAppear;
-(void)viewDidAppear;
@end
@interface PSViewController (Private2)
-(void)popRecursivelyToRootController;
@end

@interface PSTextFieldSpecifier : PSSpecifier
@property (nonatomic, retain) NSString *placeholder;
@end

@interface ASPCustomizeController : PSListController

@end
