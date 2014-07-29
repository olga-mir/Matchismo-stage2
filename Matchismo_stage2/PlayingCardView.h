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

@interface PlayingCardView : CardView

- (instancetype)initWithCard:(Card *)card;

@end
