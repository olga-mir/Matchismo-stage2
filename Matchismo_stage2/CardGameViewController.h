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

- (Deck *)createDeck; // virtual method
- (NSUInteger)numOfCardsToMatch; // virtual method
- (NSUInteger)defaultNumOfCardsInGame; // virtual method
- (CardView *)createCardViewWithCard:(Card *)card; // virtual method

@end
