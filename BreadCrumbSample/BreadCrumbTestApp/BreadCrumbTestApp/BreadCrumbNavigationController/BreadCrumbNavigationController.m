//
//  BreadCrumbNavigationViewController.m
//  Kabuto
//
//  Created by Aneeq Hashmi on 06/11/2013.
//  Copyright (c) 2013 Folio3. All rights reserved.
//


#import "BreadCrumbNavigationController.h"

/*---------------------------------------------------------------------------------------
 
Private Delegate class add the provision of assigning BreadCrumbNavigation Controller delegates to other classes also. Since it is using its delegate it self therefore we cant simply assign its default delegate property to itself as well as other classes

---------------------------------------------------------------------------------------*/
 
#pragma mark -
#pragma mark - Private Delegate Class
#pragma mark -

@interface BreadCrumbNavigationControllerPrivateDelegate : NSObject <UINavigationControllerDelegate> {
@public
    id<UINavigationControllerDelegate> _userDelegate;
}
@end

@implementation BreadCrumbNavigationControllerPrivateDelegate

#pragma mark - Navigation Controller Delegates

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [((BreadCrumbNavigationController*)navigationController) navigationController:navigationController didShowViewController:viewController animated:animated];
    
    if([_userDelegate respondsToSelector:_cmd])
    {
        [_userDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
    
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [((BreadCrumbNavigationController*)navigationController) navigationController:navigationController willShowViewController:viewController animated:animated];
    
    if([_userDelegate respondsToSelector:_cmd])
    {
        [_userDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    
}


#pragma mark - Private Methods

- (BOOL)respondsToSelector:(SEL)selector {
    return [_userDelegate respondsToSelector:selector] || [super respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // This should only ever be called from `NavigationController`, after it has verified
    // that `_userDelegate` responds to the selector by sending me
    // `respondsToSelector:`.  So I don't need to check again here.
    [invocation invokeWithTarget:_userDelegate];
}


@end


#pragma mark -
#pragma mark - Bread Crumb Navigation Controller
#pragma mark -


#define MAX_WIDTH 100.0f;
#define BACK_BUTTON_DEFAULT_WIDTH 50.0f;

@implementation BreadCrumbNavigationController
{
    UIFont *_breadCrumbFont;
    BreadCrumbNavigationControllerPrivateDelegate *_privateDelegate;
}

- (void)initDelegate {
    _privateDelegate = [[BreadCrumbNavigationControllerPrivateDelegate alloc] init];
    [super setDelegate:_privateDelegate];
}

-(void)viewDidLoad
{
    [self initDelegate];
    [self loadDefaultValues];
    [self prepareBreadCrumbNavigationBar];
}

#pragma mark - Actions

-(UIViewController*)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *controller = [super popViewControllerAnimated:animated];
    
    if(controller != nil)
    {
        [self removeLastBreadCrumbButtonWithSeperator];
    }
    return controller;
}

-(NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray *controllers = [super popToRootViewControllerAnimated:animated];
    
    if(controllers != nil && controllers.count > 0)
    {
        for(int count = 0; count < controllers.count ; count++)
            [self removeLastBreadCrumbButtonWithSeperator];
    }
    return controllers;
}

-(void)breadCrumbButtonTapped:(id)sender
{
    while(![[_breadCrumbView subviews].lastObject isEqual:sender])
    {
        [self removeLastBreadCrumbButtonWithSeperator];
    }
    
    UIViewController *controller = [self.viewControllers objectAtIndex:((UIButton*)sender).tag];
    
    [self popToViewController:controller animated:YES];
}

#pragma mark - Navigation Controller Delegates

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController.navigationItem setHidesBackButton:YES];
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    [self addBreadCrumbButtonWithSeperatorForViewController:viewController];
}

#pragma mark - Override Base methods

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    _privateDelegate->_userDelegate = delegate;

    super.delegate = nil;
    super.delegate = (id)_privateDelegate;
}

- (id<UINavigationControllerDelegate>)delegate {
    return _privateDelegate;
}

#pragma mark - Private Methods

-(void)didTappedOnBtnBack
{
    [self popViewControllerAnimated:YES];
}

-(void)prepareBreadCrumbNavigationBar
{
    // Hide the Title on Navigation bar at the center
    [self.navigationBar setTitleTextAttributes:@{
                 NSForegroundColorAttributeName : [UIColor clearColor]
                                                 }];
    
    // Add Back Button in the Navigation Bar
    UIImage *backButtonImage = [UIImage imageNamed:self.backButtonImageName];
    UIButton *btnBack = [[UIButton alloc] init];
    [btnBack setBackgroundColor:[UIColor clearColor]];
    if(backButtonImage != nil)
    {
        [btnBack setImage:backButtonImage forState:UIControlStateNormal];
        [btnBack setImage:backButtonImage forState:UIControlStateSelected];
    }
    else
    {
        [btnBack setTitle:@"Back" forState:UIControlStateNormal];
        [btnBack setTitle:@"Back" forState:UIControlStateSelected];
        [btnBack.titleLabel setFont:_breadCrumbFont];
        [btnBack setTitleColor:self.breadCrumbTitleColor forState:UIControlStateNormal];
    }
    [btnBack sizeToFit];
    [btnBack setFrame:CGRectMake(10, (self.navigationBar.frame.size.height-btnBack.frame.size.height)/2, btnBack.frame.size.width, btnBack.frame.size.height)];
    [btnBack addTarget:self action:@selector(didTappedOnBtnBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationBar addSubview:btnBack];

    CGFloat backButtonWidth = btnBack.frame.size.width + 20;// left & Right Padding of 5px
    
    CGSize size = CGSizeEqualToSize(self.navigationBarSize, CGSizeZero) ? self.navigationBar.frame.size : self.navigationBarSize;
    _scrollableBar = [[UIScrollView alloc] initWithFrame:CGRectMake(backButtonWidth, 0, size.width - backButtonWidth, size.height)];
    _scrollableBar.backgroundColor = [UIColor clearColor];
    
    _breadCrumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollableBar.frame), CGRectGetHeight(_scrollableBar.frame))];
    _breadCrumbView.backgroundColor = [UIColor clearColor];
    
    // For avoiding conflict between Buttons and Bar
    _breadCrumbView.tag = -1;
    
    [_scrollableBar addSubview:_breadCrumbView];
    [self.navigationBar addSubview:_scrollableBar];
    
    _nextButtonStartingPosition = 0;
}

