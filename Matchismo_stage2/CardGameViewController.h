//
//  cardGameViewController.h
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"

@class CardMatchingGame;
@class CardView;
@class Card;


@interface CardGameViewController : UIViewController

// Virtual methods declarations
// If not implemented in subclass, instantiating and using this class will eventually result in Assert.
- (Deck *)createDeck;
- (NSUInteger)numOfCardsToMatch;
- (NSUInteger)defaultNumOfCardsInGame;
- (CardView *)createCardViewWithFrame:(CGRect)frame withCard:(Card *)card;


@end
