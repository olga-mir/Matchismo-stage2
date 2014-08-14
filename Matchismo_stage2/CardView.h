//
//  CardView.h
//  Matchismo_stage2
//
//  Created by Olga on 26/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Card;

@interface CardView : UIView

@property (nonatomic) BOOL faceUp;

@property (nonatomic) CGFloat faceCardScaleFactor;

- (CGFloat)getCardAspectRatio;
+ (CGFloat)getAspectRatio; // static virtual method? TODO - why overriding in subclass is not working!!!!!!!!!!
- (void)setup;

// Virtual methods

- (instancetype)initWithFrame:(CGRect)frame Card:(Card *)card;
- (CGFloat)cornerRadius;
- (void)selectOrDeselectCard;
- (BOOL)getSelectedState;


@end
