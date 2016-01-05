//
//  BreadCrumbNavigationViewController.h
//  Kabuto
//
//  Created by Aneeq Hashmi on 06/11/2013.
//  Copyright (c) 2013 Folio3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BreadCrumbNavigationController : UINavigationController<UINavigationControllerDelegate>
{
    UIScrollView *_scrollableBar;
    UIView *_breadCrumbView;
    CGFloat _nextButtonStartingPosition;
}

@property(nonatomic) NSString *seperatorImageName;
@property(nonatomic) NSString *breadCrumbFontName;
@property(nonatomic) UIColor *breadCrumbTitleColor;
@property(nonatomic) CGFloat breadCrumbFontSize;
@property(nonatomic) CGFloat breadCrumbMaxWidth;
@property(nonatomic) NSString *backButtonImageName;
@property(nonatomic) CGSize navigationBarSize;


@end


