//
//  PlayingCardView.h
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"


@class Card;
@class PlayingCard;

@interface PlayingCardView : CardView

/**
 *  Designated initializer for the Playing card view.
 *
 *  @param frame frame for the view
 *  @param card  the Playing card model. Must be of type PlayingCard
 *
 *  @return the view representing given card
 */
- (instancetype)initWithFrame:(CGRect)frame withCard:(PlayingCard *)card;

- (CGFloat)getCardAspectRatio;

- (CGFloat)cornerRadius;

@end
