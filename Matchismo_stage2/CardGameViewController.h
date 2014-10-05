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
- (CGFloat)getCardAspectRatio;


@end


/*
 BUGS LIST
 
 1. Outlets don't appear when switching from one tab to another
    STEPS: 1. run the app. -> Buttons and score label appear properly
           2. switch to another tab -> the buttons are not visible
 
 
 TODOs list
 2. Corner cases 
    1. init game with not enough cards in the deck

 Separate set game "gameOver" logic
 
 Animation sequence still has hiccups.
 
 Implement the Set scoring with regard to available matches.

 
 
  */