-(void)addSeperator
{
    UIView *view;
    
    if(self.seperatorImageName != nil)
    {
        view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.seperatorImageName]];
        [view sizeToFit];
    }
    else
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.navigationBar.frame.size.height)];
        
    }
    [view setBackgroundColor:[UIColor clearColor]];
    
    [view setFrame:CGRectMake(_nextButtonStartingPosition, (self.navigationBar.frame.size.height - view.frame.size.height)/2, view.frame.size.width, view.frame.size.height)];
    
    [_breadCrumbView addSubview:view];
    
    [self setNextButtonStartingPosition: _nextButtonStartingPosition + view.frame.size.width];
    
}

-(void)addBreadCrumbButton:(NSString *)title
{
    // Add Button for Bread Crumb
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_nextButtonStartingPosition, 0, 10, self.navigationBar.frame.size.height)];
    
    [button setBackgroundColor:[UIColor clearColor]];
    
    button.tag = self.viewControllers.count - 1;
    
    [button addTarget:self action:@selector(breadCrumbButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forState:UIControlStateNormal];
    [button setTitleColor:self.breadCrumbTitleColor forState:UIControlStateNormal];
    
    CGSize size = [button sizeThatFits:button.frame.size];
    
    if(self.breadCrumbMaxWidth < size.width)
        size = CGSizeMake(self.breadCrumbMaxWidth, size.height);
    
    [button setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, size.width + 6, button.frame.size.height)];
    
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [_breadCrumbView addSubview:button];
    
    [self setNextButtonStartingPosition: _nextButtonStartingPosition + button.frame.size.width];
}

-(NSString*)getTitleFromViewController:(UIViewController*)viewController
{
    // Use Navigation item title as bread crumb if available otherwise use view controller title property as bread crumb text
    
    NSString *title = (viewController.navigationItem != nil && viewController.navigationItem.title != nil)
    ? viewController.navigationItem.title
    : viewController.title;
    
    return title;
}

-(void)addBreadCrumbButtonWithSeperatorForViewController:(UIViewController*)viewController
{
    UIButton *button = (UIButton*)[_breadCrumbView viewWithTag:self.viewControllers.count-1];
    NSString *title = [self getTitleFromViewController:viewController];
    
    if(button == nil && title != nil)
    {
        // Seperator not added for Root Controller
        if([_breadCrumbView subviews].count > 0)
            [self addSeperator];
        
        [self addBreadCrumbButton:title];
    }
}

-(void)removeLastBreadCrumbButtonWithSeperator
{
    // Remove Button
    UIView *view = [_breadCrumbView subviews].lastObject;
    [view removeFromSuperview];
    [self setNextButtonStartingPosition:_nextButtonStartingPosition - view.frame.size.width];
    
    // Remove Seperator
    UIView *sep = [_breadCrumbView subviews].lastObject;
    [sep removeFromSuperview];
    [self setNextButtonStartingPosition:_nextButtonStartingPosition - sep.frame.size.width ];
}

-(void)setNextButtonStartingPosition:(CGFloat)value
{
    _nextButtonStartingPosition = value;
    
    if(_nextButtonStartingPosition > _scrollableBar.frame.size.width)
    {
        [_scrollableBar setContentSize:CGSizeMake(_nextButtonStartingPosition, _scrollableBar.frame.size.height)];
        
        CGPoint bottomOffset = CGPointMake(_scrollableBar.contentSize.width - _scrollableBar.bounds.size.width,0);
        [_scrollableBar setContentOffset:bottomOffset animated:YES];
    }
    else
    {
        [_scrollableBar setContentSize:_scrollableBar.frame.size];
    }
    [_breadCrumbView setFrame:CGRectMake(0, 0,_scrollableBar.contentSize.width, _scrollableBar.contentSize.height)];
}

-(void)loadDefaultValues
{
    if(self.breadCrumbMaxWidth == 0.0f)
        self.breadCrumbMaxWidth = MAX_WIDTH;
    
    NSString *fontName = @"Arial";
    CGFloat fontSize = 14;
    if(self.breadCrumbFontName != nil)
        fontName = self.breadCrumbFontName;
    if(self.breadCrumbFontSize > 0.0f)
        fontSize = self.breadCrumbFontSize;
    
    if(self.breadCrumbTitleColor == nil)
        self.breadCrumbTitleColor = [UIColor blackColor];
        
    
    _breadCrumbFont = [UIFont fontWithName:fontName size:fontSize];
}



@end




