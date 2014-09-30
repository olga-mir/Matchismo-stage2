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

 beautify aRandomMatch logic. (maybe separate it for 2 and 3 card mode)
 
 bug (not finished implementing):
 Match with nulls.
 2014-09-24 15:39:05.566 Matchismo_stage2[6001:90b] Set rules fulfilment: 0xf (0001 - number, 0010 - shape, 0100 - filling, 1000 - color)
 2014-09-24 15:39:05.567 Matchismo_stage2[6001:90b] RANDOM_MATCH: Match has been found
 2014-09-24 15:39:05.567 Matchismo_stage2[6001:90b] Card contents: 0-(null)-(null)-(null),
 2014-09-24 15:39:05.568 Matchismo_stage2[6001:90b] Card contents: 0-(null)-(null)-(null),
 2014-09-24 15:39:05.568 Matchismo_stage2[6001:90b] Card contents: 0-(null)-(null)-(null)
 
 Separate set game "gameOver" logic
 
 Animation sequence still has hiccups.
 
 Implement the Set scoring with regard to available matches.

 
 
  */
