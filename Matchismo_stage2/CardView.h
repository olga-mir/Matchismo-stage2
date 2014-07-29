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

@property (nonatomic) NSUInteger aspectRatio;

- (instancetype)initWithFrame:(CGRect)frame Card:(Card *)setCard; // virtual method

@end
